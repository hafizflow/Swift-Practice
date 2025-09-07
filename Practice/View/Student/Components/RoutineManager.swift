import SwiftUI
import SwiftData

    // MARK: - Routine Manager with Caching
@MainActor
class RoutineManager: ObservableObject {
    @Published var routines: [RoutineModel] = [] {
        didSet { invalidateCache() }
    }
    @Published var courses: [CourseModel] = [] {
        didSet { invalidateCache() }
    }
    @Published var teachers: [TeacherModel] = [] {
        didSet { invalidateCache() }
    }
    
    @Published var selectedSection: String = "" {
        didSet {
            if selectedSection != oldValue {
                invalidateCache()
            }
        }
    }
    
        // MARK: - Cached Properties
    private var _cachedFilteredRoutines: [String: [MergedRoutine]]?
    private var _cachedFilteredRoutinesWithDetails: [String: [FilteredRoutine]]?
    private var _cachedCourseStatistics: [CourseStatistic]?
    private var _cachedDailyClassCounts: [DayStatistic]?
    private var _cachedWeeklyHolidays: String?
    private var _cachedTotalCoursesEnrolled: Int?
    private var _cachedTotalWeeklyClasses: Int?
    private var _cachedTotalWeeklyHours: Double?
    private var _cachedTotalWeeklyClassTime: Double?
    
    private var lastCalculatedSection: String = ""
    
        // MARK: - Cache Management
    private func invalidateCache() {
        _cachedFilteredRoutines = nil
        _cachedFilteredRoutinesWithDetails = nil
        _cachedCourseStatistics = nil
        _cachedDailyClassCounts = nil
        _cachedWeeklyHolidays = nil
        _cachedTotalCoursesEnrolled = nil
        _cachedTotalWeeklyClasses = nil
        _cachedTotalWeeklyHours = nil
        _cachedTotalWeeklyClassTime = nil
        lastCalculatedSection = ""
    }
    
    private func shouldRecalculate() -> Bool {
        return lastCalculatedSection != selectedSection || _cachedFilteredRoutines == nil
    }
    
        // MARK: - Cached Computed Properties
    
        /// Total number of unique courses enrolled for the selected section
    var totalCoursesEnrolled: Int {
        if let cached = _cachedTotalCoursesEnrolled, !shouldRecalculate() {
            return cached
        }
        
        let trimmed = selectedSection.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let validSections = [trimmed, "\(trimmed)1", "\(trimmed)2"]
        
        let filtered = routines.filter { routine in
            guard let section = routine.section?.uppercased() else { return false }
            return validSections.contains(section)
        }
        
        let uniqueCourses = Set(filtered.compactMap { $0.courseCode })
        let result = uniqueCourses.count
        
        _cachedTotalCoursesEnrolled = result
        return result
    }
    
        /// Total weekly classes for the selected section
    var totalWeeklyClasses: Int {
        if let cached = _cachedTotalWeeklyClasses, !shouldRecalculate() {
            return cached
        }
        
        let filtered = filteredAndGroupedRoutines.values.flatMap { $0 }
        let result = filtered.count
        
        _cachedTotalWeeklyClasses = result
        return result
    }
    
        /// Total weekly class hours for the selected section
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
    
        /// Get course statistics
    var courseStatistics: [CourseStatistic] {
        if let cached = _cachedCourseStatistics, !shouldRecalculate() {
            return cached
        }
        
        let trimmed = selectedSection.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let validSections = [trimmed, "\(trimmed)1", "\(trimmed)2"]
        
        let filtered = routines.filter { routine in
            guard let section = routine.section?.uppercased() else { return false }
            return validSections.contains(section)
        }
        
        let grouped = Dictionary(grouping: filtered, by: { $0.courseCode ?? "Unknown" })
        
        let result = grouped.map { courseCode, routines in
            let totalClasses = routines.count
            let totalHours = routines.reduce(0.0) { total, routine in
                total + classDuration(startTime: routine.startTime, endTime: routine.endTime)
            }
            
            let courseTitle = course(for: courseCode)?.courseTitle
            let credits = course(for: courseCode)?.credits
            let teachers = Set(routines.compactMap { $0.teacher }).joined(separator: ", ")
            
            return CourseStatistic(
                courseCode: courseCode,
                courseTitle: courseTitle ?? "Unknown",
                courseCredits: credits ?? 0.0,
                totalClasses: totalClasses,
                totalHours: totalHours,
                teachers: teachers
            )
        }.sorted { $0.courseCode < $1.courseCode }
        
        _cachedCourseStatistics = result
        return result
    }
    
        /// Get daily class counts
    var dailyClassCounts: [DayStatistic] {
        if let cached = _cachedDailyClassCounts, !shouldRecalculate() {
            return cached
        }
        
        let dayOrder = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        
        let result: [DayStatistic] = dayOrder.compactMap { day -> DayStatistic? in
            guard let routines = filteredAndGroupedRoutines[day] else { return nil }
            
            let totalClasses = routines.count
            let totalHours = routines.reduce(0.0) { total, routine in
                total + classDuration(startTime: routine.startTime, endTime: routine.endTime)
            }
            
            return DayStatistic(
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
    
        /// Filtered, grouped, merged routines (cached)
    var filteredAndGroupedRoutines: [String: [MergedRoutine]] {
        if let cached = _cachedFilteredRoutines, !shouldRecalculate() {
            return cached
        }
        
        let result = calculateFilteredAndGroupedRoutines()
        _cachedFilteredRoutines = result
        lastCalculatedSection = selectedSection
        return result
    }
    
        /// Enriched routines (cached)
    var filteredRoutinesWithDetails: [String: [FilteredRoutine]] {
        if let cached = _cachedFilteredRoutinesWithDetails, !shouldRecalculate() {
            return cached
        }
        
        let result = calculateFilteredRoutinesWithDetails()
        _cachedFilteredRoutinesWithDetails = result
        return result
    }
    
        // MARK: - Calculation Methods (Private)
    
    private func calculateFilteredAndGroupedRoutines() -> [String: [MergedRoutine]] {
        let trimmed = selectedSection.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let validSections = [trimmed, "\(trimmed)1", "\(trimmed)2"]
        
        let filtered = routines.filter { routine in
            guard let section = routine.section?.uppercased() else { return false }
            return validSections.contains(section)
        }
        
        let grouped = Dictionary(grouping: filtered, by: { routine in
            let dayString = routine.day.trimmingCharacters(in: .whitespacesAndNewlines)
            return dayString.count >= 3 ? String(dayString.prefix(3)).uppercased() : dayString.uppercased()
        })
        
        var result: [String: [MergedRoutine]] = [:]
        
        for (day, routinesForDay) in grouped {
                // Group by courseCode + teacher only
            let groupedByClass = Dictionary(grouping: routinesForDay) { routine in
                ClassGroupKey(
                    courseCode: routine.courseCode ?? "Unknown",
                    teacher: routine.teacher ?? "Unknown"
                )
            }
            
            var mergedRoutines: [MergedRoutine] = []
            
            for (key, routinesOfSame) in groupedByClass {
                let courseCode = key.courseCode
                let teacher = key.teacher
                
                    // Sort routines by start time
                let sorted = routinesOfSame.sorted { $0.startTime < $1.startTime }
                
                let startTime = sorted.first?.startTime ?? "00:00"
                let endTime = sorted.last?.endTime ?? "00:00"
                let section = sorted.first?.section ?? ""
                let room = sorted.first?.room ?? "" // pick first room (since room is not part of the key)
                
                let merged = MergedRoutine(
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
    
    private func calculateFilteredRoutinesWithDetails() -> [String: [FilteredRoutine]] {
        var result: [String: [FilteredRoutine]] = [:]
        
        for (day, mergedRoutines) in filteredAndGroupedRoutines {
            var enriched: [FilteredRoutine] = []
            
            for routine in mergedRoutines {
                let courseTitle = course(for: routine.courseCode)?.courseTitle
                let courseCredits = course(for: routine.courseCode)?.credits
                let teacherModel = teacher(for: routine.teacher)
                
                let enrichedRoutine = FilteredRoutine(
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

    // MARK: - Supporting Structures (unchanged)

struct ClassGroupKey: Hashable {
    let courseCode: String
    let teacher: String
}

struct CourseStatistic: Identifiable {
    let id = UUID()
    let courseCode: String
    let courseTitle: String
    let courseCredits: Double
    let totalClasses: Int
    let totalHours: Double
    let teachers: String
}

struct DayStatistic: Identifiable {
    let id = UUID()
    let day: String
    let totalClasses: Int
    let totalHours: Double
}

struct MergedRoutine: Identifiable {
    let id = UUID()
    let courseCode: String
    let section: String
    let room: String
    let teacher: String
    let startTime: String
    let endTime: String
    let day: String
}

struct FilteredRoutine: Identifiable {
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

struct TContactInfo {
    var name: String
    var teacher: String
    var designation: String
    var phone: String
    var email: String
    var room: String
    var image: String
}
