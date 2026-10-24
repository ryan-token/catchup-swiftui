//
//  PhoneInfoRow.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct PhoneInfoRow: View {
    @Environment(\.openURL) private var openURL

    let title: LocalizedStringKey
    let phoneNumber: String

    @State private var isShowingInvalidPhoneAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption)

            Button(Converter.formattedPhoneNumber(from: phoneNumber), action: call)
                .foregroundStyle(.blue)
        }
        .alert("Phone number is invalid", isPresented: $isShowingInvalidPhoneAlert) {
        } message: {
            Text("Could not dial this phone number. Ensure the number is correct in your Contacts app.")
        }
    }

    private func call() {
        if let url = Converter.tappablePhoneNumber(from: phoneNumber) {
            openURL(url)
        } else {
            isShowingInvalidPhoneAlert = true
        }
    }
}

#Preview {
    List {
        PhoneInfoRow(title: "Phone", phoneNumber: "6363687771")
    }
}
