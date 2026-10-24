//
//  ContactSnapshot.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 11/18/2025.
//  Copyright © 2025 Token Solutions. All rights reserved.
//

/// Sendable snapshot of the fields we pull off `CNContact`, so a Contacts
/// lookup can happen off the main actor and the values can be ferried back
/// without dragging the non-Sendable `CNContact` across the boundary.
nonisolated struct ContactSnapshot: Sendable, Equatable {
    var name: String
    var phone: String
    var secondaryPhone: String
    var email: String
    var secondaryEmail: String
    var address: String
    var secondaryAddress: String
    var picture: String
    var birthday: String
    var anniversary: String
}
