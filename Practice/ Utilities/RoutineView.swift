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
    
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    @EnvironmentObject var studentManager: RoutineManager
    @EnvironmentObject var teacherManager: TeacherManager
    

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(spacing: 0, pinnedViews: []) {
                        if let selectedDay = currentWeek.first(where: { $0.date.isSame(selectedDate) }) {
                            VStack(alignment: .leading, spacing: 4) {
                                    // Section Header
                                headerView(for: selectedDay).id("topContent")
                                
                                    // Class Row content
                                classContentView(for: selectedDay)
                            }
                            .scaleEffect(scale, anchor: .top)
                            .opacity(opacity)
                                // Improved animations with spring physics
                            .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: scale)
                            .animation(.easeOut(duration: 0.4), value: opacity)
                        }
                    }
                }
                .coordinateSpace(name: "scrollCoordinate")
                .contentMargins(.all, 20, for: .scrollContent)
                .contentMargins(.vertical, 20, for: .scrollIndicators)
                .onChange(of: selectedDate) { oldValue, newValue in
                    animateContentTransition(proxy: proxy)
                }
            }
        }
        .onAppear {
            initializeView()
        }
    }
    
        // MARK: - Extracted Views for Better Performance
    @ViewBuilder
    private func headerView(for selectedDay: Date.Day) -> some View {
        HStack(alignment: .center, spacing: 6) {
            Text(selectedDay.date.string("EEEE, "))
                .font(.title.bold())
                .foregroundStyle(.white.opacity(0.8))
            
            Text(selectedDay.date.string("dd"))
                .font(.title.bold())
                .foregroundStyle(.white.opacity(0.8))
            
            Spacer()
            
            if tabType != .isEmptyRoom {
                let dayKey = selectedDay.date.string("EEE").uppercased()
                let routineCount = studentManager.filteredRoutinesWithDetails[dayKey]?.count ?? 0
                if routineCount > 0 {
                    Text("\(routineCount) class\(routineCount != 1 ? "es" : "")")
                        .font(.title3.bold())
                        .foregroundStyle(.gray)
                }
            }
            
            if tabType != .isEmptyRoom {
                let dayKey = selectedDay.date.string("EEE").uppercased()
                let routineCount = teacherManager.filteredRoutinesWithDetails[dayKey]?.count ?? 0
                if routineCount > 0 {
                    Text("\(routineCount) class\(routineCount != 1 ? "es" : "")")
                        .font(.title3.bold())
                        .foregroundStyle(.gray)
                }
            }
        }
        .frame(height: 65)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func classContentView(for selectedDay: Date.Day) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            switch tabType {
                case .isStudent:
                    studentClassesView(for: selectedDay)
                case .isTeacher:
                    teacherClassesView(for: selectedDay)
                case .isEmptyRoom:
                    emptyRoomView()
            }
            
            Spacer().frame(height: 100)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func studentClassesView(for selectedDay: Date.Day) -> some View {
        let dayKey = selectedDay.date.string("EEE").uppercased()
        
        if let routines = studentManager.filteredRoutinesWithDetails[dayKey], !routines.isEmpty {
            ForEach(routines) { routine in
                SClassCard(routine: routine, showAlert: $showAlert)
            }
        } else {
            SClassCard(routine: nil, showAlert: $showAlert)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.1).combined(with: .opacity).combined(with: .move(edge: .bottom)),
                    removal: .scale(scale: 0.1).combined(with: .opacity).combined(with: .move(edge: .top))
                ))
        }
    }
    
    @ViewBuilder
    private func teacherClassesView(for selectedDay: Date.Day) -> some View {
        let dayKey = selectedDay.date.string("EEE").uppercased()
        
        if let routines = teacherManager.filteredRoutinesWithDetails[dayKey], !routines.isEmpty {
            ForEach(routines) { routine in
                TClassCard(routine: routine)
            }
        } else {
            TClassCard(routine: nil)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity).combined(with: .move(edge: .bottom)),
                    removal: .scale(scale: 0.95).combined(with: .opacity).combined(with: .move(edge: .top))
                ))
        }
    }
    
    @ViewBuilder
    private func emptyRoomView() -> some View {
        ForEach(0..<3, id: \.self) { index in
            ERoomCard()
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity).combined(with: .move(edge: .bottom)),
                    removal: .scale(scale: 0.95).combined(with: .opacity).combined(with: .move(edge: .top))
                ))
        }
    }
    
        // MARK: - Helper Functions
    
    private func initializeView() {
        scale = 1.0
        opacity = 1.0
    }
    
    private func animateContentTransition(proxy: ScrollViewProxy) {
            // Enhanced transition animation
        withAnimation(.easeInOut(duration: 0.15)) {
            opacity = 0.0
            scale = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.75)) {
                proxy.scrollTo("topContent", anchor: .top)
                opacity = 1
                scale = 1
            }
        }
    }
}

#Preview {
    RoutineView(
        tabType: .constant(.isStudent),
        currentWeek: .constant(Date.currentWeek),
        selectedDate: .constant(Date()),
        showAlert: .constant(false)
    )
    .environmentObject(RoutineManager())
}
