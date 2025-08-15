//
//  ContentView.swift
//  Practice
//
//  Created by Hafizur Rahman on 1/8/25.
//

import SwiftUI

struct ContentView: View {
    @State var selection: Int = 0
    
    var body: some View {
        TabView(selection: $selection) {
            Tab("Received", systemImage: "tray.and.arrow.down.fill", value: 0) {
                Home()
            }
            
            
            Tab("Sent", systemImage: "tray.and.arrow.up.fill", value: 1) {
                TeacherView()
            }
            
            
            Tab("Account", systemImage: "person.crop.circle.fill", value: 2) {
                RoutineView()
            }
        }
    }
}

#Preview {
    ContentView()
}
