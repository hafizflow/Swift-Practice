import SwiftUI

struct TeacherTabBar: View {
    @Binding var activeTab: TeacherTab
    @Binding var selectedDate: Date?
    let tint: Color
    let weight: Font.Weight
    
    init(activeTab: Binding<TeacherTab>, selectedDate: Binding<Date?>, tint: Color = .gray, weight: Font.Weight = .regular) {
        self._activeTab = activeTab
        self._selectedDate = selectedDate
        self.tint = tint
        self.weight = weight
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Text(selectedDate?.string("MMM") ?? "")
            
            Spacer()
            
            VStack(alignment: .center, spacing: 0) {
                HStack {
                    ForEach(TeacherTab.allCases, id: \.rawValue) { tab in
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
                    let tabWidth = geometry.size.width / CGFloat(TeacherTab.allCases.count)
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
            .frame(maxHeight: 24)
            .padding(.horizontal, 40)
            .foregroundStyle(.white.opacity(0.9))
            
            Spacer()
            
            Text(selectedDate?.string("YYY") ?? "")
        }
        .font(.caption2)
    }
}
