//
//  NextCatchUpsGridCell.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct NextCatchUpsGridCell: View {
    @Environment(\.colorScheme) private var colorScheme

    let contact: SelectedContact
    @Binding var selection: SelectedContact?

    var body: some View {
        Button(action: select) {
            HStack {
                ContactPictureView(picture: contact.picture)
                    .padding(.trailing, 5)

                VStack(alignment: .leading, spacing: 2) {
                    Text(ContactHelper.firstName(for: contact))
                        .font(.headline)
                        .lineLimit(1)

                    Text(ContactHelper.friendlyNextCatchUpTime(for: contact, forQuarterlyPreference: false))
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 55, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(cellBackground, in: .capsule)
            .shadow(
                color: colorScheme == .light ? Color.gray.opacity(0.4) : .clear,
                radius: 3,
                x: 0,
                y: 2
            )
            .contentShape(.capsule)
        }
        .buttonStyle(.plain)
    }

    private var cellBackground: Color {
        colorScheme == .light ? .white : Color(red: 0.15, green: 0.15, blue: 0.15)
    }

    private func select() {
        selection = contact
    }
}

#Preview {
    NextCatchUpsGridCell(contact: .sampleData, selection: .constant(nil))
}
