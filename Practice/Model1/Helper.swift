//
//  Helper.swift
//  Swift Data
//
//  Created by Hafizur Rahman on 3/9/25.
//

import SwiftUI

    // MARK: - Helpers
extension String {
    func nilIfEmpty() -> String? {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : self
    }
}
