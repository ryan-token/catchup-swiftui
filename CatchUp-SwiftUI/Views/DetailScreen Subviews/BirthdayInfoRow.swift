//
//  BirthdayInfoRow.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct BirthdayInfoRow: View {
    let contact: SelectedContact

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Birthday")
                .font(.caption)

            Text(Converter.formattedBirthdayOrAnniversary(from: contact.birthday))

            if contact.notificationOption != .never {
                Text("🥳 We will notify you on their birthday")
                    .foregroundStyle(.orange)
                    .multilineTextAlignment(.leading)
                    .font(.callout)
                    .padding(.top, 3)
            }
        }
    }
}

#Preview {
    BirthdayInfoRow(contact: .sampleData)
}
