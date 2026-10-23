//
//  NotificationOption.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/7/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import Foundation

/// How often a contact's general CatchUp reminder repeats.
///
/// The raw values are persisted in `SelectedContact.notification_preference`,
/// so they must never change.
nonisolated enum NotificationOption: Int, CaseIterable, Identifiable, Sendable {
    case never = 0
    case daily = 1
    case weekly = 2
    case monthly = 3
    case quarterly = 4
    case annually = 5
    case custom = 6

    var id: Self { self }

    /// The user-facing name shown in the "How often?" picker.
    var title: LocalizedStringResource {
        switch self {
        case .never: "Never"
        case .daily: "Daily"
        case .weekly: "Weekly"
        case .monthly: "Monthly"
        case .quarterly: "Quarterly"
        case .annually: "Annually"
        case .custom: "Custom"
        }
    }
}
