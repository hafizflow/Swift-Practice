//
//  DropdownOption.swift
//  Practice
//
//  Created by Hafizur Rahman on 16/8/25.
//

import SwiftUI

struct DropdownOption: Identifiable {
    let id = UUID()
    var title: String
    var color: Color = .primary
    var icon: String? = nil
    var action: () -> Void
}

enum DropdownAlignment {
    case leading
    case center
    case trailing
}
