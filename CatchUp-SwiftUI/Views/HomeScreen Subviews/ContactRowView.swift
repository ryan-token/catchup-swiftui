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
                .opacity(shouldShowUnreadIndicator ? 1 : 0)
                .accessibilityLabel("Unread")
                .accessibilityHidden(!shouldShowUnreadIndicator)
        }
    }

    /// Shows once the stored unread time has passed. Stored times are zero-padded,
    /// so comparing the strings compares the dates.
    private var shouldShowUnreadIndicator: Bool {
        guard !contact.unread_badge_date_time.isEmpty else { return false }
        return StoredDateFormat.string(from: referenceDate) >= contact.unread_badge_date_time
    }
}

#Preview {
    List {
        ContactRowView(contact: .sampleData, referenceDate: .now)
    }
}
