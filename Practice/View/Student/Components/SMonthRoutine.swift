import SwiftUI

struct SMonthRoutine: View {
    @Binding var showMonthRoutineStudent: Bool
    
    @State private var currentMonth = Date()
    @State private var selectedDate: Date?
    
    @EnvironmentObject var routineManager: RoutineManager
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                    // Header
                HStack {
                    Text("Student Routine")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button {
                        showMonthRoutineStudent.toggle()
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
                        selectedDate: $selectedDate,
                        routineManager: routineManager
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
                
                    // Classes for selected date
                ScrollView {
                    if let selectedDate = selectedDate {
                        let dayKey = getDayKey(for: selectedDate)
                        let routines = routineManager.filteredRoutinesWithDetails[dayKey] ?? []
                        
                        if !routines.isEmpty {
                            VStack(spacing: 12) {
                                    // Date header
                                HStack {
                                    Text(selectedDate.string("EEEE, dd"))
                                        .font(.title3.bold())
                                        .foregroundStyle(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(routines.count) class\(routines.count != 1 ? "es" : "")")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                .padding(.bottom, 8)
                                
                                    // Class cards
                                ForEach(routines) { routine in
                                    MonthClassCard(routine: routine)
                                }
                            }
                        } else {
                                // No classes on this day
                            VStack(spacing: 12) {
                                Text(selectedDate.string("EEEE, dd"))
                                    .font(.title3.bold())
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom, 8)
                                
                                VStack(spacing: 8) {
                                    Text("No Classes")
                                        .font(.title3.bold())
                                        .foregroundStyle(.white.opacity(0.8))
                                    
                                    Text("Free day!")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 100)
                                .background(.gray.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    } else {
                            // No date selected
                        VStack {
                            Text("Select a Date")
                                .font(.title3.bold())
                                .foregroundStyle(.white.opacity(0.8))
                            
                            Text("Tap on a date to view classes")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                    }
                }
                .contentMargins(.all, 20, for: .scrollContent)
                .contentMargins(.vertical, 20, for: .scrollIndicators)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.mainBackground)
        }
        .navigationBarHidden(true)
        .onAppear {
                // Set initial selection to today if no date selected
            if selectedDate == nil {
                selectedDate = Date()
            }
        }
    }
    
        // Helper to get day key from date
    private func getDayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
        // Computed properties
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
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

struct CalendarGridView: View {
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date?
    let routineManager: RoutineManager
    
    private let calendar = Calendar.current
    
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
                        isPastDate: isPastDate(date),
                        hasClasses: hasClasses(on: date)
                    ) {
                            // Allow selection of all dates in current month or future dates
                        if calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) || date >= calendar.startOfDay(for: Date()) {
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
    
    private func hasClasses(on date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        let dayKey = formatter.string(from: date).uppercased()
        
        let routines = routineManager.filteredRoutinesWithDetails[dayKey] ?? []
        return !routines.isEmpty
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let isPastDate: Bool
    let hasClasses: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 16, weight: isToday ? .bold : .medium))
                    .foregroundStyle(textColor)
                    .frame(width: 40, height: 40)
                    .background(backgroundColor)
                    .clipShape(Circle())
                    .scaleEffect(isSelected ? 1.0 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0), value: isSelected)
                
                    // Teal circle indicator for days with classes
                if hasClasses && isCurrentMonth && !isSelected {
                    Circle()
                        .stroke(.teal.opacity(0.8), lineWidth: 1.5)
                        .frame(width: 40, height: 40)
                }
            }
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return .black
        } else if isPastDate {
            return .gray.opacity(0.5)
        } else if isToday {
            return .black
        } else if !isCurrentMonth {
            return .gray.opacity(0.5)
        } else {
            return .white.opacity(0.8)
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .teal.opacity(0.9)
        } else if isToday && !isSelected {
            return .gray.opacity(0.9)
        } else {
            return .clear
        }
    }
}

    // Compact class card for month view
struct MonthClassCard: View {
    let routine: FilteredRoutine
    
    var body: some View {
        HStack(spacing: 12) {
                // Time
            VStack(alignment: .leading, spacing: 2) {
                Text(routine.startTime)
                    .font(.caption.bold())
                    .foregroundStyle(.teal.opacity(0.9))
                Text(routine.endTime)
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
            .frame(width: 50, alignment: .leading)
            
                // Course info
            VStack(alignment: .leading, spacing: 4) {
                Text("\(routine.courseTitle)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(routine.courseCode)
                        .font(.caption2)
                        .foregroundStyle(.gray)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                    
                    Text(routine.teacher)
                        .font(.caption2)
                        .foregroundStyle(.gray)
                    
                    Spacer()
                    
                    Text(routine.room)
                        .font(.caption2)
                        .foregroundStyle(.gray)
                        .lineLimit(1)
                }
            }
        }
        .padding(12)
        .background(.gray.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
