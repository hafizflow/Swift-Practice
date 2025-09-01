import SwiftUI

struct TMonthRoutine: View {
    @Binding var showMonthRoutineFaculty: Bool
    
    @State private var currentMonth = Date()
    @State private var selectedDate: Date?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                    // Header
                HStack {
                    Text("Faculty Routine")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button {
                        showMonthRoutineFaculty.toggle()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.8))
                            .frame(width: 32, height: 32)
                    }
                }
                .padding(.top, 15)
                .padding(.bottom, 30)
                .padding(.horizontal, 20)
                
                    // Calendar Section
                VStack(spacing: 0) {
                        // Month Navigation
                    HStack {
                            // Back to previous month button
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.8))
                                .frame(width: 32, height: 32)
                        }
                        .disabled(isPastLimit)
                        .opacity(isPastLimit ? 0.3 : 1.0)
                        
                        Spacer()
                        
                        Text(monthYearString(from: currentMonth))
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                            // Forward to next month button
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.8))
                                .frame(width: 32, height: 32)
                        }
                        .disabled(isFutureLimit)
                        .opacity(isFutureLimit ? 0.3 : 1.0)
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom, 15)
                    
                        // Calendar Grid with Swipe Gestures
                    CalendarGridView(
                        currentMonth: $currentMonth,
                        selectedDate: $selectedDate
                    )
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                let swipeThreshold: CGFloat = 50
                                let horizontalDistance = value.translation.width
                                let verticalDistance = abs(value.translation.height)
                                
                                    // Only process horizontal swipes (not vertical)
                                if abs(horizontalDistance) > swipeThreshold && abs(horizontalDistance) > verticalDistance {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        if horizontalDistance > 0 {
                                                // Swipe right - go to previous month
                                            if !isPastLimit {
                                                currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                                            }
                                        } else {
                                                // Swipe left - go to next month
                                            if !isFutureLimit {
                                                currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                                            }
                                        }
                                    }
                                }
                            }
                    )
                }
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
                
                ScrollView {
                        // CLASS CARD
                    VStack {
                        ForEach(0..<5, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.gray.opacity(0.2))
                                .frame(height: 80)
                                .padding(.horizontal, 4)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .contentMargins(.all, 20, for: .scrollContent)
                .contentMargins(.vertical, 20, for: .scrollIndicators)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.mainBackground)
        }
        .navigationBarHidden(true)
    }
    
    
    // Computed properties to your view:
    private var isPastLimit: Bool {
        let fourMonthsAgo = Calendar.current.date(byAdding: .month, value: -4, to: Date()) ?? Date()
        return currentMonth <= fourMonthsAgo
    }
    
    private var isFutureLimit: Bool {
        let fourMonthsFromNow = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
        return currentMonth >= fourMonthsFromNow
    }
    
    private var isCurrentMonth: Bool {
        Calendar.current.isDate(currentMonth, equalTo: Date(), toGranularity: .month)
    }
    
    private var canGoToPreviousMonth: Bool {
        !isCurrentMonth
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    TMonthRoutine(showMonthRoutineFaculty: .constant(true))
}
