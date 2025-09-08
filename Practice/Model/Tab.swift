enum Tab: String {
    case student = "graduationcap"
    case teacher = "person.crop.rectangle.stack"
    case emptyRoom = "square.stack"
    case examRoutine = "list.clipboard"
    
    var title: String {
        switch self {
            case .student: return "Student"
            case .teacher: return "Teacher"
            case .emptyRoom: return "EmptyRoom"
            case .examRoutine: return "Exam"
        }
    }
}
