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
                // Enhanced main button with better styling
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.1)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    Text(selectedOption)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                    
                    Image(systemName: "chevron.up")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isExpanded)
                }
                .padding(.horizontal, 12)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.teal.opacity(0.3),
                                    Color.teal.opacity(0.4)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                )
                .scaleEffect(isExpanded ? 0.95 : 1.0)
            }
            .frame(width: menuWidth > 0 ? menuWidth : nil, alignment: frameAlignment)
            .overlay(alignment: fromTop ? .bottom : .top) {
                if isExpanded {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                            HStack(spacing: 12) {
                                if showIcon, let iconName = option.icon {
                                    Image(systemName: iconName)
                                        .frame(width: 18, height: 18)
                                        .foregroundStyle(option.isDisabled ? .white.opacity(0.3) : .white.opacity(0.8))
                                }
                                
                                Text(option.title)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(option.isDisabled ? .white.opacity(0.4) : .white.opacity(0.9))
                                
                                Spacer()
                                
                                    // Enhanced tick mark with animation
                                if selectedOption == option.title && !option.isDisabled {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.teal.opacity(0.5))
                                        .font(.system(size: 16, weight: .semibold))
                                        .transition(.scale.combined(with: .opacity))
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedOption)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                Group {
                                    if option.isDisabled {
                                        Color.gray.opacity(0.15)
                                    } else if selectedOption == option.title {
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.blue.opacity(0.3),
                                                Color.blue.opacity(0.1)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    } else {
                                        Color.clear
                                    }
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        selectedOption == option.title && !option.isDisabled ?
                                        Color.blue.opacity(0.5) : Color.clear,
                                        lineWidth: 1
                                    )
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if !option.isDisabled {
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                    
                                    option.action()
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        isExpanded = false
                                        selectedOption = option.title
                                    }
                                }
                            }
                            .disabled(option.isDisabled)
                            .scaleEffect(option.isDisabled ? 0.98 : 1.0)
                            .opacity(isExpanded ? 1.0 : 0.0)
                            .animation(
                                .spring(response: 0.4, dampingFraction: 0.8)
                                .delay(Double(index) * 0.03),
                                value: isExpanded
                            )
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.black.opacity(0.1),
                                                Color.black.opacity(0.05)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 8)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .offset(y: fromTop ? -50 : 8)
                    .fixedSize()
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.8, anchor: transitionAnchor)
                                .combined(with: .opacity)
                                .combined(with: .offset(y: fromTop ? 10 : -10)),
                            removal: .scale(scale: 0.9, anchor: transitionAnchor)
                                .combined(with: .opacity)
                                .combined(with: .offset(y: fromTop ? 5 : -5))
                        )
                    )
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    menuWidth = max(menuWidth, proxy.size.width)
                                }
                                .onChange(of: proxy.size.width) { _, newWidth in
                                    menuWidth = max(menuWidth, newWidth)
                                }
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: frameAlignment)
            .zIndex(isExpanded ? 1000 : 1)
        }
    }
    
    init(dropdownAlignment: DropdownAlignment = .center, fromTop: Bool = true, options: [DropdownOption]) {
        self.dropdownAlignment = dropdownAlignment
        self.fromTop = fromTop
        self.options = options
            // Initialize with first non-disabled option
        let firstEnabledOption = options.first { !$0.isDisabled }
        self._selectedOption = State(initialValue: firstEnabledOption?.title ?? options.first?.title ?? "Select")
    }
}

#Preview {
    VStack(spacing: 60) {
        DropdownMenu(dropdownAlignment: .center, fromTop: true, options: [
            DropdownOption(title: "Computer Science", action: { print("Show CSE details") }),
            DropdownOption(title: "Software Engineering", action: { print("Show SWE details") }),
            DropdownOption(title: "Mechanical Engineering", isDisabled: true, action: { print("Show MCT details") }),
//            DropdownOption(title: "Electrical Engineering", action: { print("Show EEE details") }),
//            DropdownOption(title: "Naval Engineering", isDisabled: true, action: { print("Show NFE details") }),
//            DropdownOption(title: "Textile Engineering", action: { print("Show TE details") }),
//            DropdownOption(title: "English Literature", isDisabled: true, action: { print("Show ENG details") })
        ])
        
        Text("Enhanced UI with smooth spring animations\nDisabled options: Mechanical, Naval, English")
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
    }
    .padding(40)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        LinearGradient(
            gradient: Gradient(colors: [
                Color.black,
                Color.gray.opacity(0.9)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
