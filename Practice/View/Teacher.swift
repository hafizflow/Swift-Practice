//
//  Teacher.swift
//  Practice
//
//  Created by Hafizur Rahman on 21/8/25.
//

import SwiftUI


struct Teacher: View {
        // View Properties
    @State private var currentWeek: [Date.Day] = Date.currentWeek
    @State private var isStudent: Bool = false
    @State private var selectedDate: Date?
        // For Matched Geometry Effect
    @Namespace private var namespace
    @State private var activeTab: TeacherTab = .routine
    var offSetObserve = PageOffsetObserver()
    @State private var showAlert: Bool = false
    
    
    var body: some View {
        VStack(alignment: .center, spacing: 0){
            HeaderView()
                .environment(\.colorScheme, .dark)
            
            TabView(selection: $activeTab) {
                
                RoutineView(isStudent: $isStudent,currentWeek: $currentWeek, selectedDate: $selectedDate, showAlert: $showAlert)
                .onAppear {
                        // Setting up initial Selection Date
                    guard selectedDate == nil else { return }
                        // Today's Data
                    selectedDate = currentWeek.first(where: { $0.date.isSame(.now)})?.date
                }
                .tag(TeacherTab.routine)
                
                
                ScrollView(.vertical) {
                    InsightCard().padding(15)
                }
                .tag(TeacherTab.insights)
                
                
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .background(.testBg)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 30, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 30, style: .continuous))
            .ignoresSafeArea(.all, edges: .bottom)
            
        }
        .background(.mainBackground)
        
    }
    
    @ViewBuilder
    func Tabbar(_ tint: Color, _ weight: Font.Weight = .regular, activeTab: Binding<TeacherTab>) -> some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                ForEach(TeacherTab.allCases, id: \.rawValue) { tab in
                    Text(tab.rawValue)
                        .font(.system(size: 14))
                        .fontWeight(weight)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .contentShape(.rect)
                        .onTapGesture {
                            withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                                activeTab.wrappedValue = tab
                            }
                        }
                }
            }
            
                // Underline for the active tab
            GeometryReader { geometry in
                let tabWidth = geometry.size.width / CGFloat(TeacherTab.allCases.count)
                let offsetX = CGFloat(activeTab.wrappedValue.index) * tabWidth
                
                Rectangle()
                    .cornerRadius(30)
                    .frame(height: 3)
                    .foregroundColor(tint)
                    .offset(x: offsetX)
                    .frame(width: tabWidth)
                    .animation(.snappy(duration: 0.3, extraBounce: 0), value: activeTab.wrappedValue)
            }
        }
    }
    
    
    
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Teacher")
                    .font(.title.bold())
                    .opacity(0.8)
                
                Spacer(minLength: 0)
                
                Button {
                } label: {
                    Image(.setting)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(.white)
                        .opacity(0.8)
                }
            }
            
                // Week View
            HStack(spacing: 0) {
                ForEach(currentWeek) { day in
                    let date = day.date
                    let isSameDate = date.isSame(selectedDate)
                    
                    VStack(spacing: 6) {
                        Text(date.string("EEE"))
                            .font(.caption)
                            .opacity(0.9)
                        
                        Text(date.string("dd"))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(isSameDate ? .black : .white)
                            .frame(width: 38, height: 38)
                            .opacity(0.8)
                            .background {
                                if isSameDate {
                                    Circle()
                                        .fill(.white)
                                        .matchedGeometryEffect(id: "ACTIVEDATE", in: namespace)
                                }
                            }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                            selectedDate = date
                        }
                    }
                }
                
            }
            .animation(.snappy(duration: 0.25, extraBounce: 0), value: selectedDate)
            .frame(height: 80)
            .padding(.vertical, 5)
            .offset(y: 5)
            
            HStack (alignment: .center) {
                Text(selectedDate?.string("MMM") ?? "")
                
                Spacer()
                
                Tabbar(.gray, .semibold, activeTab: $activeTab)
                    .frame(maxHeight: 24)
                    .padding(.horizontal, 40)
                    .foregroundStyle(.white.opacity(0.9))
                
                Spacer()
                
                Text(selectedDate?.string("YYY") ?? "")
            }
            .font(.caption2)
            
        }
        .padding([.horizontal, .top], 15)
        .padding(.bottom, 10)
    }
}


#Preview {
    Teacher()
}


