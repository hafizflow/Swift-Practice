import SwiftUI

struct Student: View {
    
    @Binding var showAlert: Bool
    @Binding var isSearching: Bool
        // View Properties
    @State private var currentWeek: [Date.Day] = Date.currentWeek
    @State private var selectedDate: Date?
    @State private var activeTab: StudentTab = .routine
    var offSetObserve = PageOffsetObserver()
    @State private var tabType: tabType = .isStudent
    var haveData: Bool = false
    
        // Settings sheet state
    @State private var showSettings: Bool = false
    @State private var isScrolledDown: Bool = false
    @State private var showMonthRoutine: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0){
            StudentHeaderView(
                currentWeek: $currentWeek,
                selectedDate: $selectedDate,
                activeTab: $activeTab,
                showSettings: $showSettings
            )
            .environment(\.colorScheme, .dark)
            
            if haveData {
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
                    ZStack(alignment: .bottomTrailing) {
                        if isSearching {
                                // Fullscreen invisible layer
                            Color.black.opacity(0.001)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    isSearching = false
                                }
                                .zIndex(1)
                        }
                        
                        SExpandableSearchBar(isSearching: $isSearching)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 5)
                            .zIndex(2)
                    }
                }
                .background(.testBg)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 30, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 30, style: .continuous))
            } else {
                TabView(selection: $activeTab) {
                    RoutineView(tabType: $tabType,
                                currentWeek: $currentWeek,
                                selectedDate: $selectedDate,
                                showAlert: $showAlert,
                                isScrolledDown: $isScrolledDown
                    )
                    .onAppear {
                            // Setting up initial Selection Date
                        guard selectedDate == nil else { return }
                            // Today's Data
                        selectedDate = currentWeek.first(where: { $0.date.isSame(.now)})?.date
                    }
                    .tag(StudentTab.routine)
                    
                    ScrollView(.vertical) {
                        SInsightCard().padding(20)
                    }
                    .tag(StudentTab.insights)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .overlay(alignment: .bottomTrailing) {
                    ZStack(alignment: .bottomTrailing) {
                        if isSearching {
                                // Fullscreen invisible layer
                            Color.black.opacity(0.001)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    isSearching = false
                                }
                                .zIndex(1)
                        }
                        
                        CalenderButton(showMonthRoutine: $showMonthRoutine)
                            .opacity(shouldHideCalendarButton ? 0 : 1)
                            .scaleEffect(shouldHideCalendarButton ? 0.8 : 1)
                            .offset(y: shouldHideCalendarButton ? 20 : 0)
                            .animation(.easeInOut(duration: 0.3), value: shouldHideCalendarButton)
                            .zIndex(shouldHideCalendarButton ? 0 : 1)
                            .disabled(shouldHideCalendarButton)
                        
                        
                        SExpandableSearchBar(isSearching: $isSearching)
                            .zIndex(2)
                    }
                }
                .background(.testBg)
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: 30,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 30,
                    style: .continuous)
                )
                .ignoresSafeArea(.all, edges: .bottom)
            }
        }
        .background(.mainBackground)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView(isPresented: $showSettings)
        }
        .fullScreenCover(isPresented: $showMonthRoutine) {
            SMonthRoutine(showMonthRoutine: $showMonthRoutine)
        }
    }
    
        // Computed property for cleaner logic
    private var shouldHideCalendarButton: Bool {
        return isSearching || (activeTab == .routine && isScrolledDown)
    }
}

#Preview {
    Student(
        showAlert: .constant(false),
        isSearching: .constant(false),
    )
}
