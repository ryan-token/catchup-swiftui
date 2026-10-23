//
//  NextCatchUpRow.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/29/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct NextCatchUpRow: View {
    let contact: SelectedContact

    var body: some View {
        // Reads only the next notification time, so this row updates when it changes.
        LabeledContent(
            "Next CatchUp:",
            value: ContactHelper.friendlyNextCatchUpTime(for: contact, forQuarterlyPreference: false)
        )
        .listRowSeparator(.hidden)
    }
}

#Preview {
    List {
        NextCatchUpRow(contact: .sampleData)
    }
}
