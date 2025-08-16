//
//  Tab.swift
//  Practice
//
//  Created by Hafizur Rahman on 16/8/25.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case student = "graduationcap"
    case teacher = "person.crop.rectangle"
    case teacherInfo = "person.text.rectangle"
    case emptyRoom = "square.stack"
    
    var title: String {
        switch self {
            case .student:
                return "Student"
            case .teacher:
                return "Teacher"
            case .teacherInfo:
                return "Teacher Info"
            case .emptyRoom:
                return "Empty Room"
        }
    }
}


// Animated SF Tab Model
struct AnimatedTab: Identifiable {
    var id: UUID = .init()
    var tab: Tab
    var isAnimating: Bool?
}
