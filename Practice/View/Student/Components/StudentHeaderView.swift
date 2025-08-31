import SwiftUI

struct StudentHeaderView: View {
    @Binding var currentWeek: [Date.Day]
    @Binding var selectedDate: Date?
    @Binding var activeTab: StudentTab
    @Binding var showSettings: Bool
    
        // For Matched Geometry Effect
    @Namespace private var namespace
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Student")
                    .font(.title.bold())
                    .opacity(0.8)
                
                Spacer(minLength: 0)
                
                Button {
                    showSettings.toggle()
                } label: {
                    Image(.setting)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(.white)
                        .opacity(0.8)
                }
            }
            .padding(.horizontal, 5)
            
                // Week View (excluding Friday)
            HStack(spacing: 0) {
                ForEach(currentWeek.filter { Calendar.current.component(.weekday, from: $0.date) != 6 }) { day in
                    let date = day.date
                    let isSameDate = date.isSame(selectedDate)
                    
                    VStack(spacing: 6) {
                        Text(date.string("EEE"))
                            .font(.caption)
                            .opacity(0.9)
                        
                        Text(date.string("dd"))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(isSameDate ? .black : .white)
                            .frame(width: 38, height: 38)
                            .opacity(0.8)
                            .background {
                                if isSameDate {
                                    Circle()
                                        .fill(.white.opacity(0.9))
                                        .matchedGeometryEffect(id: "ACTIVEDATE", in: namespace)
                                }
                            }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                            selectedDate = date
                        }
                    }
                }
            }
            .animation(.snappy(duration: 0.3, extraBounce: 0), value: selectedDate)
            .frame(height: 80)
            .padding(.vertical, 5)
            .offset(y: 5)
            
            HStack (alignment: .center) {
                Text(selectedDate?.string("MMM") ?? "")
                
                Spacer()
                
                StudentTabBar(activeTab: $activeTab)
                    .frame(maxHeight: 24)
                    .padding(.horizontal, 40)
                    .foregroundStyle(.white.opacity(0.9))
                
                Spacer()
                
                Text(selectedDate?.string("YYY") ?? "")
            }
            .font(.caption2)
        }
        .padding(.horizontal, 15)
        .padding(.top, 15)
        .padding(.bottom, 10)
    }
}

#Preview {
    StudentHeaderView(
        currentWeek: .constant(Date.currentWeek),
        selectedDate: .constant(Date()),
        activeTab: .constant(.routine),
        showSettings: .constant(false)
    )
    .background(.mainBackground)
    .environment(\.colorScheme, .dark)
}
