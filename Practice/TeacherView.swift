//
//  TeacherView.swift
//  Practice
//
//  Created by Hafizur Rahman on 1/8/25.
//

import SwiftUI

struct TeacherView: View {
    @State private var counter = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Counter: \(counter)")
                .font(.largeTitle)
            
            HStack(spacing: 40) {
                Button(action: {
                    counter -= 1
                }) {
                    Text("-")
                        .font(.largeTitle)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    counter += 1
                }) {
                    Text("+")
                        .font(.largeTitle)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .background(Color.green)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
    }
}

#Preview {
    TeacherView()
}

