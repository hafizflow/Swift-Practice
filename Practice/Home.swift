//
//  Home.swift
//  Practice
//
//  Created by Hafizur Rahman on 15/8/25.
//

import SwiftUI

struct Home: View {
    @State private var activeTab: Tab = .student
    
    @State private var allTabs: [AnimatedTab] = Tab.allCases.compactMap { tab ->
        AnimatedTab? in
        return .init(tab: tab)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $activeTab) {
                
                NavigationStack {
                    VStack {
                        Student()
                    }
                }
                .setUpTab(.student)
                .overlay(alignment: .bottomTrailing) {
                    ExpandableSearchBar()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 5)
                }
                
                NavigationStack {
                    VStack {
                        
                    }
                    .navigationTitle(Tab.teacher.title)
                }
                .setUpTab(.teacher)
    
                
                NavigationStack {
                    VStack {
                        
                    }
                    .navigationTitle(Tab.emptyRoom.title)
                }
                .setUpTab(.emptyRoom)
                
                NavigationStack {
                    VStack {
                        
                    }
                    .navigationTitle(Tab.examRoutine.title)
                }
                .setUpTab(.examRoutine)
                
            }
            
            CustomTabBar()
        }
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

