//
//  TeacherTab.swift
//  Practice
//
//  Created by Hafizur Rahman on 21/8/25.
//

import SwiftUI

enum TeacherTab: String, CaseIterable, Identifiable {
    case routine = "Routine"
    case insights = "Insights"
    
    var id: String { rawValue }
    
    var index: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }
    
    var page: String {
        switch self {
            case .routine:
                return "Routine"
            case .insights:
                return "Insights"
        }
    }
}
