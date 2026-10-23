//
//  AnniversaryInfoRow.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct AnniversaryInfoRow: View {
    let contact: SelectedContact

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Anniversary")
                .font(.caption)

            Text(Converter.formattedBirthdayOrAnniversary(from: contact.anniversary))

            if contact.notificationOption != .never {
                Text("💜 We will notify you the day before their anniversary")
                    .foregroundStyle(.purple)
                    .multilineTextAlignment(.leading)
                    .font(.callout)
                    .padding(.top, 3)
            }
        }
    }
}

#Preview {
    AnniversaryInfoRow(contact: .sampleData)
}
