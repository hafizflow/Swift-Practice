import SwiftUI
import SwiftData

struct Home: View {
    @State private var activeTab: Tab = .student
    @State private var showAlert: Bool = false
    @State private var isSearchingS: Bool = false
    @State private var isSearchingT: Bool = false
    @State private var isSearchingEmpty: Bool = false
    @State private var isSearchingExam: Bool = false
    
        // SwiftData environment and queries
    @Environment(\.modelContext) private var context
    @Query private var routines: [RoutineModel]
    @Query private var courses: [CourseModel]
    @Query private var teachers: [TeacherModel]
    
        // Managers
    @StateObject private var dataManager = DataManager()
    @StateObject private var routineManager = RoutineManager()
    @StateObject private var teacherManager = TeacherManager()
    @StateObject private var emptyRoomManager = EmptyRoomManager()
    
        // Optimization: Track data initialization
    @State private var managersInitialized = false
    
    var body: some View {
        ZStack {
            TabView(selection: $activeTab) {
                NavigationStack {
                    Student(showAlert: $showAlert, isSearching: $isSearchingS)
                        .environmentObject(routineManager)
                        .refreshable {
                            await refreshData()
                        }
                }
                .tabItem {
                    Label(Tab.student.title, systemImage: Tab.student.rawValue)
                }
                .tag(Tab.student)
                
                NavigationStack {
                    Teacher(isSearching: $isSearchingT)
                        .environmentObject(teacherManager)
                        .refreshable {
                            await refreshData()
                        }
                }
                .tabItem {
                    Label(Tab.teacher.title, systemImage: Tab.teacher.rawValue)
                }
                .tag(Tab.teacher)
                
                NavigationStack {
                    EmptyRoom(isSearching: $isSearchingEmpty)
                        .environmentObject(routineManager)
                        .environmentObject(emptyRoomManager)
                        .refreshable {
                            await refreshData()
                        }
                }
                .tabItem {
                    Label(Tab.emptyRoom.title, systemImage: Tab.emptyRoom.rawValue)
                }
                .tag(Tab.emptyRoom)
                
                NavigationStack {
                    ExamRoutine(showAlert: $showAlert, isSearching: $isSearchingExam)
                        .environmentObject(routineManager)
                        .refreshable {
                            await refreshData()
                        }
                }
                .tabItem {
                    Label(Tab.examRoutine.title, systemImage: Tab.examRoutine.rawValue)
                }
                .tag(Tab.examRoutine)
            }
            .preferredColorScheme(.dark)
            .tint(.teal.opacity(0.9))
            .background(.testBg)
            .ScustomAlert(isPresented: $showAlert)
            
                // Show loading indicator while data is being fetched
            if dataManager.isLoading {
                LoadingOverlay(lastUpdateTime: dataManager.lastUpdateTime)
            }
        }
        .onAppear {
                // Initialize managers immediately if not done yet
            if !managersInitialized {
                initializeManagers()
                managersInitialized = true
            }
        }
        .task {
                // Perform version check and data loading in background
            await loadDataInBackground()
        }
        .onChange(of: routines) { _, newRoutines in
                // Only update if managers are initialized to avoid unnecessary work
            if managersInitialized {
                updateRoutinesInManagers(newRoutines)
            }
        }
        .onChange(of: courses) { _, newCourses in
            if managersInitialized {
                updateCoursesInManagers(newCourses)
            }
        }
        .onChange(of: teachers) { _, newTeachers in
            if managersInitialized {
                updateTeachersInManagers(newTeachers)
            }
        }
    }
    
        // MARK: - Helper Methods
    
        /// Initialize managers with cached data immediately - non-blocking UI operation
    private func initializeManagers() {
            // This is lightweight - just assigning references
        routineManager.routines = routines
        routineManager.courses = courses
        routineManager.teachers = teachers
        
        teacherManager.routines = routines
        teacherManager.courses = courses
        teacherManager.teachers = teachers
        
        emptyRoomManager.routines = routines
        
        print("🚀 Managers initialized with \(routines.count) routines, \(courses.count) courses, \(teachers.count) teachers")
    }
    
        /// Load data in background without blocking UI
    private func loadDataInBackground() async {
            // Only proceed if not already loaded or if it's been a while
        guard !dataManager.loaded || shouldCheckForUpdates() else {
            print("⏭️ Skipping background load - recently updated")
            return
        }
        
            // Perform version check and conditional data loading
        await dataManager.loadAllData(
            context: context,
            routines: routines,
            courses: courses,
            teachers: teachers
        )
    }
    
        /// Force refresh data (for pull-to-refresh)
    private func refreshData() async {
        print("🔄 Force refreshing data...")
        await dataManager.forceRefresh(
            context: context,
            routines: routines,
            courses: courses,
            teachers: teachers
        )
    }
    
        /// Check if we should check for updates based on time
    private func shouldCheckForUpdates() -> Bool {
        let now = Date().timeIntervalSince1970
        let lastCheck = dataManager.lastSyncDate
        let timeSinceLastCheck = now - lastCheck
        
            // Check for updates if it's been more than 5 minutes
        return timeSinceLastCheck > 300
    }
    
        /// Update routines in all managers - lightweight operation
    private func updateRoutinesInManagers(_ newRoutines: [RoutineModel]) {
        routineManager.routines = newRoutines
        teacherManager.routines = newRoutines
        emptyRoomManager.routines = newRoutines
        print("📊 Updated routines in managers: \(newRoutines.count) items")
    }
    
        /// Update courses in managers - lightweight operation
    private func updateCoursesInManagers(_ newCourses: [CourseModel]) {
        routineManager.courses = newCourses
        teacherManager.courses = newCourses
        print("📚 Updated courses in managers: \(newCourses.count) items")
    }
    
        /// Update teachers in managers - lightweight operation
    private func updateTeachersInManagers(_ newTeachers: [TeacherModel]) {
        routineManager.teachers = newTeachers
        teacherManager.teachers = newTeachers
        print("👨‍🏫 Updated teachers in managers: \(newTeachers.count) items")
    }
}

    // MARK: - Enhanced Loading Overlay
struct LoadingOverlay: View {
    let lastUpdateTime: Date?
    @State private var progress: Double = 0.0
    @State private var animationPhase = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                    // Animated progress indicator
                ZStack {
                    Circle()
                        .stroke(Color.teal.opacity(0.3), lineWidth: 4)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            AngularGradient(
                                colors: [.teal, .cyan, .teal],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
                
                VStack(spacing: 8) {
                    Text("Updating data...")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    if let lastUpdate = lastUpdateTime {
                        Text("Last updated: \(formatTime(lastUpdate))")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption)
                    } else {
                        Text("Checking for updates...")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption)
                    }
                }
                
                    // Subtle animation dots
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.teal)
                            .frame(width: 6, height: 6)
                            .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                                value: animationPhase
                            )
                    }
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .opacity(0.95)
                    .shadow(radius: 10)
            )
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
            // Animate progress bar
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            progress = 0.8
        }
        
            // Animate dots
        Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            animationPhase = (animationPhase + 1) % 3
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    Home()
}
