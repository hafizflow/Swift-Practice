import SwiftUI
import SwiftData

    // MARK: - DataManager
@MainActor
class DataManager: ObservableObject {
    let api = APIService()
    @Published var loaded = false
    @Published var isLoading = false   // to show progress in UI
    
    @AppStorage("routineVersion") var routineVersion: String = ""
    @AppStorage("courseVersion") var courseVersion: String = ""
    @AppStorage("teacherVersion") var teacherVersion: String = ""
    
    private var container: ModelContainer
    
    init(container: ModelContainer = try! ModelContainer(for: RoutineModel.self, CourseModel.self, TeacherModel.self)) {
        self.container = container
    }
    
        // MARK: - Load Routine
    func loadRoutine(context: ModelContext, existingRoutines: [RoutineModel]) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await api.fetchRoutine()
            guard response.status == "success" else { return }
            
            if routineVersion != response.version && !response.data.isEmpty {
                isLoading = true
                
                try await Task.detached(priority: .userInitiated) {
                    let bgContext = await ModelContext(self.container)
                    
                        // Delete old
                    for r in existingRoutines {
                        bgContext.delete(r)
                    }
                    
                        // Insert new
                    for dto in response.data {
                        let routine = RoutineModel(from: dto)
                        bgContext.insert(routine)
                    }
                    
                    try bgContext.save()
                }.value
                
                    // update version on main actor
                routineVersion = response.version ?? ""
                isLoading = false
            } else {
                print("Routine version unchanged: \(routineVersion)")
                return
            }
        } catch {
            print("Error loading routine: \(error.localizedDescription)")
        }
    }
    
        // MARK: - Load Course
    func loadCourse(context: ModelContext, existingCourses: [CourseModel]) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await api.fetchCourse()
            guard response.status == "success" else { return }
            
            if courseVersion != response.version && !response.data.isEmpty {
                isLoading = true
                
                try await Task.detached(priority: .userInitiated) {
                    let bgContext = await ModelContext(self.container)
                    
                    for c in existingCourses {
                        bgContext.delete(c)
                    }
                    
                    for dto in response.data {
                        let course = CourseModel(from: dto)
                        bgContext.insert(course)
                    }
                    
                    try bgContext.save()
                }.value
                
                courseVersion = response.version ?? ""
                isLoading = false
            } else {
                print("Course version unchanged: \(courseVersion)")
                return
            }
        } catch {
            print("Error loading course: \(error.localizedDescription)")
        }
    }
    
        // MARK: - Load Teacher
    func loadTeacher(context: ModelContext, existingTeachers: [TeacherModel]) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await api.fetchTeacher()
            guard response.status == "success" else { return }
            
            if teacherVersion != response.version && !response.data.isEmpty {
                isLoading = true
                
                try await Task.detached(priority: .userInitiated) {
                    let bgContext = await ModelContext(self.container)
                    
                    for t in existingTeachers {
                        bgContext.delete(t)
                    }
                    
                    for dto in response.data {
                        let teacher = TeacherModel(from: dto)
                        bgContext.insert(teacher)
                    }
                    
                    try bgContext.save()
                }.value
                
                teacherVersion = response.version ?? ""
                isLoading = false
            } else {
                print("Teacher version unchanged: \(teacherVersion)")
                return
            }
        } catch {
            print("Error loading teacher: \(error.localizedDescription)")
        }
    }
}
