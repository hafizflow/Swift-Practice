//
//  OverflowingText.swift
//  Practice
//
//  Created by Hafizur Rahman on 2/9/25.
//

import SwiftUI

struct OverflowingText: View {
    let text: String
    @State private var isOverflowing = false
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                Text(text)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding([.top, .bottom], 6)
                    .lineLimit(1)
                    .brightness(-0.2)
                    .background(
                        GeometryReader { textGeo in
                            Color.clear
                                .onAppear {
                                    if textGeo.size.width > geo.size.width {
                                        isOverflowing = true
                                    }
                                }
                        }
                    )
            }
            .disabled(!isOverflowing) // 👈 scrolling only if overflow
        }
        .frame(height: 36) // enough height for one line of text
    }
}
