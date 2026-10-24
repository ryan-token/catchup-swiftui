//
//  ReviewOnAppStoreButton.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

/// Opens CatchUp's "Write a Review" page in the App Store.
struct ReviewOnAppStoreButton: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button(action: openReviewPage) {
            CalloutButtonView(title: "Review on the App Store", color: .orange)
        }
    }

    private func openReviewPage() {
        openURL(Constants.writeReviewURL)
    }
}

#Preview {
    ReviewOnAppStoreButton()
        .padding()
}
