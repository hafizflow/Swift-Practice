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
                    .environmentObject(emptyRoomManager)
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
        .preferredColorScheme(.dark)
        .tint(.teal.opacity(0.9))
        .background(.testBg)
        .ScustomAlert(isPresented: $showAlert)
        .task {
            if !dataManager.loaded {
                    // ✅ First populate from SwiftData immediately
                routineManager.routines = routines
                routineManager.courses = courses
                routineManager.teachers = teachers
                
                teacherManager.routines = routines
                teacherManager.courses = courses
                teacherManager.teachers = teachers
                
                emptyRoomManager.routines = routines
                
                    // ✅ Now kick off API load in the background
                await dataManager.loadRoutine(context: context, existingRoutines: routines)
                await dataManager.loadCourse(context: context, existingCourses: courses)
                await dataManager.loadTeacher(context: context, existingTeachers: teachers)
                dataManager.loaded = true
            }
        }
        .onChange(of: routines) { _, newRoutines in
            routineManager.routines = newRoutines
            teacherManager.routines = newRoutines
            emptyRoomManager.routines = newRoutines
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

