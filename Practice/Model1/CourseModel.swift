import Foundation
import SwiftData

    // MARK: - API Response
struct CourseResponse: Codable {
    let status: String
    let version: String?
    let message: String?
    let data: [CourseDTO]
}

    // MARK: - DTO (Data Transfer Object for API)
struct CourseDTO: Codable, Identifiable {
    let id: Int
    let courseCode: String?
    let courseTitle: String?
    let credits: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case courseCode = "course_code"
        case courseTitle = "course_title"
        case credits
    }
    
        // Custom decoder → converts empty string to nil
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        courseCode = try? container.decodeIfPresent(String.self, forKey: .courseCode)?.nilIfEmpty()
        courseTitle = try? container.decodeIfPresent(String.self, forKey: .courseTitle)?.nilIfEmpty()
        credits = try container.decodeIfPresent(Double.self, forKey: .credits) ?? 0.0
    }
}

    // MARK: - SwiftData Model
@Model
class CourseModel: Identifiable {
    var id: UUID                // Local SwiftData primary key
    var apiID: Int              // API id
    
    var courseCode: String?
    var courseTitle: String?
    var credits: Double
    
    init(apiID: Int,
         courseCode: String? = nil,
         courseTitle: String? = nil,
         credits: Double = 0.0) {
        self.id = UUID()
        self.apiID = apiID
        self.courseCode = courseCode
        self.courseTitle = courseTitle
        self.credits = credits
    }
    
        // Safe init from DTO
    convenience init(from dto: CourseDTO) {
        self.init(
            apiID: dto.id,
            courseCode: dto.courseCode,
            courseTitle: dto.courseTitle,
            credits: dto.credits
        )
    }
}

