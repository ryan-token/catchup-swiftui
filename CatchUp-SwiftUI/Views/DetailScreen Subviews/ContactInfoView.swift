//
//  ContactInfoView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/10/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

/// One list row for each piece of contact information the contact has.
struct ContactInfoView: View {
    let contact: SelectedContact

    var body: some View {
        if contact.hasPhone {
            PhoneInfoRow(title: "Phone", phoneNumber: contact.phone)
        }

        if contact.hasSecondaryPhone {
            PhoneInfoRow(title: "Secondary Phone", phoneNumber: contact.secondary_phone)
        }

        if contact.hasEmail {
            EmailInfoRow(title: "Email", email: contact.email)
        }

        if contact.hasSecondaryEmail {
            EmailInfoRow(title: "Secondary Email", email: contact.secondary_email)
        }

        if contact.hasAddress {
            AddressInfoRow(title: "Address", address: contact.address)
        }

        if contact.hasSecondaryAddress {
            AddressInfoRow(title: "Secondary Address", address: contact.secondary_address)
        }

        if contact.hasBirthday {
            BirthdayInfoRow(contact: contact)
        }

        if contact.hasAnniversary {
            AnniversaryInfoRow(contact: contact)
        }
    }
}

#Preview {
    List {
        ContactInfoView(contact: .sampleData)
    }
}
