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
    var body: some Scene {
        WindowGroup {
            Home()
                .environmentObject(RoutineManager())
                .environmentObject(ContactManager())
                .environmentObject(TeacherManager())
                .environmentObject(EmptyRoomManager())
        }
        .modelContainer(for: [RoutineModel.self, CourseModel.self, TeacherModel.self])
    }
}



