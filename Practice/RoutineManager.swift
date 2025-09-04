import SwiftUI
import SwiftData

    // MARK: - Routine Manager
@MainActor
class RoutineManager: ObservableObject {
    @Published var routines: [RoutineModel] = []
    @Published var courses: [CourseModel] = []
    @Published var teachers: [TeacherModel] = []
    
    @Published var selectedSection: String = ""
    
        // MARK: - Filtered, grouped, merged routines
    var filteredAndGroupedRoutines: [String: [MergedRoutine]] {
        let trimmed = selectedSection.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let validSections = [trimmed, "\(trimmed)1", "\(trimmed)2"]
        
        let filtered = routines.filter { routine in
            guard let section = routine.section?.uppercased() else { return false }
            return validSections.contains(section)
        }
        
            // More robust day extraction - handle various day formats
        let grouped = Dictionary(grouping: filtered, by: { routine in
            let dayString = routine.day.trimmingCharacters(in: .whitespacesAndNewlines)
            
                // Handle different day formats
            if dayString.count >= 3 {
                return String(dayString.prefix(3)).uppercased()
            } else {
                return dayString.uppercased()
            }
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
                        ongoing.endTime == newRoutine.startTime { // Check if times are consecutive
                        
                            // Merge same consecutive course sessions
                        current = MergedRoutine(
                            courseCode: ongoing.courseCode,
                            section: ongoing.section,
                            room: ongoing.room,
                            teacher: ongoing.teacher,
                            startTime: ongoing.startTime, // Keep original start time
                            endTime: newRoutine.endTime,   // Update to new end time
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
    
        // MARK: - Enriched routines with course & teacher info
    var filteredRoutinesWithDetails: [String: [FilteredRoutine]] {
        var result: [String: [FilteredRoutine]] = [:]
        
        for (day, mergedRoutines) in filteredAndGroupedRoutines {
            var enriched: [FilteredRoutine] = []
            
            for routine in mergedRoutines {
                let courseTitle = courseTitle(for: routine.courseCode)
                let teacherModel = teacher(for: routine.teacher)
                
                let enrichedRoutine = FilteredRoutine(
                    courseCode: routine.courseCode,
                    room: routine.room,
                    teacher: routine.teacher,
                    startTime: routine.startTime,
                    endTime: routine.endTime,
                    section: routine.section,
                    day: routine.day,
                    courseTitle: courseTitle,
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
    func courseTitle(for code: String?) -> String {
        guard let code = code else { return "Unknown" }
        return courses.first { $0.courseCode?.uppercased() == code.uppercased() }?.courseTitle ?? "Unknown"
    }
    
    func teacher(for code: String?) -> TeacherModel? {
        guard let code = code, !code.isEmpty else { return nil }
        return teachers.first { $0.teacher?.uppercased() == code.uppercased() }
    }
}

    // MARK: - Data Models
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
    let teacherName: String
    let teacherCell: String
    let teacherEmail: String
    let teacherDesignation: String
    let teacherImage: String
}
