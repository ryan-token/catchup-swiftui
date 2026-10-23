//
//  BirthdayOrAnniversaryRow.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/31/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

/// Celebrates when the next notification is the contact's birthday or the day before their anniversary.
struct BirthdayOrAnniversaryRow: View {
    let contact: SelectedContact

    var body: some View {
        if contact.hasBirthday, contact.next_notification_date_time.contains(contact.birthday) {
            Text("🥳 \(ContactHelper.firstName(for: contact))'s birthday!")
                .foregroundStyle(.orange)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.top, 2)
        } else if let anniversaryString = dayBeforeAnniversaryString(),
                  contact.next_notification_date_time == anniversaryString {
            Text("💜 The day before their anniversary!")
                .foregroundStyle(.purple)
                .multilineTextAlignment(.leading)
                .padding(.top, 2)
        }
    }

    private func dayBeforeAnniversaryString() -> String? {
        NotificationHelper.getAnniversaryDateComponents(for: contact)
            .map { NotificationHelper.calculateDateStringFromComponents($0) }
    }
}

#Preview {
    List {
        BirthdayOrAnniversaryRow(contact: .sampleData)
    }
}
