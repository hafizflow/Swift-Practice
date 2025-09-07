//    import SwiftUI
//    import SwiftData
//    
//    struct Home: View {
//        @State private var activeTab: Tab = .student
//        @State private var showAlert: Bool = false
//        @State private var isSearchingS: Bool = false
//        @State private var isSearchingT: Bool = false
//        @State private var isSearchingEmpty: Bool = false
//        @State private var isSearchingExam: Bool = false
//    
//            // SwiftData environment and queries
//        @Environment(\.modelContext) private var context
//        @Query private var routines: [RoutineModel]
//        @Query private var courses: [CourseModel]
//        @Query private var teachers: [TeacherModel]
//    
//            // Single data manager for the entire app
//        @StateObject private var dataManager = DataManager()
//    
//            // Managers that will be passed to child views
//        @StateObject private var routineManager = RoutineManager()
//        @StateObject private var teacherManager = TeacherManager()
//    
//        @State private var allTabs: [AnimatedTab] = Tab.allCases.compactMap { tab ->
//            AnimatedTab? in
//            return .init(tab: tab)
//        }
//    
//        var body: some View {
//            VStack(spacing: 0) {
//                TabView(selection: $activeTab) {
//                    NavigationStack {
//                        Student(showAlert: $showAlert, isSearching: $isSearchingS)
//                            .environmentObject(routineManager)
//                    }
//                    .setUpTab(.student)
//    
//                    NavigationStack {
//                        Teacher(isSearching: $isSearchingT)
//                            .environmentObject(teacherManager)
//                    }
//                    .setUpTab(.teacher)
//    
//                    NavigationStack {
//                        EmptyRoom(isSearching: $isSearchingEmpty)
//                            .environmentObject(routineManager) // or create separate manager if needed
//                    }
//                    .setUpTab(.emptyRoom)
//    
//                    NavigationStack {
//                        ExamRoutine(showAlert: $showAlert, isSearching: $isSearchingExam)
//                            .environmentObject(routineManager) // or create separate manager if needed
//                    }
//                    .setUpTab(.examRoutine)
//                }
//                CustomTabBar()
//            }
//            .ScustomAlert(isPresented: $showAlert)
//            .task {
//                    // Load data only once when the app starts
//                if !dataManager.loaded {
//                    await dataManager.loadRoutine(context: context, existingRoutines: routines)
//                    await dataManager.loadCourse(context: context, existingCourses: courses)
//                    await dataManager.loadTeacher(context: context, existingTeachers: teachers)
//                    dataManager.loaded = true
//    
//                        // Update all managers with loaded data
//                    routineManager.routines = routines
//                    routineManager.courses = courses
//                    routineManager.teachers = teachers
//    
//                    teacherManager.routines = routines
//                    teacherManager.courses = courses
//                    teacherManager.teachers = teachers
//                }
//            }
//            .onChange(of: routines) { _, newRoutines in
//                // Update all managers when data changes
//                routineManager.routines = newRoutines
//                teacherManager.routines = newRoutines
//            }
//            .onChange(of: courses) { _, newCourses in
//                routineManager.courses = newCourses
//                teacherManager.courses = newCourses
//            }
//            .onChange(of: teachers) { _, newTeachers in
//                routineManager.teachers = newTeachers
//                teacherManager.teachers = newTeachers
//            }
//        }
//    
//            // Custom Tab Bar
//        @ViewBuilder
//        func CustomTabBar() -> some View {
//            HStack(spacing: 0) {
//                ForEach($allTabs) { $animatedTab in
//                    let tab = animatedTab.tab
//                    VStack(spacing: 4) {
//                        Image(systemName: tab.rawValue)
//                            .font(.title2)
//                            .symbolEffect(.bounce.down.byLayer, value: animatedTab.isAnimating)
//    
//                        Text(tab.title)
//                            .font(.caption2)
//                            .textScale(.secondary)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .foregroundStyle(activeTab == tab ? Color.teal.opacity(0.8) : Color.gray)
//                    .padding(.top, 15)
//                    .padding(.bottom, 10)
//                    .contentShape(.rect)
//                    .onTapGesture {
//                        withAnimation(.bouncy, completionCriteria: .logicallyComplete, {
//                            activeTab = tab
//                            animatedTab.isAnimating = true
//                        }, completion: {
//                            var transaction = Transaction()
//                            transaction.disablesAnimations = true
//                            withTransaction(transaction) {
//                                animatedTab.isAnimating = nil
//                            }
//                        })
//                    }
//                }
//            }
//            .background(.testBg)
//        }
//    }
//    
//    extension View {
//        @ViewBuilder
//        func setUpTab(_ tab: Tab) -> some View {
//            self
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .tag(tab)
//                .toolbar(.hidden, for: .tabBar)
//        }
//    }
//    
//    #Preview {
//        Home()
//    }
//


enum Tab: String {
    case student = "graduationcap"
    case teacher = "person.crop.rectangle.stack"
    case emptyRoom = "square.stack"
    case examRoutine = "list.clipboard"
    
    var title: String {
        switch self {
            case .student: return "Student"
            case .teacher: return "Teacher"
            case .emptyRoom: return "EmptyRoom"
            case .examRoutine: return "Exam"
        }
    }
}

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
    
    var body: some View {
        TabView(selection: $activeTab) {
            NavigationStack {
                Student(showAlert: $showAlert, isSearching: $isSearchingS)
                    .environmentObject(routineManager)
            }
            .tabItem {
                Label(Tab.student.title, systemImage: Tab.student.rawValue)
            }
            .tag(Tab.student)
            
            NavigationStack {
                Teacher(isSearching: $isSearchingT)
                    .environmentObject(teacherManager)
            }
            .tabItem {
                Label(Tab.teacher.title, systemImage: Tab.teacher.rawValue)

            }
            .tag(Tab.teacher)
            
            NavigationStack {
                EmptyRoom(isSearching: $isSearchingEmpty)
                    .environmentObject(routineManager)
            }
            .tabItem {
                Label(Tab.emptyRoom.title, systemImage: Tab.emptyRoom.rawValue)

            }
            .tag(Tab.emptyRoom)
            
            NavigationStack {
                ExamRoutine(showAlert: $showAlert, isSearching: $isSearchingExam)
                    .environmentObject(routineManager)
            }
            .tabItem {
                Label(Tab.examRoutine.title, systemImage: Tab.examRoutine.rawValue)

            }
            .tag(Tab.examRoutine)
        }
        .tint(.teal.opacity(0.9))
        .background(.testBg)
        .preferredColorScheme(.dark)
        .ScustomAlert(isPresented: $showAlert)
        .task {
            if !dataManager.loaded {
                await dataManager.loadRoutine(context: context, existingRoutines: routines)
                await dataManager.loadCourse(context: context, existingCourses: courses)
                await dataManager.loadTeacher(context: context, existingTeachers: teachers)
                dataManager.loaded = true
                
                routineManager.routines = routines
                routineManager.courses = courses
                routineManager.teachers = teachers
                
                teacherManager.routines = routines
                teacherManager.courses = courses
                teacherManager.teachers = teachers
            }
        }
        .onChange(of: routines) { _, newRoutines in
            routineManager.routines = newRoutines
            teacherManager.routines = newRoutines
        }
        .onChange(of: courses) { _, newCourses in
            routineManager.courses = newCourses
            teacherManager.courses = newCourses
        }
        .onChange(of: teachers) { _, newTeachers in
            routineManager.teachers = newTeachers
            teacherManager.teachers = newTeachers
        }
    }
}

#Preview {
    Home()
}
