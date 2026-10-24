//
//  AboutScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/19/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

/// The About sheet: its navigation stack and close button.
struct AboutScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            // The header names the app, so the bar carries only the close button.
            AboutScreenContent()
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
    AboutScreen()
}
