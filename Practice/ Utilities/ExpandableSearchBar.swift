//
//  ExpandableSearchBar.swift
//  Practice
//
//  Created by Hafizur Rahman on 16/8/25.
//

import SwiftUI

struct ExpandableSearchBar: View {
    @State var searchText: String = ""
    @State var isSearching: Bool = false
    
    var body: some View {
        ZStack {
            if isSearching {
                TextField("Section (61_N)", text: $searchText)
                    .padding(24)
            }
            
            HStack {
                Spacer()
                Capsule()
                    .stroke(lineWidth: 1)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: isSearching ? .infinity : 50, maxHeight: 50)
                    .overlay(alignment: .trailing) {
                        Button {
                            withAnimation {
                                isSearching.toggle()
                            }
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .tint(.secondary)
                                .padding()
                            
                        }
                    }
            }
        }
    }
}

#Preview {
    ExpandableSearchBar()
        .padding(.horizontal, 16)
}
