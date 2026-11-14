//
//  UNAuthorizationStatus+Scheduling.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 11/13/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import UserNotifications

extension UNAuthorizationStatus {
    /// Whether the app may add notification requests with this permission.
    ///
    /// Provisional and ephemeral permission deliver notifications too, just more quietly
    /// or for a limited time.
    nonisolated var allowsScheduling: Bool {
        switch self {
        case .authorized, .provisional, .ephemeral:
            true
        case .notDetermined, .denied:
            false
        @unknown default:
            false
        }
    }
}
