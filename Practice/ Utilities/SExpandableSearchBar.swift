import SwiftUI

struct SExpandableSearchBar: View {
    @State var searchText: String = ""
    @Binding var isSearching: Bool
    
    var body: some View {
        ZStack {
            if isSearching {
                HStack(spacing: 0) {
                    TextField("Section (61_N)", text: $searchText)
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    HStack (spacing: 0) {
                        Divider()
                            .frame(height: 30)
                        
                        DropdownMenu(dropdownAlignment: .center, fromTop: true, options: [
                            DropdownOption(title: "CSE", action: { print("Show CSE details") }),
                        ])
                        .frame(width: 50)
                        
                        Divider()
                            .frame(width: 2)
                            .frame(height: 30)
                            .foregroundStyle(.gray.opacity(0.8))
                    }
                    .offset(x: -60)
                }
                
            }
            
            HStack (spacing: 0) {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(.gray.opacity(0.65))
                    .frame(maxWidth: isSearching ? .infinity : 60, maxHeight: 50)
                    .overlay(alignment: .trailing) {
                        Button {
                            withAnimation {
                                isSearching.toggle()
                            }
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .tint(.white)
                                .padding(.trailing, 20)
                        }
                    }
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.mainBackground)
        }
        .animation(.easeInOut(duration: 0.3), value: isSearching)
    }
}


#Preview {
    SExpandableSearchBar(isSearching: .constant(false))
        .padding(.horizontal, 16)
}
