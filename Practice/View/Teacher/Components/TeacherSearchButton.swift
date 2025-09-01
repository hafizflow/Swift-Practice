//
//  TeacherSearchButton.swift
//  Practice
//
//  Created by Hafizur Rahman on 1/9/25.
//

import SwiftUI

struct TeacherSearchButton: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(lineWidth: 1.5)
            .foregroundStyle(.teal.opacity(0.5))
            .frame(maxWidth: 60, maxHeight: 50)
            .overlay(alignment: .trailing) {
                Button {
                    
                } label: {
                    Image(systemName: "magnifyingglass")
                        .tint(.white)
                        .padding(.trailing, 20)
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.mainBackground)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 5)
    }
}

#Preview {
    TeacherSearchButton()
}
