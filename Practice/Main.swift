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
    @StateObject private var tInfo = ContactManager()
    @StateObject private var teacherManager = TeacherManager()
    
    var body: some Scene {
        WindowGroup {
            Home()
                .environmentObject(manager)
                .environmentObject(tInfo)
                .environmentObject(teacherManager)
        }
        .modelContainer(for: [RoutineModel.self, CourseModel.self, TeacherModel.self])
    }
}



