import Foundation
import SwiftData

    // MARK: - API Response
struct RoutineResponse: Codable {
    let status: String
    let version: String?
    let message: String?     
    let data: [RoutineDTO]
}

    // MARK: - DTO (for decoding API JSON)
struct RoutineDTO: Codable, Identifiable {
    let id: Int
    let section: String?
    let startTime: String
    let endTime: String
    let courseCode: String?
    let room: String
    let teacher: String?
    let day: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case section
        case startTime = "start_time"
        case endTime = "end_time"
        case courseCode = "course_code"
        case room
        case teacher
        case day
    }
    
        // Custom decoding to handle empty strings as nil
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        section = try? container.decodeIfPresent(String.self, forKey: .section)?.nilIfEmpty()
        startTime = try container.decode(String.self, forKey: .startTime)
        endTime = try container.decode(String.self, forKey: .endTime)
        courseCode = try? container.decodeIfPresent(String.self, forKey: .courseCode)?.nilIfEmpty()
        room = try container.decode(String.self, forKey: .room)
        teacher = try? container.decodeIfPresent(String.self, forKey: .teacher)?.nilIfEmpty()
        day = try container.decode(String.self, forKey: .day)
    }
}

    // MARK: - SwiftData Model
@Model
class RoutineModel: Identifiable {
    var id: UUID            // Primary key for SwiftData
    var apiID: Int          // API id
    
    var section: String?
    var startTime: String
    var endTime: String
    var courseCode: String?
    var room: String
    var teacher: String?
    var day: String
    
    init(apiID: Int,
         section: String? = nil,
         startTime: String,
         endTime: String,
         courseCode: String? = nil,
         room: String,
         teacher: String? = nil,
         day: String) {
        self.id = UUID()
        self.apiID = apiID
        self.section = section
        self.startTime = startTime
        self.endTime = endTime
        self.courseCode = courseCode
        self.room = room
        self.teacher = teacher
        self.day = day
    }
    
        // Safe conversion from DTO
    convenience init(from dto: RoutineDTO) {
        self.init(
            apiID: dto.id,
            section: dto.section,
            startTime: dto.startTime,
            endTime: dto.endTime,
            courseCode: dto.courseCode,
            room: dto.room,
            teacher: dto.teacher,
            day: dto.day
        )
    }
}


