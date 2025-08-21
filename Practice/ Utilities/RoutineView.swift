//
//  RoutineView.swift
//  Practice
//
//  Created by Hafizur Rahman on 21/8/25.
//

import SwiftUI

struct RoutineView: View {
    @Binding var isStudent: Bool
    @Binding var currentWeek: [Date.Day]
    @Binding var selectedDate: Date?
    @Binding var showAlert: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            ScrollView(.vertical) {
                LazyVStack(spacing: 15) {
                    ForEach(currentWeek) { day in
                        let date = day.date
                        let isLast = currentWeek.last?.id == day.id
                        
                        VStack(alignment: .leading, spacing: 15) {
                                // Section Header & Content grouped together
                            HStack(alignment: .center, spacing: 6) {
                                Text(date.string("EEEE"))
                                    .font(.largeTitle.bold())
                                    .foregroundStyle(.white.opacity(0.8))
                                
                                Text(date.string("dd"))
                                    .font(.largeTitle.bold())
                                    .foregroundStyle(.white.opacity(0.8))
                                
                                Spacer()
                                
                                Text("2 class")
                                    .font(.title3.bold())
                                    .foregroundStyle(.gray)
                            }
                            .frame(height: 70)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                                // Task Row content
                            VStack(alignment: .leading, spacing: 15) {
                                if isStudent {
                                    SClassCard(showAlert: $showAlert)
                                } else {
                                    TClassCard()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: isLast ? size.height - 100 : nil, alignment: .top)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.all, 20, for: .scrollContent)
            .contentMargins(.vertical, 20, for: .scrollIndicators)
            .scrollPosition(id: .init(get: {
                return currentWeek.first(where: { $0.date.isSame(selectedDate)})?.id
            }, set: { newValue in
                selectedDate = currentWeek.first(where: { $0.id == newValue})?.date
            }), anchor: .top)
        }
    }
}

#Preview {
    RoutineView(
        isStudent: .constant(false),
        currentWeek: .constant(Date.currentWeek),
        selectedDate: .constant(Date()),
        showAlert: .constant(false)
    )
}
