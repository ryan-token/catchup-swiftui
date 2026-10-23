//
//  UpdatesScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/29/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

/// The release notes sheet: its navigation stack and close button.
struct UpdatesScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            // The header shows the title, so the bar carries only the close button.
            UpdatesScreenContent()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .close, action: close)
                    }
                }
        }
    }

    private func close() {
        dismiss()
    }
}

#Preview {
    UpdatesScreen()
}
