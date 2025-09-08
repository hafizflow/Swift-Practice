import SwiftUI
import SwiftData

struct Teacher: View {
    @Binding var isSearching: Bool
    
        // Get the teacher manager from environment (passed from Home)
    @EnvironmentObject private var teacherManager: TeacherManager
    
        // View Properties
    @State private var currentWeek: [Date.Day] = Date.currentWeek
    @State private var tabType: tabType = .isTeacher
    @State private var selectedDate: Date? = Date()
    @State private var activeTab: TeacherTab = .routine
    @State private var showAlert: Bool = false
    
        // Data state - based on actual search results
    private var hasData: Bool {
        return !teacherManager.selectedTeacher.isEmpty && !teacherManager.filteredRoutinesWithDetails.isEmpty
    }
    
    private var hasSearched: Bool {
        return !teacherManager.selectedTeacher.isEmpty
    }
    
        // Settings sheet state
    @State private var showSettings = false
    @State private var isScrolledDown = false
    @State private var showMonthRoutineFaculty: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            
                // Header always visible
            VStack(alignment: .leading, spacing: 12) {
                TeacherHeaderView(
                    currentWeek: $currentWeek,
                    selectedDate: $selectedDate,
                    showSettings: $showSettings
                )
                
                if hasData {
                    TeacherTabBar(
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
                    // Empty state (no teacher searched yet)
                VStack {
                    LottieAnimation(animationName: "discover.json")
                        .frame(maxWidth: .infinity , maxHeight: 250)
                        .padding(.horizontal, 30)
                    
                    Text("Enter Teacher Initial")
                        .foregroundStyle(.white.opacity(0.9))
                        .fontWeight(.medium)
                        .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity , maxHeight: .infinity)
                .overlay(alignment: .bottomTrailing) {
                    searchBarOverlay
                }
                .background(.testBg)
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
                    // No results found for searched teacher
                VStack(spacing: 20) {
                    LottieAnimation(animationName: "medi.json")
                        .frame(maxWidth: .infinity , maxHeight: 250)
                        .padding(.horizontal, 30)
                    
                    Text("No Classes Found")
                        .foregroundStyle(.white.opacity(0.9))
                        .fontWeight(.medium)
                    
                    Text("No classes found for teacher '\(teacherManager.selectedTeacher)'")
                        .foregroundStyle(.gray)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button("Try Different Teacher") {
                        teacherManager.selectedTeacher = ""
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
                    .environmentObject(teacherManager)
                    .onAppear {
                            // Setting up initial Selection Date
                        guard selectedDate == nil else { return }
                        selectedDate = currentWeek.first(where: { $0.date.isSame(.now)})?.date
                    }
                    .tag(TeacherTab.routine)
                    
                    ScrollView(.vertical) {
                        TInsightCard(teacherManager: teacherManager)
                            .environmentObject(teacherManager)
                            .padding(20)
                            .padding(.bottom, 100)
                    }
                    .tag(TeacherTab.insights)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .overlay(alignment: .bottomTrailing) {
                    ZStack(alignment: .bottomTrailing) {
                        CalenderButton(showMonthRoutine: $showMonthRoutineFaculty)
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
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 30,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 30,
                        style: .continuous
                    )
                )
            }
        }
        .background(.mainBackground)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .gesture(
            TapGesture()
                .onEnded { _ in
                    if isSearching {
                        isSearching = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                },
            including: isSearching ? .all : .subviews
        )
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView(isPresented: $showSettings)
        }
        .fullScreenCover(isPresented: $showMonthRoutineFaculty) {
            TMonthRoutine(showMonthRoutineFaculty: $showMonthRoutineFaculty)
                .environmentObject(teacherManager)
        }
    }
    
        // Computed property for cleaner logic
    private var shouldHideCalendarButton: Bool {
        return isSearching || isScrolledDown
    }
    
        // Reusable search bar overlay
    private var searchBarOverlay: some View {
        ZStack(alignment: .bottomTrailing) {
            TExpandableSearchBar(isSearching: $isSearching)
                .environmentObject(teacherManager)
        }
    }
}

#Preview {
    Teacher(isSearching: .constant(false))
        .environmentObject(TeacherManager())
}
