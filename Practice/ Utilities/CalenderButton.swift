//
//  CalenderButton.swift
//  Practice
//
//  Created by Hafizur Rahman on 31/8/25.
//

import SwiftUI

struct CalenderButton: View {
    @Binding var showMonthRoutine: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(lineWidth: 1)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.mainBackground)
            }
            .foregroundStyle(.gray.opacity(0.65))
            .frame(maxWidth: 45, maxHeight: 40)
            .overlay {
                Button {
                    withAnimation {
                        showMonthRoutine.toggle()
                    }
                } label: {
                    Image(systemName: "calendar")
                        .tint(.white)
                }
            }
            .padding(.trailing, 27.5)
            .padding(.bottom, 65)
    }
}

#Preview {
    CalenderButton(showMonthRoutine: .constant(true))
}
