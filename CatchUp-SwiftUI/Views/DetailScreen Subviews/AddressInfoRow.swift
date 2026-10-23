//
//  AddressInfoRow.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import MapKit
import SwiftUI

struct AddressInfoRow: View {
    let title: LocalizedStringKey
    let address: String

    @State private var geocodingErrorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption)

            Button(address, action: openInMaps)
                .foregroundStyle(.blue)
        }
        .alert("Couldn't open in Maps", item: $geocodingErrorMessage) { _ in
        } message: { message in
            Text(message)
        }
    }

    private func openInMaps() {
        Task {
            await openAddressInMaps()
        }
    }

    private func openAddressInMaps() async {
        guard let request = MKGeocodingRequest(addressString: address) else {
            geocodingErrorMessage = "That address couldn't be parsed."
            return
        }
        do {
            let mapItems = try await request.mapItems
            guard let destination = mapItems.first else {
                geocodingErrorMessage = "No matching location was found."
                return
            }
            MKMapItem.openMaps(with: [destination])
        } catch {
            geocodingErrorMessage = error.localizedDescription
        }
    }
}

#Preview {
    List {
        AddressInfoRow(title: "Address", address: "2190 E 11th Ave")
    }
}
