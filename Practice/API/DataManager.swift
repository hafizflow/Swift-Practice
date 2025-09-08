import SwiftUI
import SwiftData

    // MARK: - DataManager
@MainActor
class DataManager: ObservableObject {
    let api = APIService()
    @Published var loaded = false
    @Published var isLoading = false
    @Published var lastUpdateTime: Date?
    
    @AppStorage("routineVersion") var routineVersion: String = ""
    @AppStorage("courseVersion") var courseVersion: String = ""
    @AppStorage("teacherVersion") var teacherVersion: String = ""
    @AppStorage("lastSyncDate") var lastSyncDate: TimeInterval = 0
    
    private var container: ModelContainer
    private let updateCooldown: TimeInterval = 300 // 5 minutes cooldown
    
    init(container: ModelContainer = try! ModelContainer(for: RoutineModel.self, CourseModel.self, TeacherModel.self)) {
        self.container = container
    }
    
        // MARK: - Load All Data (Version-First Approach)
    func loadAllData(context: ModelContext, routines: [RoutineModel], courses: [CourseModel], teachers: [TeacherModel]) async {
            // Skip if recently updated to avoid unnecessary API calls
        let now = Date().timeIntervalSince1970
        if loaded && now - lastSyncDate < updateCooldown {
            print("Skipping update - last sync was recent (\(Int(now - lastSyncDate))s ago)")
            return
        }
        
        do {
                // 1. First, check versions with lightweight API call
            print("Checking versions...")
            let versionResponse = try await api.fetchVersion()
            
                // 2. Compare versions and determine what needs updating
            let needsRoutineUpdate = routineVersion != versionResponse.routine
            let needsCourseUpdate = courseVersion != versionResponse.course
            let needsTeacherUpdate = teacherVersion != versionResponse.teacher
            
                // 3. If nothing needs updating, exit early
            guard needsRoutineUpdate || needsCourseUpdate || needsTeacherUpdate else {
                print("✅ All versions up to date - no API calls needed")
                print("Current versions - Routine: \(routineVersion), Course: \(courseVersion), Teacher: \(teacherVersion)")
                
                await MainActor.run {
                    self.loaded = true
                    self.lastSyncDate = now
                    self.lastUpdateTime = Date()
                }
                return
            }
            
            print("📱 Updates needed - Routine: \(needsRoutineUpdate ? "✓" : "✗"), Course: \(needsCourseUpdate ? "✓" : "✗"), Teacher: \(needsTeacherUpdate ? "✓" : "✗")")
            
                // 4. Set loading state
            await MainActor.run {
                self.isLoading = true
            }
            
                // 5. Only call the large APIs that need updating (concurrently)
            await withTaskGroup(of: Void.self) { group in
                if needsRoutineUpdate {
                    group.addTask {
                        await self.loadRoutine(context: context, existingRoutines: routines, newVersion: versionResponse.routine)
                    }
                }
                if needsCourseUpdate {
                    group.addTask {
                        await self.loadCourse(context: context, existingCourses: courses, newVersion: versionResponse.course)
                    }
                }
                if needsTeacherUpdate {
                    group.addTask {
                        await self.loadTeacher(context: context, existingTeachers: teachers, newVersion: versionResponse.teacher)
                    }
                }
            }
            
                // 6. Update UI state after all operations complete
            await MainActor.run {
                self.loaded = true
                self.isLoading = false
                self.lastSyncDate = now
                self.lastUpdateTime = Date()
            }
            
            print("🎉 Data sync completed successfully")
            
        } catch {
            print("❌ Error checking versions: \(error.localizedDescription)")
            await MainActor.run {
                self.loaded = true
                self.isLoading = false
            }
        }
    }
    
        // MARK: - Force Refresh (For Pull-to-Refresh)
    func forceRefresh(context: ModelContext, routines: [RoutineModel], courses: [CourseModel], teachers: [TeacherModel]) async {
        lastSyncDate = 0 // Reset cooldown
        await loadAllData(context: context, routines: routines, courses: courses, teachers: teachers)
    }
    
        // MARK: - Load Routine (Version-Optimized)
    private func loadRoutine(context: ModelContext, existingRoutines: [RoutineModel], newVersion: String) async {
        do {
            print("📥 Fetching routine data (version: \(newVersion))...")
            let response = try await api.fetchRoutine()
            guard response.status == "success", !response.data.isEmpty else {
                print("⚠️ Routine API returned no data or failed")
                return
            }
            
                // Perform all heavy operations in background
            try await Task.detached(priority: .userInitiated) {
                let bgContext = await ModelContext(self.container)
                
                    // Delete old data
                for routine in existingRoutines {
                    bgContext.delete(routine)
                }
                
                    // Insert new data in batches to avoid memory spikes
                let batchSize = 50 // Reduced for better responsiveness
                let batches = response.data.chunked(into: batchSize)
                
                for (index, batch) in batches.enumerated() {
                    for dto in batch {
                        let routine = RoutineModel(from: dto)
                        bgContext.insert(routine)
                    }
                    
                        // Save each batch
                    try bgContext.save()
                    
                        // Optional: Add small delay every few batches to prevent overwhelming
                    if index > 0 && index % 5 == 0 {
                        try await Task.sleep(nanoseconds: 10_000_000) // 10ms
                    }
                }
                
                print("✅ Routine data updated - \(response.data.count) records")
            }.value
            
                // Update version on main thread
            await MainActor.run {
                self.routineVersion = newVersion
            }
            
        } catch {
            print("❌ Error loading routine: \(error.localizedDescription)")
        }
    }
    
        // MARK: - Load Course (Version-Optimized)
    private func loadCourse(context: ModelContext, existingCourses: [CourseModel], newVersion: String) async {
        do {
            print("📥 Fetching course data (version: \(newVersion))...")
            let response = try await api.fetchCourse()
            guard response.status == "success", !response.data.isEmpty else {
                print("⚠️ Course API returned no data or failed")
                return
            }
            
            try await Task.detached(priority: .userInitiated) {
                let bgContext = await ModelContext(self.container)
                
                for course in existingCourses {
                    bgContext.delete(course)
                }
                
                let batchSize = 50
                let batches = response.data.chunked(into: batchSize)
                
                for (index, batch) in batches.enumerated() {
                    for dto in batch {
                        let course = CourseModel(from: dto)
                        bgContext.insert(course)
                    }
                    try bgContext.save()
                    
                    if index > 0 && index % 5 == 0 {
                        try await Task.sleep(nanoseconds: 10_000_000)
                    }
                }
                
                print("✅ Course data updated - \(response.data.count) records")
            }.value
            
            await MainActor.run {
                self.courseVersion = newVersion
            }
            
        } catch {
            print("❌ Error loading course: \(error.localizedDescription)")
        }
    }
    
        // MARK: - Load Teacher (Version-Optimized)
    private func loadTeacher(context: ModelContext, existingTeachers: [TeacherModel], newVersion: String) async {
        do {
            print("📥 Fetching teacher data (version: \(newVersion))...")
            let response = try await api.fetchTeacher()
            guard response.status == "success", !response.data.isEmpty else {
                print("⚠️ Teacher API returned no data or failed")
                return
            }
            
            try await Task.detached(priority: .userInitiated) {
                let bgContext = await ModelContext(self.container)
                
                for teacher in existingTeachers {
                    bgContext.delete(teacher)
                }
                
                let batchSize = 50
                let batches = response.data.chunked(into: batchSize)
                
                for (index, batch) in batches.enumerated() {
                    for dto in batch {
                        let teacher = TeacherModel(from: dto)
                        bgContext.insert(teacher)
                    }
                    try bgContext.save()
                    
                    if index > 0 && index % 5 == 0 {
                        try await Task.sleep(nanoseconds: 10_000_000)
                    }
                }
                
                print("✅ Teacher data updated - \(response.data.count) records")
            }.value
            
            await MainActor.run {
                self.teacherVersion = newVersion
            }
            
        } catch {
            print("❌ Error loading teacher: \(error.localizedDescription)")
        }
    }
}

    // MARK: - Array Extension for Batching
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
