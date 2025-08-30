import SwiftUI


struct ExamRoutine: View {
    @Binding  var showAlert: Bool
    @Binding var isSearching: Bool
        // View Properties
    @State private var currentWeek: [Date.Day] = Date.currentWeek
    @State private var tabType: tabType = .isTeacher
    @State private var selectedDate: Date?
        // For Matched Geometry Effect
    @Namespace private var namespace
    @State private var activeTab: TeacherTab = .routine
    var haveData = false
    
    
    
    var body: some View {
        VStack(alignment: .center, spacing: 0){
            HeaderView()
                .environment(\.colorScheme, .dark)
            
            
            if haveData {
                VStack {
                    LottieAnimation(animationName: "discover.json")
                        .frame(maxWidth: .infinity , maxHeight: 250)
                        .padding(.horizontal, 30)
                    
                    Text("Enter Your Section")
                        .foregroundStyle(.white.opacity(0.9))
                        .fontWeight(.medium)
                        .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity , maxHeight: .infinity)
                .overlay(alignment: .bottomTrailing) {
                    ZStack(alignment: .bottomTrailing) {
                        if isSearching {
                                // Fullscreen invisible layer
                            Color.black.opacity(0.001)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    isSearching = false
                                }
                                .zIndex(1)
                        }
                        
                        EExpandableSearchBar(isSearching: $isSearching)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 5)
                            .zIndex(2)
                    }
                }
                .background(.testBg)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 30, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 30, style: .continuous))
                .ignoresSafeArea(.all, edges: .bottom)
            } else {
                VStack(alignment: .center, spacing: 16) {
                    ScrollView {
                        ExamCard(showAlert: $showAlert).padding(.horizontal, 20).padding(.top, 16)
                        ExamCard(showAlert: $showAlert).padding(.horizontal, 20).padding(.top, 16)
                    }
                    
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.testBg)
                    .clipShape(UnevenRoundedRectangle(
                        topLeadingRadius: 30,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 30,
                        style: .continuous)
                    )
                    .ignoresSafeArea(.all, edges: .bottom)
                    .overlay(alignment: .bottomTrailing) {
                        ZStack(alignment: .bottomTrailing) {
                            if isSearching {
                                    // Fullscreen invisible layer
                                Color.black.opacity(0.001)
                                    .ignoresSafeArea()
                                    .onTapGesture {
                                        isSearching = false
                                    }
                                    .zIndex(1)
                            }
                            
                            EExpandableSearchBar(isSearching: $isSearching)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 5)
                                .zIndex(2)
                        }
                    }
                    .background(.mainBackground)
                }

            }
        }
            
            
        
    }
    
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ExamRoutine")
                    .font(.title.bold())
                    .opacity(0.8)
                
                Spacer(minLength: 0)
                
                Button {
                } label: {
                    Image(.setting)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(.white)
                        .opacity(0.8)
                }
            }
            
            HStack (alignment: .center) {
                Text(selectedDate?.string("MMM") ?? "")
                
                Spacer()
                
                Text(selectedDate?.string("YYY") ?? "")
            }
            .font(.caption2)
            
        }
        .padding([.horizontal, .top], 15)
        .padding(.bottom, 10)
        .background(.mainBackground)
    }
}


#Preview {
    ExamRoutine(showAlert: .constant(false), isSearching: .constant(false))
}


