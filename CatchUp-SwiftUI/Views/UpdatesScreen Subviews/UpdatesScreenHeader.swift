//
//  UpdatesScreenHeader.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct UpdatesScreenHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("New Update")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.orange)
                .accessibilityAddTraits(.isHeader)

            Text("Version \(Utils.currentAppVersion)")
                .font(.headline)
                .foregroundStyle(.blue)

            Text("Release Notes:")
                .font(.headline)

            Divider()
        }
        .padding(.top, 10)
    }
}

#Preview {
    UpdatesScreenHeader()
}
