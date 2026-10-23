//
//  AboutScreenContent.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

/// The scrolling content of the About sheet.
struct AboutScreenContent: View {
    @State private var isShowingUpdateScreen = false

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                AboutScreenHeader()

                OrangeDivider()
                    .padding(.bottom)

                TipJarSection()

                OrangeDivider()

                ReviewOnAppStoreButton()
                    .padding(.vertical)

                Button("Show Latest Update Details", action: showUpdateScreen)
                    .font(.headline)
                    .foregroundStyle(.blue)
                    .padding(.bottom)
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $isShowingUpdateScreen) {
            UpdatesScreen()
        }
    }

    private func showUpdateScreen() {
        isShowingUpdateScreen = true
    }
}

#Preview {
    AboutScreenContent()
}
