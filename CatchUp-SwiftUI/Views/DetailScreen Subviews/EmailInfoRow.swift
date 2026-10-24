//
//  EmailInfoRow.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct EmailInfoRow: View {
    @Environment(\.openURL) private var openURL

    let title: LocalizedStringKey
    let email: String

    @State private var isShowingEmailAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption)

            Button(email, action: confirmEmail)
                .foregroundStyle(.blue)
        }
        .alert("Email \(email)?", isPresented: $isShowingEmailAlert) {
            if let url = Converter.tappableEmail(from: email) {
                Button("Yes") {
                    openURL(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func confirmEmail() {
        isShowingEmailAlert = true
    }
}

#Preview {
    List {
        EmailInfoRow(title: "Email", email: "test@example.com")
    }
}
