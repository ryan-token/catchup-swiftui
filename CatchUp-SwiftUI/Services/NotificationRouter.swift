//
//  NotificationRouter.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/23/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import Foundation
import Observation
import UserNotifications

/// Opens the contact whose notification the user tapped.
///
/// Becomes the notification center's delegate at launch, early enough to receive the
/// tap that launched the app. A window's root view then shows the contact.
@Observable
final class NotificationRouter: NSObject, @MainActor UNUserNotificationCenterDelegate {
    /// The contact whose notification was tapped, until a window shows it.
    private(set) var pendingContactID: UUID?

    /// Returns the tapped contact's ID once, so only one window opens it.
    func takePendingContactID() -> UUID? {
        defer { pendingContactID = nil }
        return pendingContactID
    }

    /// Records the contact a tapped notification belongs to, read from its stable identifier or thread.
    func notificationTapped(identifier: String, threadIdentifier: String) {
        let uuidString = NotificationID.extractContactUUID(from: identifier)
            ?? NotificationID.extractContactUUID(from: threadIdentifier)
        pendingContactID = uuidString.flatMap(UUID.init(uuidString:))
    }

    #if DEBUG
    /// Opens a contact as a tapped notification would, for screenshot mode.
    func open(contactID: UUID) {
        pendingContactID = contactID
    }
    #endif

    /// Main-actor isolated, because the system's completion handler behind this async
    /// method runs when it returns, and UIKit requires that on the main thread.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let request = response.notification.request
        notificationTapped(identifier: request.identifier, threadIdentifier: request.content.threadIdentifier)
    }
}
