//
//  Utils.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/28/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import Foundation
import OSLog
import UserNotifications

enum Utils {
    static func clearAppIconNotificationBadge() async {
        do {
            try await UNUserNotificationCenter.current().setBadgeCount(0)
        } catch {
            Logger.notifications.error("Failed to clear the app icon badge: \(error)")
        }
    }

    /// The marketing version, such as "3.2.3".
    nonisolated static var currentAppVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    /// Whether the given version is a major release, such as "4.0".
    nonisolated static func updateIsMajor(version: String = currentAppVersion) -> Bool {
        version.hasSuffix(".0")
    }
}
