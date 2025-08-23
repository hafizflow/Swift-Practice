//
//  ERoomCard.swift
//  Practice
//
//  Created by Hafizur Rahman on 24/8/25.
//

import SwiftUI

struct ERoomCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Text("Room Number: ")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(.white.opacity(0.7))
                    .padding([.top, .bottom], 6)
                    .lineLimit(1)
                    .brightness(-0.2)
                
                Text("KT-503")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding([.top, .bottom], 6)
                    .lineLimit(1)
                    .brightness(-0.2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .lineLimit(1)
        .padding(15)
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
