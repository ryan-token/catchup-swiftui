//
//  UpdatesScreenContent.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

/// The scrolling release notes shown after a major update.
struct UpdatesScreenContent: View {
    private static let currentVersionNotes: [String] = [
        "Designed for iPhone Duo, with your contacts and their details side by side on the inner display",
        "Tapping a reminder notification now opens that contact",
        "Bug fixes & performance improvements"
    ]

    private static let version3Notes: [String] = [
        "A grid of your next CatchUps",
        "Pull-to-refresh photo & contact information for your selected contacts",
        "Unread indicators for contacts it's time to CatchUp with",
        "Automatic cloud syncing with other Apple devices",
        "UI redesign",
        "Significant under-the-hood improvements"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                UpdatesScreenHeader()

                ReleaseNotesSection(notes: Self.currentVersionNotes)

                Text("***From version 3.0***:")
                    .padding(.top)

                ReleaseNotesSection(notes: Self.version3Notes)

                ReviewOnAppStoreButton()
                    .padding(.vertical)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    UpdatesScreenContent()
}
