//
//  DetailScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct DetailScreen: View {
    let contact: SelectedContact
    /// The split view's selection, cleared when this contact is removed.
    @Binding var selection: SelectedContact?

    @State private var preferenceModel = NotificationPreferenceModel()
    /// The space the navigation bar and status bar take above the list.
    @State private var topInset: CGFloat = 0
    @State private var isScrolledToTop = true

    var body: some View {
        List {
            // The header scrolls with the content, so short windows such as
            // iPhone Duo's outer display or a landscape iPhone keep room for the list.
            Section {
                DetailHeader(contact: contact, topInset: topInset)
            }
            .listSectionMargins(.horizontal, 0)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            Section {
                NextCatchUpRow(contact: contact)
                BirthdayOrAnniversaryRow(contact: contact)
            }

            Section("Notification Preference") {
                NotificationPreferenceView(model: preferenceModel)
            }

            if contact.hasContactInfo {
                Section("Contact Information") {
                    ContactInfoView(contact: contact)
                }
            }

            RemoveContactButton(contact: contact, selection: $selection)
        }
        .contentMargins(.top, 0, for: .scrollContent)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentInsets.top
        } action: { _, newInset in
            topInset = newInset
        }
        .onScrollGeometryChange(for: Bool.self) { geometry in
            geometry.contentOffset.y + geometry.contentInsets.top <= 0
        } action: { _, isAtTop in
            isScrolledToTop = isAtTop
        }
        // Let the gradient reach the top edge, keeping the fade for content scrolled under the bars.
        .scrollEdgeEffectHidden(isScrolledToTop, for: .top)
        .navigationTitle(contact.name)
        .toolbarTitleDisplayMode(.inline)
        // The header already shows the name; keep the title for VoiceOver and the back menu.
        .toolbar(removing: .title)
        .onChange(of: contact.id, initial: true) {
            preferenceModel.load(contact)
        }
        .task {
            Utils.clearUnreadBadge(for: contact)
            await Utils.clearAppIconNotificationBadge()
        }
    }
}

#Preview {
    @Previewable @State var selection: SelectedContact?

    NavigationStack {
        DetailScreen(contact: .sampleData, selection: $selection)
    }
}
