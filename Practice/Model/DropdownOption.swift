import SwiftUI

    // Updated DropdownOption structure
struct DropdownOption: Identifiable {
    let id = UUID()
    let title: String
    let icon: String?
    let color: Color
    let isDisabled: Bool
    let action: () -> Void
    
    init(title: String, icon: String? = nil, color: Color = .primary, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.isDisabled = isDisabled
        self.action = action
    }
}

enum DropdownAlignment {
    case leading, center, trailing
}
