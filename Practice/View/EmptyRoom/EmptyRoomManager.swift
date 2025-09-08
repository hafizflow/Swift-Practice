import SwiftUI
import SwiftData

@MainActor
class EmptyRoomManager: ObservableObject {
    @Published var selectedTimeSlot: String = "08:30"
    
    let timeSlotsForPicker: [String] = ["08:30", "10:00", "11:30", "01:00", "02:30", "04:00"]
    
    func updateTimeSlot(_ timeSlot: String) {
        selectedTimeSlot = timeSlot
            // No need to invalidate cache here since we're just changing selection
    }
    
    @Published var routines: [RoutineModel] = [] {
        didSet {
                // Only invalidate when routines actually change
            _cachedEmptyRoomsBySlot = nil
                // Pre-calculate all slots when routines change
            Task { await preCalculateAllSlots() }
        }
    }
    
    private var _cachedEmptyRoomsBySlot: [String: [String: [String]]]?
    
        /// All supported time slots
    let timeSlots: [(start: String, end: String)] = [
        ("08:30", "10:00"),
        ("10:00", "11:30"),
        ("11:30", "01:00"),
        ("01:00", "02:30"),
        ("02:30", "04:00"),
        ("04:00", "05:30")
    ]
    
        /// Get empty rooms by day for a specific slot
    func emptyRoomsByDay(for slot: (start: String, end: String)) -> [String: [String]] {
        let key = slot.start + "-" + slot.end
        
            // If cache exists, return immediately
        if let cached = _cachedEmptyRoomsBySlot?[key] {
            return cached
        }
        
            // If no cache, calculate and store
        let result = calculateEmptyRooms(slotStart: slot.start, slotEnd: slot.end)
        if _cachedEmptyRoomsBySlot == nil {
            _cachedEmptyRoomsBySlot = [:]
        }
        _cachedEmptyRoomsBySlot?[key] = result
        return result
    }
    
        // MARK: - Pre-calculation for better performance
    private func preCalculateAllSlots() async {
        guard !routines.isEmpty else { return }
        
        var newCache: [String: [String: [String]]] = [:]
        
            // Calculate all time slots at once
        for slot in timeSlots {
            let key = slot.start + "-" + slot.end
            newCache[key] = calculateEmptyRooms(slotStart: slot.start, slotEnd: slot.end)
        }
        
            // Update cache on main thread
        await MainActor.run {
            _cachedEmptyRoomsBySlot = newCache
        }
    }
    
        // MARK: - Core Logic
    private func calculateEmptyRooms(slotStart: String, slotEnd: String) -> [String: [String]] {
            // Group routines by day
        let groupedByDay = Dictionary(grouping: routines) { routine in
            let dayString = routine.day.trimmingCharacters(in: .whitespacesAndNewlines)
            return dayString.count >= 3 ? String(dayString.prefix(3)).uppercased() : dayString.uppercased()
        }
        
        var result: [String: [String]] = [:]
        
        for (day, routinesForDay) in groupedByDay {
                // Routines that overlap with the slot
            let slotRoutines = routinesForDay.filter { routine in
                overlapsWithSlot(startTime: routine.startTime,
                                 endTime: routine.endTime,
                                 slotStart: slotStart,
                                 slotEnd: slotEnd)
            }
            
                // Empty rooms = courseCode/teacher/section is nil or empty
            let emptyRooms = slotRoutines.filter { routine in
                (routine.courseCode?.isEmpty ?? true) ||
                (routine.teacher?.isEmpty ?? true) ||
                (routine.section?.isEmpty ?? true)
            }
                .map { $0.room }
                .sorted()
            
            result[day] = emptyRooms
        }
        
        return result
    }
    
        // MARK: - Flexible Time Slot Check
    private func overlapsWithSlot(startTime: String, endTime: String, slotStart: String, slotEnd: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let start = formatter.date(from: startTime),
              let end = formatter.date(from: endTime),
              let slotStartDate = formatter.date(from: slotStart),
              let slotEndDate = formatter.date(from: slotEnd) else {
            return false
        }
        
        return start < slotEndDate && end > slotStartDate
    }
}
