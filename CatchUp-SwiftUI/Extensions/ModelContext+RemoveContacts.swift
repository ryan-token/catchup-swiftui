//
//  ModelContext+RemoveContacts.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/23/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftData

extension ModelContext {
    /// Deletes contacts and saves right away, then purges their notifications using
    /// keys captured beforehand, since the deleted contacts can no longer be read.
    func remove(_ contacts: [SelectedContact]) {
        let notificationKeys = contacts.map(ContactNotificationKeys.init)
        for contact in contacts {
            delete(contact)
        }
        do {
            try save()
        } catch {
            assertionFailure("Failed to save after deleting contacts: \(error)")
        }

        Task {
            await NotificationHelper.removeNotifications(matching: notificationKeys)
        }
    }
}
