import Foundation
import SwiftData

    // MARK: - API Response
struct TeacherResponse: Codable {
    let status: String
    let version: String?
    let message: String?
    let data: [TeacherDTO]
}

    // MARK: - DTO (Data Transfer Object for API)
struct TeacherDTO: Codable, Identifiable {
    let id: Int
    let name: String?
    let teacher: String?
    let designation: String?
    let department: String?
    let faculty: String?
    let email: String?
    let phone: String?
    let cellPhone: String?
    let personalWebsite: String?
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, teacher, designation, department, faculty, email, phone
        case cellPhone = "cell_phone"
        case personalWebsite = "personal_website"
        case imageUrl = "image_url"
    }
    
        // Custom decoder to handle empty strings as nil
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try? container.decodeIfPresent(String.self, forKey: .name)?.nilIfEmpty()
        teacher = try? container.decodeIfPresent(String.self, forKey: .teacher)?.nilIfEmpty()
        designation = try? container.decodeIfPresent(String.self, forKey: .designation)?.nilIfEmpty()
        department = try? container.decodeIfPresent(String.self, forKey: .department)?.nilIfEmpty()
        faculty = try? container.decodeIfPresent(String.self, forKey: .faculty)?.nilIfEmpty()
        email = try? container.decodeIfPresent(String.self, forKey: .email)?.nilIfEmpty()
        phone = try? container.decodeIfPresent(String.self, forKey: .phone)?.nilIfEmpty()
        cellPhone = try? container.decodeIfPresent(String.self, forKey: .cellPhone)?.nilIfEmpty()
        personalWebsite = try? container.decodeIfPresent(String.self, forKey: .personalWebsite)?.nilIfEmpty()
        imageUrl = try? container.decodeIfPresent(String.self, forKey: .imageUrl)?.nilIfEmpty()
    }
}

    // MARK: - SwiftData Model
@Model
class TeacherModel: Identifiable {
    var id: UUID        // Local SwiftData primary key
    var apiID: Int      // API id
    
    var name: String?
    var teacher: String?
    var designation: String?
    var department: String?
    var faculty: String?
    var email: String?
    var phone: String?
    var cellPhone: String?
    var personalWebsite: String?
    var imageUrl: String?
    
    init(apiID: Int,
         name: String? = nil,
         teacher: String? = nil,
         designation: String? = nil,
         department: String? = nil,
         faculty: String? = nil,
         email: String? = nil,
         phone: String? = nil,
         cellPhone: String? = nil,
         personalWebsite: String? = nil,
         imageUrl: String? = nil) {
        self.id = UUID()
        self.apiID = apiID
        self.name = name
        self.teacher = teacher
        self.designation = designation
        self.department = department
        self.faculty = faculty
        self.email = email
        self.phone = phone
        self.cellPhone = cellPhone
        self.personalWebsite = personalWebsite
        self.imageUrl = imageUrl
    }
    
        // Safe init from DTO
    convenience init(from dto: TeacherDTO) {
        self.init(
            apiID: dto.id,
            name: dto.name,
            teacher: dto.teacher,
            designation: dto.designation,
            department: dto.department,
            faculty: dto.faculty,
            email: dto.email,
            phone: dto.phone,
            cellPhone: dto.cellPhone,
            personalWebsite: dto.personalWebsite,
            imageUrl: dto.imageUrl
        )
    }
}


