//
//  ContactNotificationKeys.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import UserNotifications

/// Everything needed to find a contact's notifications, captured as values so the
/// notifications can still be removed after the contact itself is deleted.
struct ContactNotificationKeys {
    let threadID: String
    let identifiers: Set<String>
    /// Titles used by versions of the app that didn't set stable identifiers.
    let legacyTitles: Set<String>

    init(_ contact: SelectedContact) {
        threadID = NotificationID.thread(contact)
        identifiers = [
            NotificationID.general(contact),
            NotificationID.birthday(contact),
            NotificationID.anniversary(contact),
            contact.notification_identifier.uuidString,
            contact.birthday_notification_id.uuidString,
            contact.anniversary_notification_id.uuidString
        ]
        legacyTitles = [
            "👋 CatchUp with \(contact.name)",
            "🥳 Today is \(contact.name)'s birthday!",
            "😍 Tomorrow is \(contact.name)'s anniversary!"
        ]
    }

    func matches(_ request: UNNotificationRequest) -> Bool {
        identifiers.contains(request.identifier)
            || request.content.threadIdentifier == threadID
            || legacyTitles.contains(request.content.title)
    }
}
