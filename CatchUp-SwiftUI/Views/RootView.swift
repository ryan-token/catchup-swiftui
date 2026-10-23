//
//  RootView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

/// The root of each window: a sidebar of contacts beside the selected contact's details.
///
/// The selection lives here, above the split view, so it survives the split view
/// collapsing and expanding — for example when iPhone Duo folds or unfolds, or an
/// iPad window resizes. Each window owns its own selection.
struct RootView: View {
    @State private var selectedContact: SelectedContact?

    var body: some View {
        NavigationSplitView {
            HomeScreen(selection: $selectedContact)
        } detail: {
            // A contact deleted on another device can lose its context without being marked deleted.
            if let selectedContact, !selectedContact.isDeleted, selectedContact.modelContext != nil {
                DetailScreen(contact: selectedContact, selection: $selectedContact)
                    // Give each contact fresh detail state.
                    .id(selectedContact.id)
            } else {
                NoContactSelectedScreen()
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(PreviewSampleData.container)
        .environment(LaunchCoordinator())
}
