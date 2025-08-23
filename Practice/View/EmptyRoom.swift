//
//  EmptyRoom.swift
//  Practice
//
//  Created by Hafizur Rahman on 24/8/25.
//

import SwiftUI

struct EmptyRoom: View {
        // View Properties
    @State private var currentWeek: [Date.Day] = Date.currentWeek
    @State private var selectedDate: Date?
        // For Matched Geometry Effect
    @Namespace private var namespace
    @State private var activeTab: StudentTab = .routine
    var offSetObserve = PageOffsetObserver()
    @Binding var showAlert: Bool
    @State private var isStudent: Bool = true
    
    var body: some View {
        VStack(alignment: .center, spacing: 0){
            HeaderView()
                .environment(\.colorScheme, .dark)
            
            TabView(selection: $activeTab) {
                RoutineView(isStudent: $isStudent, currentWeek: $currentWeek, selectedDate: $selectedDate, showAlert: $showAlert)
                    .onAppear {
                            // Setting up initial Selection Date
                        guard selectedDate == nil else { return }
                            // Today's Data
                        selectedDate = currentWeek.first(where: { $0.date.isSame(.now)})?.date
                    }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .background(.testBg)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 30, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 30, style: .continuous))
                //            .ignoresSafeArea(.container, edges: .bottom)
        }
        .background(.mainBackground)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("EmptyRoom")
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
                Text(selectedDate?.string("YYY") ?? "")
            }
            .font(.caption2)
            
        }
        .padding([.horizontal, .top], 15)
        .padding(.bottom, 10)
    }
}

#Preview {
    EmptyRoom(showAlert: .constant(false))
}
