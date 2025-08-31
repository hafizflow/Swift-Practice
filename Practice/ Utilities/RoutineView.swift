import SwiftUI

enum tabType {
    case isStudent
    case isTeacher
    case isEmptyRoom
}

struct RoutineView: View {
    @Binding var tabType: tabType
    @Binding var currentWeek: [Date.Day]
    @Binding var selectedDate: Date?
    @Binding var showAlert: Bool
    @Binding var isScrolledDown: Bool
    
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    @State private var previousScrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    @State private var scrollViewHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
//            let size = geometry.size
            
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(spacing: 0, pinnedViews: []) {
                        if let selectedDay = currentWeek.first(where: { $0.date.isSame(selectedDate) }) {
                            VStack(alignment: .leading, spacing: 4) {
                                    // Section Header
                                HStack(alignment: .center, spacing: 6) {
                                    Text(selectedDay.date.string("EEEE,"))
                                        .font(.title.bold())
                                        .foregroundStyle(.white.opacity(0.8))
                                    
                                    Text(selectedDay.date.string("dd"))
                                        .font(.title.bold())
                                        .foregroundStyle(.white.opacity(0.8))
                                    
                                    Spacer()
                                    
                                    if tabType != .isEmptyRoom {
                                        Text("2 class")
                                            .font(.title3.bold())
                                            .foregroundStyle(.gray)
                                    }
                                }
                                .frame(height: 65)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id("topContent")
                                
                                    // Class Row content
                                VStack(alignment: .leading, spacing: 15) {
                                    switch tabType {
                                        case .isStudent:
                                            ForEach(0..<3, id: \.self) { index in
                                                SClassCard(showAlert: $showAlert)
                                            }
                                        case .isTeacher:
                                            ForEach(0..<3, id: \.self) { index in
                                                TClassCard()
                                            }
                                        case .isEmptyRoom:
                                            ForEach(0..<3, id: \.self) { index in
                                                ERoomCard()
                                            }
                                    }
                                    
                                    Spacer().frame(height: 100)
                                }
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { contentGeometry in
                                        Color.clear
                                            .onAppear {
                                                contentHeight = contentGeometry.size.height
                                            }
                                            .onChange(of: contentGeometry.size.height) { _, newHeight in
                                                contentHeight = newHeight
                                            }
                                    }
                                )
                            }
                            .scaleEffect(scale, anchor: .top)
                            .opacity(opacity)
                        }
                    }
                    .background(
                        GeometryReader { scrollGeometry in
                            let currentOffset = scrollGeometry.frame(in: .named("scrollCoordinate")).minY
                            Color.clear
                                .onChange(of: currentOffset) { oldValue, newValue in
                                    handleScrollChange(currentOffset: newValue)
                                }
                        }
                    )
                }
                .coordinateSpace(name: "scrollCoordinate")
                .contentMargins(.all, 20, for: .scrollContent)
                .contentMargins(.vertical, 20, for: .scrollIndicators)
                .background(
                    GeometryReader { scrollViewGeometry in
                        Color.clear
                            .onAppear {
                                scrollViewHeight = scrollViewGeometry.size.height
                            }
                            .onChange(of: scrollViewGeometry.size.height) { _, newHeight in
                                scrollViewHeight = newHeight
                            }
                    }
                )
                .onChange(of: selectedDate) { oldValue, newValue in
                    isScrolledDown = false
                    previousScrollOffset = 0
                    
                    withAnimation(.easeOut(duration: 0.1)) {
                        opacity = 0
                        scale = 0.8
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scale = 0.0
                        withAnimation(.easeOut(duration: 0.5)) {
                            proxy.scrollTo("topContent", anchor: .top)
                            opacity = 1
                            scale = 1.0
                        }
                    }
                }
            }
        }
        .onAppear {
            scale = 1.0
            opacity = 1.0
            isScrolledDown = false
            previousScrollOffset = 0
        }
    }
    
    private func handleScrollChange(currentOffset: CGFloat) {
        let scrollDifference = currentOffset - previousScrollOffset
        
            // Only process scroll changes if the difference is significant enough
        guard abs(scrollDifference) > 5 else { return }
        
            // Calculate the maximum scroll position (bottom of content)
        let maxScrollOffset = -(max(0, contentHeight - scrollViewHeight + 40)) // 40 for margins
        
            // Ignore scroll changes if we're in bounce territory
        let isAtTopBounce = currentOffset > 20 // Top bounce threshold
        let isAtBottomBounce = currentOffset < maxScrollOffset - 50 // Bottom bounce threshold
        
            // Only update scroll state if we're not bouncing
        if !isAtTopBounce && !isAtBottomBounce {
            if scrollDifference > 0 {
                    // Scrolling up (content moving down)
                isScrolledDown = false
            } else {
                    // Scrolling down (content moving up)
                isScrolledDown = true
            }
            previousScrollOffset = currentOffset
        }
    }
}


#Preview {
    RoutineView(
        tabType: .constant(.isStudent),
        currentWeek: .constant(Date.currentWeek),
        selectedDate: .constant(Date()),
        showAlert: .constant(false),
        isScrolledDown: .constant(false),
    )
}

    // Alternative approach - More reliable animation
struct RoutineViewAlternative: View {
    @Binding var tabType: tabType
    @Binding var currentWeek: [Date.Day]
    @Binding var selectedDate: Date?
    @Binding var showAlert: Bool
    
    @State private var animationID = UUID()
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    if let selectedDay = currentWeek.first(where: { $0.date.isSame(selectedDate) }) {
                        VStack(alignment: .leading, spacing: 4) {
                                // Section Header
                            HStack(alignment: .center, spacing: 6) {
                                Text(selectedDay.date.string("EEEE,"))
                                    .font(.title.bold())
                                    .foregroundStyle(.white.opacity(0.8))
                                
                                Text(selectedDay.date.string("dd"))
                                    .font(.title.bold())
                                    .foregroundStyle(.white.opacity(0.8))
                                
                                Spacer()
                                
                                if tabType != .isEmptyRoom {
                                    Text("2 class")
                                        .font(.title3.bold())
                                        .foregroundStyle(.gray)
                                }
                            }
                            .frame(height: 70)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                                // Class Row content
                            VStack(alignment: .leading, spacing: 15) {
                                switch tabType {
                                    case .isStudent:
                                        SClassCard(showAlert: $showAlert)
                                    case .isTeacher:
                                        TClassCard()
                                    case .isEmptyRoom:
                                        ERoomCard()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: size.height - 100, alignment: .top)
                        }
                        .scaleEffect(1.0)
                        .opacity(1.0)
                        .id(animationID)
                    }
                }
            }
            .contentMargins(.all, 20, for: .scrollContent)
            .contentMargins(.vertical, 20, for: .scrollIndicators)
        }
        .onChange(of: selectedDate) { oldValue, newValue in
            withAnimation(.easeInOut(duration: 0.4)) {
                animationID = UUID()
            }
        }
    }
}




