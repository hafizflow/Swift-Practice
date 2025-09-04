import Foundation

enum APIServiceError: Error, LocalizedError {
    case invalidURL
    case serverError(String)
    case decodingError
    
    var errorDescription: String? {
        switch self {
            case .invalidURL:
                return "Invalid URL."
            case .serverError(let message):
                return message
            case .decodingError:
                return "Failed to decode response."
        }
    }
}


class APIService {
    
        // MARK: - Fetch Routine
    func fetchRoutine() async throws -> RoutineResponse {
        guard let url = URL(string: "https://diu.zahidp.xyz/api/routine-table") else {
            throw APIServiceError.invalidURL
        }
        return try await fetch(from: url, type: RoutineResponse.self)
    }
    
        // MARK: - Fetch Course
    func fetchCourse() async throws -> CourseResponse {
        guard let url = URL(string: "https://diu.zahidp.xyz/api/course-table") else {
            throw APIServiceError.invalidURL
        }
        return try await fetch(from: url, type: CourseResponse.self)
    }
    
        // MARK: - Fetch Course
    func fetchTeacher() async throws -> TeacherResponse {
        guard let url = URL(string: "https://diu.zahidp.xyz/api/teacher-table") else {
            throw APIServiceError.invalidURL
        }
        return try await fetch(from: url, type: TeacherResponse.self)
    }
    
        // MARK: - Generic fetch function
    private func fetch<T: Codable>(from url: URL, type: T.Type) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        
            // 1. Check HTTP status code
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw APIServiceError.serverError("HTTP Error: \(httpResponse.statusCode)")
        }
        
            // 2. Decode JSON
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            
                // 3. Check API status if it has a "status" field
            if let apiResponse = decoded as? (any APIStatusCheck),
               apiResponse.status == "failed" {
                throw APIServiceError.serverError(apiResponse.apiMessage ?? "No data found")
            }
            
            return decoded
        } catch {
            throw APIServiceError.decodingError
        }
    }
}

    // MARK: - Protocol to handle status check
protocol APIStatusCheck {
    var status: String { get }
    var apiMessage: String? { get }
}

extension RoutineResponse: APIStatusCheck {
    var apiMessage: String? { message }
}

extension CourseResponse: APIStatusCheck {
    var apiMessage: String? { message }
}

extension TeacherResponse: APIStatusCheck {
    var apiMessage: String? { message }
}



