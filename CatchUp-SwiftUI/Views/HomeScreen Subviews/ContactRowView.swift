//
//  ContactRowView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/10/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct ContactRowView: View {
    let contact: SelectedContact
    /// The time the unread indicator is evaluated against.
    let referenceDate: Date

    var body: some View {
        HStack {
            ContactPictureView(picture: contact.picture)

            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name)
                    .font(.headline)

                Text(Converter.notificationPreferenceDescription(for: contact))
                    .font(.caption)
                    // A hierarchical style adapts to the selection highlight on its own.
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Circle()
                .fill(.orange)
                .frame(width: 15, height: 15)
                .padding(.horizontal)
                .opacity(isUnread ? 1 : 0)
                .accessibilityLabel("Unread")
                .accessibilityHidden(!isUnread)
        }
    }

    private var isUnread: Bool {
        contact.isUnread(at: referenceDate)
    }
}

#Preview {
    List {
        ContactRowView(contact: .sampleData, referenceDate: .now)
    }
}
