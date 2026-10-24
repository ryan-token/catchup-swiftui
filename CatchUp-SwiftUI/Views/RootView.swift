//
//  RootView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftData
import SwiftUI

/// The root of each window: a sidebar of contacts beside the selected contact's details.
///
/// The selection lives here, above the split view, so it survives the split view
/// collapsing and expanding — for example when iPhone Duo folds or unfolds, or an
/// iPad window resizes. Each window owns its own selection.
struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationRouter.self) private var notificationRouter

    @State private var selectedContact: SelectedContact?

    var body: some View {
        NavigationSplitView {
            HomeScreen(selection: $selectedContact)
        } detail: {
            if let selectedContact, !selectedContact.isRemoved {
                DetailScreen(contact: selectedContact, selection: $selectedContact)
                    // Give each contact fresh detail state.
                    .id(selectedContact.id)
            } else {
                NoContactSelectedScreen()
            }
        }
        // Initial, for the tap that launched the app.
        .onChange(of: notificationRouter.pendingContactID, initial: true) {
            openTappedContact()
        }
    }

    /// Shows the contact whose notification was tapped, if it still exists.
    private func openTappedContact() {
        guard let contactID = notificationRouter.takePendingContactID() else { return }

        var descriptor = FetchDescriptor<SelectedContact>(predicate: #Predicate { $0.id == contactID })
        descriptor.fetchLimit = 1
        if let contact = try? modelContext.fetch(descriptor).first {
            selectedContact = contact
        }
    }
}

#Preview {
    RootView()
        .modelContainer(PreviewSampleData.container)
        .environment(LaunchCoordinator())
        .environment(NotificationRouter())
}
