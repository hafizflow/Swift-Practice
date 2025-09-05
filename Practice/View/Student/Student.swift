import SwiftUI
import SwiftData

struct Student: View {
    @Environment(\.modelContext) private var context
    @Query private var routines: [RoutineModel]
    @Query private var courses: [CourseModel]
    @Query private var teachers: [TeacherModel]
    
    @Binding var showAlert: Bool
    @Binding var isSearching: Bool
    
        // View Properties
    @State private var currentWeek: [Date.Day] = Date.currentWeek
    @State private var selectedDate: Date?
    @State private var activeTab: StudentTab = .routine
    var offSetObserve = PageOffsetObserver()
    @State private var tabType: tabType = .isStudent
    
        // Data managers
    @StateObject private var routineManager = RoutineManager()
    @StateObject private var dataManager = DataManager()
    
        // Data state - now based on actual search results
    private var hasData: Bool {
        return !routineManager.selectedSection.isEmpty && !routineManager.filteredRoutinesWithDetails.isEmpty
    }
    
    private var hasSearched: Bool {
        return !routineManager.selectedSection.isEmpty
    }
    
        // Settings sheet state
    @State private var showSettings: Bool = false
    @State private var isScrolledDown: Bool = false
    @State private var showMonthRoutineStudent: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            
                // Header always visible
            VStack(alignment: .leading, spacing: 12) {
                StudentHeaderView(
                    currentWeek: $currentWeek,
                    selectedDate: $selectedDate,
                    activeTab: $activeTab,
                    showSettings: $showSettings
                )
                
                if hasData {
                    StudentTabBar(
                        activeTab: $activeTab,
                        selectedDate: $selectedDate,
                        tint: .gray,
                        weight: .semibold
                    )
                    .padding(.horizontal, 15)
                    .padding(.bottom, 10)
                }
            }
            .environment(\.colorScheme, .dark)
            
                // Content based on search state
            if !hasSearched {
                    // Empty state (no section searched yet)
                VStack {
                    LottieAnimation(animationName: "discover.json")
                        .frame(maxWidth: .infinity , maxHeight: 250)
                        .padding(.horizontal, 30)
                    
                    Text("Enter Your Section")
                        .foregroundStyle(.white.opacity(0.9))
                        .fontWeight(.medium)
                        .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity , maxHeight: .infinity)
                .overlay(alignment: .bottomTrailing) {
                    searchBarOverlay
                }
                .background(.testBg)
                .onTapGesture {
                        // Only dismiss if not tapping on search bar
                    if isSearching {
                        isSearching = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 30,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 30,
                        style: .continuous
                    )
                )
                
            } else if hasSearched && !hasData {
                    // No results found for searched section
                VStack(spacing: 20) {
                    LottieAnimation(animationName: "yogi.json")
                        .frame(maxWidth: .infinity , maxHeight: 250)
                        .padding(.horizontal, 30)
                    
                    Text("No Routines Found")
                        .foregroundStyle(.white.opacity(0.9))
                        .fontWeight(.medium)
                    
                    Text("No classes found for section '\(routineManager.selectedSection)'")
                        .foregroundStyle(.gray)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button("Try Different Section") {
                        routineManager.selectedSection = ""
                        isSearching = true
                    }
                    .foregroundColor(.teal)
                    .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity , maxHeight: .infinity)
                .overlay(alignment: .bottomTrailing) {
                    searchBarOverlay
                }
                .background(.testBg)
                .onTapGesture {
                        // Only dismiss if not tapping on search bar
                    if isSearching {
                        isSearching = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 30,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 30,
                        style: .continuous
                    )
                )
                
            } else {
                    // Actual Routine & Insights (has data)
                TabView(selection: $activeTab) {
                    
                    RoutineView(
                        tabType: $tabType,
                        currentWeek: $currentWeek,
                        selectedDate: $selectedDate,
                        showAlert: $showAlert
                    )
                    .environmentObject(routineManager)  // Pass the manager
                    .onAppear {
                            // Setting up initial Selection Date
                        guard selectedDate == nil else { return }
                        selectedDate = currentWeek.first(where: { $0.date.isSame(.now)})?.date
                    }
                    .tag(StudentTab.routine)
                    
                    ScrollView(.vertical) {
                        SInsightCard(routineManager: routineManager)
                            .padding(20)
                            .padding(.bottom, 100)
                    }
                    .tag(StudentTab.insights)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .overlay(alignment: .bottomTrailing) {
                    ZStack(alignment: .bottomTrailing) {
                        CalenderButton(showMonthRoutine: $showMonthRoutineStudent)
                            .opacity(shouldHideCalendarButton ? 0 : 1)
                            .scaleEffect(shouldHideCalendarButton ? 0.8 : 1)
                            .offset(y: shouldHideCalendarButton ? 20 : 0)
                            .animation(.easeInOut(duration: 0.3), value: shouldHideCalendarButton)
                            .zIndex(shouldHideCalendarButton ? 0 : 1)
                            .disabled(shouldHideCalendarButton)
                        
                        searchBarOverlay
                    }
                }
                .background(.testBg)
                .contentShape(Rectangle())
                .onTapGesture {
                        // Only dismiss if not tapping on search bar
                    if isSearching {
                        isSearching = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 30,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 30,
                        style: .continuous
                    )
                )
                .ignoresSafeArea(.all, edges: .bottom)
            }
        }
        .background(.mainBackground)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView(isPresented: $showSettings)
        }
        .fullScreenCover(isPresented: $showMonthRoutineStudent) {
            SMonthRoutine(showMonthRoutineStudent: $showMonthRoutineStudent)
        }
        .task {
            if !dataManager.loaded {
                await dataManager.loadRoutine(context: context, existingRoutines: routines)
                await dataManager.loadCourse(context: context, existingCourses: courses)
                await dataManager.loadTeacher(context: context, existingTeachers: teachers)
                dataManager.loaded = true
                
                    // Update routine manager with loaded data
                routineManager.routines = routines
                routineManager.courses = courses
                routineManager.teachers = teachers
            }
        }
        .onChange(of: routines) { _, newRoutines in
            routineManager.routines = newRoutines
        }
        .onChange(of: courses) { _, newCourses in
            routineManager.courses = newCourses
        }
        .onChange(of: teachers) { _, newTeachers in
            routineManager.teachers = newTeachers
        }
    }
    
        // Computed property for cleaner logic
    private var shouldHideCalendarButton: Bool {
        return isSearching || isScrolledDown
    }
    
        // Reusable search bar overlay
    private var searchBarOverlay: some View {
        ZStack(alignment: .bottomTrailing) {
            SExpandableSearchBar(isSearching: $isSearching)
                .environmentObject(routineManager)
        }
    }
}

#Preview {
    Student(
        showAlert: .constant(false),
        isSearching: .constant(false)
    )
}
