import SwiftUI

struct Home: View {
    @State private var activeTab: Tab = .student
    @State private var showAlert: Bool = false
    @State private var isSearchingS: Bool = false
    @State private var isSearchingT: Bool = false
    
    
    @State private var allTabs: [AnimatedTab] = Tab.allCases.compactMap { tab ->
        AnimatedTab? in
        return .init(tab: tab)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $activeTab) {
                NavigationStack {Student(showAlert: $showAlert)}.setUpTab(.student)

                NavigationStack {Teacher()}.setUpTab(.teacher)
                
                NavigationStack {EmptyRoom(showAlert: $showAlert)}.setUpTab(.emptyRoom)
                
                NavigationStack {
                    VStack {
                        
                    }
                    .navigationTitle(Tab.examRoutine.title)
                }
                .setUpTab(.examRoutine)
            }
            CustomTabBar()
        }
        .overlay(alignment: .bottomTrailing) {
            ZStack (alignment: .bottomTrailing) {
                    // Student tab
                if activeTab == .student {
                    if isSearchingS {
                            // Fullscreen invisible layer
                        Color.black.opacity(0.001)
                            .ignoresSafeArea()
                            .onTapGesture {
                                isSearchingS = false
                            }
                            .zIndex(1) // keep it below the search bar
                    }
                    
                    SExpandableSearchBar(isSearching: $isSearchingS)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 75)
                        .id("student")
                        .zIndex(2) // above the transparent layer
                }
                
                    // Teacher tab
                else if activeTab == .teacher {
                    if isSearchingT {
                        Color.black.opacity(0.001)
                            .ignoresSafeArea()
                            .onTapGesture {
                                isSearchingT = false
                            }
                            .zIndex(1)
                    }
                    
                    TExpandableSearchBar(isSearching: $isSearchingT)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 75)
                        .id("teacher")
                        .zIndex(2)
                }
                
                    // Empty Room tab
                else if activeTab == .emptyRoom {
                    TimeChangeButton()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 75)
                        .id("emptyRoom")
                        .zIndex(2)
                }
            }
        }
        .customAlert(isPresented: $showAlert)
    }
    
    
        // Custom Tab Bar
    @ViewBuilder
    func CustomTabBar() -> some View {
        HStack(spacing: 0) {
            ForEach($allTabs) { $animatedTab in
                let tab = animatedTab.tab
                
                VStack(spacing: 4) {
                    Image(systemName: tab.rawValue)
                        .font(.title2)
                        .symbolEffect(.bounce.down.byLayer, value: animatedTab.isAnimating)
                    
                    Text(tab.title)
                        .font(.caption2)
                        .textScale(.secondary)
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(activeTab == tab ? Color.teal.opacity(0.8) : Color.gray)
                .padding(.top, 15)
                .padding(.bottom, 10)
                .contentShape(.rect)
                .onTapGesture {
                    withAnimation(.bouncy, completionCriteria: .logicallyComplete, {
                        activeTab = tab
                        animatedTab.isAnimating = true
                    }, completion: {
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            animatedTab.isAnimating = nil
                        }
                    })
                    
                }
            }
        }
        .background(.testBg)
    }
    
}

extension View {
    @ViewBuilder
    func setUpTab(_ tab: Tab) -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .tag(tab)
            .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    Home()
}
