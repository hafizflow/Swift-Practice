import SwiftUI

struct StudentTabBar: View {
    @Binding var activeTab: StudentTab
    var tint: Color = .gray
    var weight: Font.Weight = .semibold
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                ForEach(StudentTab.allCases, id: \.rawValue) { tab in
                    Text(tab.rawValue)
                        .font(.system(size: 14))
                        .fontWeight(weight)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .contentShape(.rect)
                        .onTapGesture {
                            withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                                activeTab = tab
                            }
                        }
                }
            }
            
                // Underline for the active tab
            GeometryReader { geometry in
                let tabWidth = geometry.size.width / CGFloat(StudentTab.allCases.count)
                let offsetX = CGFloat(activeTab.index) * tabWidth
                
                Rectangle()
                    .cornerRadius(30)
                    .frame(height: 3)
                    .foregroundColor(tint)
                    .offset(x: offsetX)
                    .frame(width: tabWidth)
                    .animation(.snappy(duration: 0.3, extraBounce: 0), value: activeTab)
            }
        }
    }
}

#Preview {
    StudentTabBar(activeTab: .constant(.routine))
        .foregroundStyle(.white.opacity(0.9))
        .background(.mainBackground)
        .environment(\.colorScheme, .dark)
}
