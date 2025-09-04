import SwiftUI
import SwiftData

    // MARK: - Routine Manager
@MainActor
class RoutineManager: ObservableObject {
    @Published var routines: [RoutineModel] = []
    @Published var courses: [CourseModel] = []
    @Published var teachers: [TeacherModel] = []
    
    @Published var selectedSection: String = ""
    
        // MARK: - Calculations
    
        /// Total number of unique courses enrolled for the selected section
    var totalCoursesEnrolled: Int {
        let trimmed = selectedSection.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let validSections = [trimmed, "\(trimmed)1", "\(trimmed)2"]
        
        let filtered = routines.filter { routine in
            guard let section = routine.section?.uppercased() else { return false }
            return validSections.contains(section)
        }
        
        let uniqueCourses = Set(filtered.compactMap { $0.courseCode })
        return uniqueCourses.count
    }
    
        /// Total weekly classes for the selected section
    var totalWeeklyClasses: Int {
        let filtered = filteredAndGroupedRoutines.values.flatMap { $0 }
        return filtered.count
    }
    
        /// Total weekly class hours for the selected section
    var totalWeeklyHours: Double {
        let filtered = filteredAndGroupedRoutines.values.flatMap { $0 }
        return filtered.reduce(0.0) { total, routine in
            total + classDuration(startTime: routine.startTime, endTime: routine.endTime)
        }
    }
    
        /// Total weekly class time in hours, only counting days with classes
    var totalWeeklyClassTime: Double {
        let activeDays = dailyClassCounts.filter { $0.totalClasses > 0 }
        return activeDays.reduce(0.0) { $0 + $1.totalHours }
    }
    
        /// Get course statistics
    var courseStatistics: [CourseStatistic] {
        let trimmed = selectedSection.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let validSections = [trimmed, "\(trimmed)1", "\(trimmed)2"]
        
        let filtered = routines.filter { routine in
            guard let section = routine.section?.uppercased() else { return false }
            return validSections.contains(section)
        }
        
        let grouped = Dictionary(grouping: filtered, by: { $0.courseCode ?? "Unknown" })
        
        return grouped.map { courseCode, routines in
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
    }
    
        /// Get daily class counts
    var dailyClassCounts: [DayStatistic] {
        let dayOrder = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        
        return dayOrder.compactMap { day in
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
    }
    
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
    
        /// Get weekly holiday days (days without classes) as formatted string
    var weeklyHolidays: String {
        let allDays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        let activeDays = Set(filteredAndGroupedRoutines.keys.filter { day in
            if let routines = filteredAndGroupedRoutines[day] {
                return !routines.isEmpty
            }
            return false
        })
        
        let holidayDays = allDays.filter { !activeDays.contains($0) }
        
        return holidayDays.isEmpty ? "No Holidays" : holidayDays.joined(separator: ", ")
    }
    
        // MARK: - Filtered, grouped, merged routines (unchanged)
    var filteredAndGroupedRoutines: [String: [MergedRoutine]] {
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
        
        let timeOrder = ["08:30", "10:00", "11:30", "01:00", "02:30", "04:00"]
        var result: [String: [MergedRoutine]] = [:]
        
        for (day, routinesForDay) in grouped {
            let sorted = routinesForDay.sorted { first, second in
                let start1 = first.startTime
                let start2 = second.startTime
                return (timeOrder.firstIndex(of: start1) ?? Int.max) < (timeOrder.firstIndex(of: start2) ?? Int.max)
            }
            
            var mergedRoutines: [MergedRoutine] = []
            var current: MergedRoutine?
            
            for routine in sorted {
                let newRoutine = MergedRoutine(
                    courseCode: routine.courseCode ?? "Unknown",
                    section: routine.section ?? "",
                    room: routine.room,
                    teacher: routine.teacher ?? "Unknown",
                    startTime: routine.startTime,
                    endTime: routine.endTime,
                    day: routine.day
                )
                
                if let ongoing = current {
                    if ongoing.courseCode == newRoutine.courseCode &&
                        ongoing.room == newRoutine.room &&
                        ongoing.teacher == newRoutine.teacher &&
                        ongoing.endTime == newRoutine.startTime {
                        current = MergedRoutine(
                            courseCode: ongoing.courseCode,
                            section: ongoing.section,
                            room: ongoing.room,
                            teacher: ongoing.teacher,
                            startTime: ongoing.startTime,
                            endTime: newRoutine.endTime,
                            day: ongoing.day
                        )
                    } else {
                        mergedRoutines.append(ongoing)
                        current = newRoutine
                    }
                } else {
                    current = newRoutine
                }
            }
            
            if let ongoing = current {
                mergedRoutines.append(ongoing)
            }
            
            result[day] = mergedRoutines
        }
        
        return result
    }
    
        // MARK: - Enriched routines (unchanged)
    var filteredRoutinesWithDetails: [String: [FilteredRoutine]] {
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
                    teacherImage: teacherModel?.imageUrl ?? ""
                )
                
                enriched.append(enrichedRoutine)
            }
            
            result[day] = enriched
        }
        
        return result
    }
    
        // MARK: - Helpers
    func course(for code: String?) -> CourseModel? {
        guard let code = code, !code.isEmpty else { return nil }
        return courses.first { $0.courseCode?.uppercased() == code.uppercased() }
    }
    
    func teacher(for code: String?) -> TeacherModel? {
        guard let code = code, !code.isEmpty else { return nil }
        return teachers.first { $0.teacher?.uppercased() == code.uppercased() }
    }
}

    // MARK: - Statistics Models
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

    // MARK: - Routine Models
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
}
