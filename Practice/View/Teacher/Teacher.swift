import SwiftUI

struct Teacher: View {
    
    @Binding var isSearching: Bool
        // View Properties
    @State private var currentWeek: [Date.Day] = Date.currentWeek
    @State private var tabType: tabType = .isTeacher
    @State private var selectedDate: Date?
        // For Matched Geometry Effect
    @Namespace private var namespace
    @State private var activeTab: TeacherTab = .routine
    @State private var showAlert: Bool = false
    var haveData: Bool = false
    
    @State private var showSettings = false
    @State private var isScrolledDown = false
    @State private var showMonthRoutineFaculty: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0){
            VStack(alignment: .leading, spacing: 12) {
                TeacherHeaderView(
                    currentWeek: $currentWeek,
                    selectedDate: $selectedDate,
                    showSettings: $showSettings
                )
                
                if !haveData {
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
            
            if haveData {
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
                    ZStack(alignment: .bottomTrailing) {
                        if isSearching {
                            Color.black.opacity(0.001)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    isSearching = false
                                }
                                .zIndex(1)
                        }
                        
                        TExpandableSearchBar(isSearching: $isSearching)
                            .zIndex(2)
                    }
                }
                .background(.testBg)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 30, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 30, style: .continuous))
            } else {
                TabView(selection: $activeTab) {
                    RoutineView(tabType: $tabType, currentWeek: $currentWeek, selectedDate: $selectedDate, showAlert: $showAlert, isScrolledDown: $isScrolledDown)
                        .onAppear {
                                // Setting up initial Selection Date
                            guard selectedDate == nil else { return }
                                // Today's Data
                            selectedDate = currentWeek.first(where: { $0.date.isSame(.now)})?.date
                        }
                        .tag(TeacherTab.routine)
                    
                    
                    ScrollView(.vertical) {
                        TInsightCard()
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
                        
                        ZStack {
                            if activeTab == .routine {
                                TExpandableSearchBar(isSearching: $isSearching)
                                    .zIndex(2)
                            } else {
                                TeacherSearchButton()
                                    .transition(
                                        .asymmetric(insertion: .scale.combined(with: .opacity),
                                                    removal: .scale.combined(with: .opacity))
                                    )
                            }
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: activeTab)
                    }
                }
                .background(.testBg)
                .contentShape(Rectangle()) // ensures taps are registered anywhere
                .simultaneousGesture(
                    TapGesture().onEnded {
                        if isSearching {
                            isSearching = false
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                )
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 30, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 30, style: .continuous))
                .ignoresSafeArea(.all, edges: .bottom)
            }
        }
        .background(.mainBackground)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView(isPresented: $showSettings)
        }
        .fullScreenCover(isPresented: $showMonthRoutineFaculty) {
            TMonthRoutine(showMonthRoutineFaculty: $showMonthRoutineFaculty)
        }
    }
    
    // Computed property for cleaner logic
    private var shouldHideCalendarButton: Bool {
        return isSearching || isScrolledDown
    }
}

#Preview {
    Teacher(isSearching: .constant(false))
}
