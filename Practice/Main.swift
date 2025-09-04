//
//  Main.swift
//  Practice
//
//  Created by Hafizur Rahman on 16/8/25.
//

import SwiftUI
import SwiftData

@main
struct Main: App {
    @StateObject private var manager = RoutineManager()
    
    var body: some Scene {
        WindowGroup {
            Home()
        }
        .modelContainer(for: [RoutineModel.self, CourseModel.self, TeacherModel.self])
        .environmentObject(manager)
    }
}



