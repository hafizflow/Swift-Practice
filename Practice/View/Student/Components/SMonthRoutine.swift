import SwiftUI

struct SMonthRoutine: View {
    @Binding var showMonthRoutine: Bool
    
    @State private var currentMonth = Date()
    @State private var selectedDate: Date?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                    // Header
                HStack {
                    Text("Routine")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button {
                        showMonthRoutine.toggle()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.8))
                            .frame(width: 32, height: 32)
                    }
                }
                .padding(.top, 15)
                .padding(.bottom, 30)
                
                    // Calendar Section
                VStack(spacing: 0) {
                        // Month Navigation
                    HStack {
                            // Back to current month button
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title3.bold())
                                .foregroundStyle(.white.opacity(0.8))
                                .frame(width: 32, height: 32)
                        }
                        .disabled(isCurrentMonth)
                        .opacity(isCurrentMonth ? 0.3 : 1.0)
                        
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
                                .font(.title3.bold())
                                .foregroundStyle(.white.opacity(0.8))
                                .frame(width: 32, height: 32)
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom, 15)
                    
                        // Calendar Grid
                    CalendarGridView(
                        currentMonth: $currentMonth,
                        selectedDate: $selectedDate
                    )
                }
                .padding(.bottom, 20)
                
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
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.mainBackground)
        }
        .navigationBarHidden(true)
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

struct CalendarGridView: View {
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date?
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // Weekday headers
            ForEach(weekdayHeaders, id: \.self) { weekday in
                Text(weekday)
                    .font(.caption.bold())
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
            }
            
                // Calendar days
            ForEach(calendarDays, id: \.self) { date in
                if let date = date {
                    CalendarDayView(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate ?? Date.distantPast),
                        isToday: calendar.isDate(date, inSameDayAs: Date()),
                        isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                        isPastDate: date < calendar.startOfDay(for: Date())
                    ) {
                        if !isPastDate(date) {
                            selectedDate = date
                        }
                    }
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 40)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentMonth)
    }
    
    private var weekdayHeaders: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols
    }
    
    private var calendarDays: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.end)
        else { return [] }
        
        var days: [Date?] = []
        var date = monthFirstWeek.start
        
        while date < monthLastWeek.end {
            days.append(date)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
        }
        
        return days
    }
    
    private func isPastDate(_ date: Date) -> Bool {
        date < calendar.startOfDay(for: Date())
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let isPastDate: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 16, weight: isToday ? .bold : .medium))
                .foregroundStyle(textColor)
                .frame(width: 40, height: 40)
                .background(backgroundColor)
                .clipShape(Circle())
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .disabled(isPastDate)
    }
    
    private var textColor: Color {
        if isPastDate {
            return .gray.opacity(0.3)
        } else if isSelected {
            return .black
        } else if isToday {
            return .white
        } else if !isCurrentMonth {
            return .gray.opacity(0.5)
        } else {
            return .white.opacity(0.8)
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .white.opacity(0.9)
        } else if isToday && !isSelected {
            return .blue.opacity(0.3)
        } else {
            return .clear
        }
    }
}

#Preview {
    SMonthRoutine(showMonthRoutine: .constant(true))
}
