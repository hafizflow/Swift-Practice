import SwiftUI

struct Student: View {
    // View Properties
    @State private var currentWeek: [Date.Day] = Date.currentWeek
    @State private var selectedDate: Date?
    // For Matched Geometry Effect
    @Namespace private var namespace
    
    
    var body: some View {
        VStack(spacing: 0){
            HeaderView()
                .environment(\.colorScheme, .dark)

            GeometryReader { geometry in
                let size = geometry.size
                
                ScrollView(.vertical) {
                    LazyVStack(spacing: 15) {
                        ForEach(currentWeek) { day in
                            let date = day.date
                            let isLast = currentWeek.last?.id == day.id
                            
                            VStack(alignment: .leading, spacing: 15) {
                                // Section Header & Content grouped together
                                HStack(alignment: .center, spacing: 6) {
                                    Text(date.string("EEEE"))
                                        .font(.largeTitle.bold())
                                    
                                    Text(date.string("dd"))
                                        .font(.largeTitle.bold())
                                    
                                    Spacer()
                                    
                                    Text("2 class")
                                        .font(.title3.bold())
                                        .foregroundStyle(.gray)
                                }
                                .frame(height: 70)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Task Row content
                                VStack(alignment: .leading, spacing: 15) {
                                    ClassCard()
                                    ClassCard()
                                }
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: isLast ? size.height - 100 : nil, alignment: .top)
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .contentMargins(.all, 20, for: .scrollContent)
                .contentMargins(.vertical, 20, for: .scrollIndicators)
                .scrollPosition(id: .init(get: {
                    return currentWeek.first(where: { $0.date.isSame(selectedDate)})?.id
                }, set: { newValue in
                    selectedDate = currentWeek.first(where: { $0.id == newValue})?.date
                }), anchor: .top)
            }
            .background(.background)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 30, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 30, style: .continuous))
            .ignoresSafeArea(.all, edges: .bottom)

        }
        .background(.secondBackground)
        .onAppear {
            // Setting up initial Selection Date
            guard selectedDate == nil else { return }
            // Today's Data
            selectedDate = currentWeek.first(where: { $0.date.isSame(.now)})?.date
        }
    }
    
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Student")
                    .font(.title.bold())
                
                Spacer(minLength: 0)
                
                Button {
                } label: {
                    Image(.setting)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(.white)
                }
            }
            
            // Week View
            HStack(spacing: 0) {
                ForEach(currentWeek) { day in
                    let date = day.date
                    let isSameDate = date.isSame(selectedDate)
                    
                    VStack(spacing: 6) {
                        Text(date.string("EEE"))
                            .font(.caption)
                        
                        Text(date.string("dd"))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(isSameDate ? .black : .white)
                            .frame(width: 38, height: 38)
                            .background {
                                if isSameDate {
                                    Circle()
                                        .fill(.white)
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
            .animation(.snappy(duration: 0.25, extraBounce: 0), value: selectedDate)
            .frame(height: 80)
            .padding(.vertical, 5)
            .offset(y: 5)
            
            HStack {
                Text(selectedDate?.string("MMM") ?? "")
                
                Spacer()
                
                Text(selectedDate?.string("YYY") ?? "")
            }
            .font(.caption2)
            
        }
        .padding([.horizontal, .top], 15)
        .padding(.bottom, 10)
    }
}

#Preview {
    Student()
}
