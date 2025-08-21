import SwiftUI


struct Student: View {
    // View Properties
    @State private var currentWeek: [Date.Day] = Date.currentWeek
    @State private var selectedDate: Date?
    // For Matched Geometry Effect
    @Namespace private var namespace
    @State private var activeTab: StudentTab = .routine
    var offSetObserve = PageOffsetObserver()

    
    var body: some View {
        VStack(alignment: .center, spacing: 0){
            HeaderView()
                .environment(\.colorScheme, .dark)
            
            TabView(selection: $activeTab) {
                
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
                                            .foregroundStyle(.white.opacity(0.8))
                                        
                                        Text(date.string("dd"))
                                            .font(.largeTitle.bold())
                                            .foregroundStyle(.white.opacity(0.8))
                                        
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
                .onAppear {
                    // Setting up initial Selection Date
                    guard selectedDate == nil else { return }
                    // Today's Data
                    selectedDate = currentWeek.first(where: { $0.date.isSame(.now)})?.date
                }
                .tag(StudentTab.routine)
                
               
                ScrollView(.vertical) {
                    InsightCard().padding(15)
                }
                .tag(StudentTab.insights)

                
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .background(.testBg)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 30, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 30, style: .continuous))
            .ignoresSafeArea(.all, edges: .bottom)

        }
        .background(.mainBackground)
        
    }
    
    @ViewBuilder
    func Tabbar(_ tint: Color, _ weight: Font.Weight = .regular, activeTab: Binding<StudentTab>) -> some View {
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
                                activeTab.wrappedValue = tab
                            }
                        }
                }
            }
            
            // Underline for the active tab
            GeometryReader { geometry in
                let tabWidth = geometry.size.width / CGFloat(StudentTab.allCases.count)
                let offsetX = CGFloat(activeTab.wrappedValue.index) * tabWidth
                
                Rectangle()
                    .cornerRadius(30)
                    .frame(height: 3)
                    .foregroundColor(tint)
                    .offset(x: offsetX)
                    .frame(width: tabWidth)
                    .animation(.snappy(duration: 0.3, extraBounce: 0), value: activeTab.wrappedValue)
            }        }
    }
    
    
    
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Student")
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
            
            // Week View
            HStack(spacing: 0) {
                ForEach(currentWeek) { day in
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
            
            HStack (alignment: .center) {
                Text(selectedDate?.string("MMM") ?? "")
                
                Spacer()
                
                Tabbar(.gray, .semibold, activeTab: $activeTab)
                    .frame(maxHeight: 24)
                    .padding(.horizontal, 40)
                    .foregroundStyle(.white.opacity(0.9))
                
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



@Observable
class PageOffsetObserver: NSObject {
    var collectionView: UICollectionView?
    var offset: CGPoint = .zero
    private(set) var isObserving: Bool = false
    
    deinit {
        remove()
    }
    
    func ovserve() {
        // Safe method
        guard !isObserving else { return }
        collectionView?.addObserver(self, forKeyPath: "contentOffset", context: nil)
        isObserving = true
    }
    
    func remove() {
        isObserving = false
        collectionView?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "contentOffset" else { return }
        
        if let contentOffset = (object as? UICollectionView)?.contentOffset {
            offset = contentOffset
        }
    }
}


struct FindCollectionView: UIViewRepresentable {
    var result: (UICollectionView) -> ()
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let collectionView = view.collectionSuperview {
                print(collectionView)
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
            // Update logic if needed
    }
}

extension UIView {
    // Finding the CollectionView by traversing the superview
    var collectionSuperview: UICollectionView? {
        if let collectionView = superview as? UICollectionView {
            return collectionView
        }
        return superview?.collectionSuperview
    }
}
