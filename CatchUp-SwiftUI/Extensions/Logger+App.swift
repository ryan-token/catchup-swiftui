//
//  Logger+App.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import OSLog

extension Logger {
    private nonisolated static let subsystem = Bundle.main.bundleIdentifier ?? "CatchUp"

    /// Scheduling, purging, and reconciling local notifications.
    nonisolated static let notifications = Logger(subsystem: subsystem, category: "Notifications")

    /// Reading from the Contacts store and formatting contact details.
    nonisolated static let contacts = Logger(subsystem: subsystem, category: "Contacts")

    /// In-app purchases for the tip jar.
    nonisolated static let store = Logger(subsystem: subsystem, category: "Store")
}
