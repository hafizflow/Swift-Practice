//
//  ERoomCard.swift
//  Practice
//
//  Created by Hafizur Rahman on 24/8/25.
//

import SwiftUI

struct ERoomCard: View {
    var isEmpty: Bool = false
    var body: some View {
        Group {
            if isEmpty {
                VStack(alignment: .center, spacing: 0) {
                    LottieAnimation(animationName: "notfound.json")
                        .frame(maxWidth: .infinity, maxHeight: 250)
                        .padding(.bottom, 8)
                    Text("No Empty Room Found !!!")
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 16)
                }
                .frame(height: 350)
                .frame(maxWidth: .infinity)
            } else {
                VStack(alignment: .leading) {
                    Text("08:30 - 10:30")
                        .font(.system(size: 16))
                        .fontWeight(.bold)
                        .foregroundStyle(.teal.opacity(0.9))
                        .brightness(-0.2)
                        .padding(.bottom, 4)
                    
                    HStack(alignment: .center) {
                        Text("Room No: ")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(.white.opacity(0.7))
                            .minimumScaleFactor(0.4)
                            .brightness(-0.2)
                        
                        Text("KT-503")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(.white.opacity(0.9))
                            .minimumScaleFactor(0.4)
                            .brightness(-0.2)
                    }
                }
                .lineLimit(1)
                .padding(15)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(.testBg)
                .shadow(color: .gray.opacity(0.75), radius: 2)
        }
    }
}

#Preview {
    ERoomCard()
    
}
