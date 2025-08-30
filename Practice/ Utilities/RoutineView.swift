import SwiftUI

enum tabType {
    case isStudent
    case isTeacher
    case isEmptyRoom
}

// Not used
struct RoutineView: View {
    @Binding var tabType: tabType
    @Binding var currentWeek: [Date.Day]
    @Binding var selectedDate: Date?
    @Binding var showAlert: Bool
    
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
                        .id(selectedDay.date.timeIntervalSince1970)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0, anchor: .top).combined(with: .opacity),
                            removal: .opacity
                        ))
                    }
                }
            }
            .contentMargins(.all, 20, for: .scrollContent)
            .contentMargins(.vertical, 20, for: .scrollIndicators)
        }
        .animation(.easeInOut(duration: 0.4), value: selectedDate)
    }
}

// Not used
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


struct RoutineViewManualAnimation: View {
    @Binding var tabType: tabType
    @Binding var currentWeek: [Date.Day]
    @Binding var selectedDate: Date?
    @Binding var showAlert: Bool
    
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            ScrollViewReader { proxy in
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
                                .frame(height: 65)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id("topContent") // Add ID for scroll targeting
                                
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
                                .frame(minHeight: size.height - 120, alignment: .top)
                            }
                            .scaleEffect(scale, anchor: .top)
                            .opacity(opacity)
                        }
                    }
                }
                .contentMargins(.all, 20, for: .scrollContent)
                .contentMargins(.vertical, 20, for: .scrollIndicators)
                .onChange(of: selectedDate) { oldValue, newValue in
                        // Quick fade out
                    withAnimation(.easeOut(duration: 0.1)) {
                        opacity = 0
                        scale = 0.8
                    }
                        // Scroll to top and scale up animation after a brief delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scale = 0.0
                            // Scroll to top first
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
        }
    }
}



#Preview {
    RoutineViewManualAnimation(
        tabType: .constant(.isStudent),
        currentWeek: .constant(Date.currentWeek),
        selectedDate: .constant(Date()),
        showAlert: .constant(false)
    )
}
