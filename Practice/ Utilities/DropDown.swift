import SwiftUI

struct DropdownMenu: View {
    @State var selectedOption: String
    @State var isExpanded = false
    @State var menuWidth: CGFloat = 0
    var dropdownAlignment: DropdownAlignment = .center
    var frameAlignment: Alignment {
        switch dropdownAlignment {
            case .leading: return .leading
            case .center: return .center
            case .trailing: return .trailing
        }
    }
    var showIcon: Bool = false
    var fromTop: Bool = true
    
    var transitionAnchor: UnitPoint {
        if fromTop {
            return dropdownAlignment == .leading ? .leading :
            dropdownAlignment == .center ? .center :
                .trailing
        } else {
            return dropdownAlignment == .leading ? .topLeading :
            dropdownAlignment == .center ? .top :
                .topTrailing
        }
    }
    
    let options: [DropdownOption]
    
    var body: some View {
        ZStack {
            Button(action: {
                isExpanded.toggle()
            }) {
                Text(selectedOption)
                    .font(.system(size: 14))
                    .frame(width: 50, height: 40)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
                    .foregroundStyle(.white.opacity(0.9))
            }
            .tint(.primary)
            .frame(height: 50)
            .frame(width: menuWidth, alignment: frameAlignment)
            .overlay(alignment: fromTop ? .bottom : .top) {
                if isExpanded {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(options) { option in
                            HStack(spacing: 8) {
                                if showIcon, let iconName = option.icon {
                                    Image(systemName: iconName)
                                        .frame(width: 20, height: 20)
                                }
                                Text(option.title)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            .foregroundColor(option.color)
                            .padding(.vertical, 5)
                            .onTapGesture {
                                option.action()
                                withAnimation {
                                    isExpanded = false
                                    selectedOption = option.title
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.mainBackground)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
                    )
                    .offset(y: fromTop ? -50 : 50)
                    .fixedSize()
                    .transition(
                        .scale(scale: 0, anchor: transitionAnchor)
                        .combined(with: .opacity)
                        .combined(with: .offset(y: 40))
                    )
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    menuWidth = proxy.size.width
                                }
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: frameAlignment)
            .animation(.smooth, value: isExpanded)
        }
    }
    
    init(dropdownAlignment: DropdownAlignment = .center, fromTop: Bool = true, options: [DropdownOption]) {
        self.dropdownAlignment = dropdownAlignment
        self.fromTop = fromTop
        self.options = options
        self._selectedOption = State(initialValue: options.first?.title ?? "CSE")
    }
}

#Preview {
    DropdownMenu(dropdownAlignment: .center, fromTop: true, options: [
        DropdownOption(title: "CSE", action: { print("Show CSE details") }),
        DropdownOption(title: "SWE", action: { print("Show SWE details") }),
    ])
}



    //        DropdownOption(title: "MCT", action: { print("Show MCT details") }),
    //        DropdownOption(title: "EEE", action: { print("Show EEE details") }),
    //        DropdownOption(title: "NFE", action: { print("Show NFE details") }),
    //        DropdownOption(title: "TE", action: { print("Show TE details") }),
    //        DropdownOption(title: "ENG", action: { print("Show ENG details") })
