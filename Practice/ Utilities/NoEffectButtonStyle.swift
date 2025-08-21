//
//  NoEffectButtonStyle.swift
//  Practice
//
//  Created by Hafizur Rahman on 21/8/25.
//

import SwiftUI

struct NoEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 1.0 : 1.0)
    }
}
