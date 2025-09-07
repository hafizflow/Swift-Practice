import SwiftUI
import SwiftData

    // MARK: - Teacher Manager with Caching
@MainActor
class TeacherManager: ObservableObject {
    @Published var routines: [RoutineModel] = [] {
        didSet { invalidateCache() }
    }
    @Published var courses: [CourseModel] = [] {
        didSet { invalidateCache() }
    }
    @Published var teachers: [TeacherModel] = [] {
        didSet { invalidateCache() }
    }
    
    @Published var selectedTeacher: String = "" {
        didSet {
            if selectedTeacher != oldValue {
                invalidateCache()
            }
        }
    }
    
        // MARK: - Cached Properties
    private var _cachedFilteredRoutines: [String: [TMergedRoutine]]?
    private var _cachedFilteredRoutinesWithDetails: [String: [TFilteredRoutine]]?
    private var _cachedCourseStatistics: [TCourseStatistic]?
    private var _cachedDailyClassCounts: [TDayStatistic]?
    private var _cachedWeeklyHolidays: String?
    private var _cachedTotalCoursesProvided: Int?
    private var _cachedTotalWeeklyClasses: Int?
    private var _cachedTotalWeeklyHours: Double?
    private var _cachedTotalWeeklyClassTime: Double?
    
    private var lastCalculatedTeacher: String = ""
    
        // MARK: - Cache Management
    private func invalidateCache() {
        _cachedFilteredRoutines = nil
        _cachedFilteredRoutinesWithDetails = nil
        _cachedCourseStatistics = nil
        _cachedDailyClassCounts = nil
        _cachedWeeklyHolidays = nil
        _cachedTotalCoursesProvided = nil
        _cachedTotalWeeklyClasses = nil
        _cachedTotalWeeklyHours = nil
        _cachedTotalWeeklyClassTime = nil
        lastCalculatedTeacher = ""
    }
    
    private func shouldRecalculate() -> Bool {
        return lastCalculatedTeacher != selectedTeacher || _cachedFilteredRoutines == nil
    }
    
        // MARK: - Cached Computed Properties
    
        /// Total number of unique courses provided by the selected teacher
    var totalCoursesProvided: Int {
        if let cached = _cachedTotalCoursesProvided, !shouldRecalculate() {
            return cached
        }
        
        let trimmed = selectedTeacher.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        let filtered = routines.filter { routine in
            guard let teacher = routine.teacher?.uppercased() else { return false }
            return teacher == trimmed
        }
        
        let uniqueCourses = Set(filtered.compactMap { $0.courseCode })
        let result = uniqueCourses.count
        
        _cachedTotalCoursesProvided = result
        return result
    }
    
        /// Total weekly classes for the selected teacher
    var totalWeeklyClasses: Int {
        if let cached = _cachedTotalWeeklyClasses, !shouldRecalculate() {
            return cached
        }
        
        let filtered = filteredAndGroupedRoutines.values.flatMap { $0 }
        let result = filtered.count
        
        _cachedTotalWeeklyClasses = result
        return result
    }
    
        /// Total weekly class hours for the selected teacher
    var totalWeeklyHours: Double {
        if let cached = _cachedTotalWeeklyHours, !shouldRecalculate() {
            return cached
        }
        
        let filtered = filteredAndGroupedRoutines.values.flatMap { $0 }
        let result = filtered.reduce(0.0) { total, routine in
            total + classDuration(startTime: routine.startTime, endTime: routine.endTime)
        }
        
        _cachedTotalWeeklyHours = result
        return result
    }
    
        /// Total weekly class time in hours, only counting days with classes
    var totalWeeklyClassTime: Double {
        if let cached = _cachedTotalWeeklyClassTime, !shouldRecalculate() {
            return cached
        }
        
        let activeDays = dailyClassCounts.filter { $0.totalClasses > 0 }
        let result = activeDays.reduce(0.0) { $0 + $1.totalHours }
        
        _cachedTotalWeeklyClassTime = result
        return result
    }
    
        /// Get course statistics for the teacher
    var courseStatistics: [TCourseStatistic] {
        if let cached = _cachedCourseStatistics, !shouldRecalculate() {
            return cached
        }
        
        let trimmed = selectedTeacher.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        let filtered = routines.filter { routine in
            guard let teacher = routine.teacher?.uppercased() else { return false }
            return teacher == trimmed
        }
        
        let grouped = Dictionary(grouping: filtered, by: { $0.courseCode ?? "Unknown" })
        
        let result = grouped.map { courseCode, routines in
            let totalClasses = routines.count
            let totalHours = routines.reduce(0.0) { total, routine in
                total + classDuration(startTime: routine.startTime, endTime: routine.endTime)
            }
            
            let courseTitle = course(for: courseCode)?.courseTitle
            let credits = course(for: courseCode)?.credits
            let sections = Set(routines.compactMap { $0.section }).joined(separator: ", ")
            
            return TCourseStatistic(
                courseCode: courseCode,
                courseTitle: courseTitle ?? "Unknown",
                courseCredits: credits ?? 0.0,
                totalClasses: totalClasses,
                totalHours: totalHours,
                sections: sections
            )
        }.sorted { $0.courseCode < $1.courseCode }
        
        _cachedCourseStatistics = result
        return result
    }
    
        /// Get daily class counts for the teacher
    var dailyClassCounts: [TDayStatistic] {
        if let cached = _cachedDailyClassCounts, !shouldRecalculate() {
            return cached
        }
        
        let dayOrder = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        
        let result: [TDayStatistic] = dayOrder.compactMap { day -> TDayStatistic? in
            guard let routines = filteredAndGroupedRoutines[day] else { return nil }
            
            let totalClasses = routines.count
            let totalHours = routines.reduce(0.0) { total, routine in
                total + classDuration(startTime: routine.startTime, endTime: routine.endTime)
            }
            
            return TDayStatistic(
                day: day,
                totalClasses: totalClasses,
                totalHours: totalHours
            )
        }
        
        _cachedDailyClassCounts = result
        return result
    }
    
        /// Get weekly holiday days (days without classes) as formatted string
    var weeklyHolidays: String {
        if let cached = _cachedWeeklyHolidays, !shouldRecalculate() {
            return cached
        }
        
        let allDays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        let activeDays = Set(filteredAndGroupedRoutines.keys.filter { day in
            if let routines = filteredAndGroupedRoutines[day] {
                return !routines.isEmpty
            }
            return false
        })
        
        let holidayDays = allDays.filter { !activeDays.contains($0) }
        let result = holidayDays.isEmpty ? "No Holidays" : holidayDays.joined(separator: ", ")
        
        _cachedWeeklyHolidays = result
        return result
    }
    
        // MARK: - Cached Main Data Properties
    
        /// Filtered, grouped, merged routines (cached) - for teacher
    var filteredAndGroupedRoutines: [String: [TMergedRoutine]] {
        if let cached = _cachedFilteredRoutines, !shouldRecalculate() {
            return cached
        }
        
        let result = calculateFilteredAndGroupedRoutines()
        _cachedFilteredRoutines = result
        lastCalculatedTeacher = selectedTeacher
        return result
    }
    
        /// Enriched routines (cached) - for teacher
    var filteredRoutinesWithDetails: [String: [TFilteredRoutine]] {
        if let cached = _cachedFilteredRoutinesWithDetails, !shouldRecalculate() {
            return cached
        }
        
        let result = calculateFilteredRoutinesWithDetails()
        _cachedFilteredRoutinesWithDetails = result
        return result
    }
    
        // MARK: - Calculation Methods (Private)
    
    private func calculateFilteredAndGroupedRoutines() -> [String: [TMergedRoutine]] {
        let trimmed = selectedTeacher.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        let filtered = routines.filter { routine in
            guard let teacher = routine.teacher?.uppercased() else { return false }
            return teacher == trimmed
        }
        
        let grouped = Dictionary(grouping: filtered, by: { routine in
            let dayString = routine.day.trimmingCharacters(in: .whitespacesAndNewlines)
            return dayString.count >= 3 ? String(dayString.prefix(3)).uppercased() : dayString.uppercased()
        })
        
        var result: [String: [TMergedRoutine]] = [:]
        
        for (day, routinesForDay) in grouped {
                // Group by courseCode + section only (since we're filtering by teacher already)
            let groupedByClass = Dictionary(grouping: routinesForDay) { routine in
                TClassGroupKey(
                    courseCode: routine.courseCode ?? "Unknown",
                    section: routine.section ?? "Unknown"
                )
            }
            
            var mergedRoutines: [TMergedRoutine] = []
            
            for (key, routinesOfSame) in groupedByClass {
                let courseCode = key.courseCode
                let section = key.section
                
                    // Sort routines by start time
                let sorted = routinesOfSame.sorted { $0.startTime < $1.startTime }
                
                let startTime = sorted.first?.startTime ?? "00:00"
                let endTime = sorted.last?.endTime ?? "00:00"
                let teacher = sorted.first?.teacher ?? ""
                let room = sorted.first?.room ?? "" // pick first room
                
                let merged = TMergedRoutine(
                    courseCode: courseCode,
                    section: section,
                    room: room,
                    teacher: teacher,
                    startTime: startTime,
                    endTime: endTime,
                    day: day
                )
                mergedRoutines.append(merged)
            }
            
                // Sort by your predefined time order
            let timeOrder = ["08:30", "10:00", "11:30", "01:00", "02:30", "04:00"]
            mergedRoutines.sort { first, second in
                (timeOrder.firstIndex(of: first.startTime) ?? Int.max) <
                    (timeOrder.firstIndex(of: second.startTime) ?? Int.max)
            }
            
            result[day] = mergedRoutines
        }
        
        return result
    }
    
    private func calculateFilteredRoutinesWithDetails() -> [String: [TFilteredRoutine]] {
        var result: [String: [TFilteredRoutine]] = [:]
        
        for (day, mergedRoutines) in filteredAndGroupedRoutines {
            var enriched: [TFilteredRoutine] = []
            
            for routine in mergedRoutines {
                let courseTitle = course(for: routine.courseCode)?.courseTitle
                let courseCredits = course(for: routine.courseCode)?.credits
                let teacherModel = teacher(for: routine.teacher)
                
                let enrichedRoutine = TFilteredRoutine(
                    courseCode: routine.courseCode,
                    room: routine.room,
                    teacher: routine.teacher,
                    startTime: routine.startTime,
                    endTime: routine.endTime,
                    section: routine.section,
                    day: routine.day,
                    courseTitle: courseTitle ?? "Unknown",
                    courseCredits: courseCredits ?? 0.0,
                    teacherName: teacherModel?.name ?? "Unknown",
                    teacherCell: teacherModel?.cellPhone ?? "N/A",
                    teacherEmail: teacherModel?.email ?? "N/A",
                    teacherDesignation: teacherModel?.designation ?? "N/A",
                    teacherImage: teacherModel?.imageUrl ?? "",
                    teacherRoom: "Unknown"
                )
                
                enriched.append(enrichedRoutine)
            }
            
            result[day] = enriched
        }
        
        return result
    }
    
        // MARK: - Helper Methods
    
        /// Calculate class duration in hours - handles ambiguous 12-hour format
    private func classDuration(startTime: String, endTime: String) -> Double {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard
            let start = formatter.date(from: startTime),
            let end = formatter.date(from: endTime)
        else {
            return 1.5 // fallback if parsing fails
        }
        
        let startHour = Calendar.current.component(.hour, from: start)
        let startMinute = Calendar.current.component(.minute, from: start)
        let endHour = Calendar.current.component(.hour, from: end)
        let endMinute = Calendar.current.component(.minute, from: end)
        
            // Adjust ambiguous times (01:00–07:00 treated as PM, unless 00:00)
        let adjustedStartHour = startHour <= 7 && startHour != 0 ? startHour + 12 : startHour
        let adjustedEndHour = endHour <= 7 && endHour != 0 ? endHour + 12 : endHour
        
        let startTotalMinutes = adjustedStartHour * 60 + startMinute
        let endTotalMinutes = adjustedEndHour * 60 + endMinute
        
        var diff = endTotalMinutes - startTotalMinutes
        if diff < 0 { diff += 24 * 60 } // handle past-midnight
        
        return Double(diff) / 60.0
    }
    
    func course(for code: String?) -> CourseModel? {
        guard let code = code, !code.isEmpty else { return nil }
        return courses.first { $0.courseCode?.uppercased() == code.uppercased() }
    }
    
    func teacher(for code: String?) -> TeacherModel? {
        guard let code = code, !code.isEmpty else { return nil }
        return teachers.first { $0.teacher?.uppercased() == code.uppercased() }
    }
    
        // MARK: - Manual Cache Refresh
        /// Call this method if you need to force refresh calculations
    func refreshCalculations() {
        invalidateCache()
    }
}

    // MARK: - Supporting Structures for Teacher

struct TClassGroupKey: Hashable {
    let courseCode: String
    let section: String
}

struct TCourseStatistic: Identifiable {
    let id = UUID()
    let courseCode: String
    let courseTitle: String
    let courseCredits: Double
    let totalClasses: Int
    let totalHours: Double
    let sections: String // Different from student - shows sections taught
}

struct TDayStatistic: Identifiable {
    let id = UUID()
    let day: String
    let totalClasses: Int
    let totalHours: Double
}

struct TMergedRoutine: Identifiable {
    let id = UUID()
    let courseCode: String
    let section: String
    let room: String
    let teacher: String
    let startTime: String
    let endTime: String
    let day: String
}

struct TFilteredRoutine: Identifiable {
    let id = UUID()
    let courseCode: String
    let room: String
    let teacher: String
    let startTime: String
    let endTime: String
    let section: String
    let day: String
    let courseTitle: String
    let courseCredits: Double
    let teacherName: String
    let teacherCell: String
    let teacherEmail: String
    let teacherDesignation: String
    let teacherImage: String
    let teacherRoom: String
}

    // Extension for TFilteredRoutine duration calculation
extension TFilteredRoutine {
    var duration: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard
            let start = formatter.date(from: startTime),
            let end = formatter.date(from: endTime)
        else { return "" }
        
        let startHour = Calendar.current.component(.hour, from: start)
        let startMinute = Calendar.current.component(.minute, from: start)
        let endHour = Calendar.current.component(.hour, from: end)
        let endMinute = Calendar.current.component(.minute, from: end)
        
            // Convert to 12-hour format logic
        let adjustedStartHour = startHour <= 7 && startHour != 0 ? startHour + 12 : startHour
        let adjustedEndHour = endHour <= 7 && endHour != 0 ? endHour + 12 : endHour
        
        let startTotalMinutes = adjustedStartHour * 60 + startMinute
        let endTotalMinutes = adjustedEndHour * 60 + endMinute
        
        var diff = endTotalMinutes - startTotalMinutes
        
        if diff < 0 {
            diff += 24 * 60
        }
        
        let hours = diff / 60
        let mins = diff % 60
        
        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }
}
