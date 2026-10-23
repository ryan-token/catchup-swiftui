//
//  NotificationHelper.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/21/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import OSLog
import UserNotifications

/// Schedules each contact's general, birthday, and anniversary notifications.
///
/// Date calculations live in `NotificationHelper+Dates.swift`, and purging and
/// reconciliation live in `NotificationHelper+Maintenance.swift`.
enum NotificationHelper {
    private enum Category {
        static let general = "catchup.general"
        static let birthday = "catchup.birthday"
        static let anniversary = "catchup.anniversary"
    }

    static func createNewNotification(for contact: SelectedContact) async {
        if contact.notificationOption == .never && !contact.hasBirthday && !contact.hasAnniversary {
            contact.next_notification_date_time = ""
            return
        }

        updateNextNotificationDateTimeFor(contact: contact)

        let isAuthorized = await checkNotificationAuthorizationStatusAndAddRequest()
        guard isAuthorized else { return }

        if contact.notificationOption != .never {
            await addGeneralNotification(for: contact)
        }
        if contact.hasBirthday {
            await addBirthdayNotification(for: contact)
        }
        if contact.hasAnniversary {
            await addAnniversaryNotification(for: contact)
        }
    }

    /// Schedules the general reminder: one repeating request for each of its triggers.
    static func addGeneralNotification(for contact: SelectedContact) async {
        let identifiers = contact.notificationOption == .quarterly
            ? NotificationID.quarters(contact)
            : [NotificationID.general(contact)]

        for (identifier, components) in zip(identifiers, generalDateComponents(for: contact)) {
            let content = UNMutableNotificationContent()
            content.title = "👋 CatchUp with \(contact.name)"
            content.body = NotificationMessages.randomGeneralBody()

            await scheduleNotification(
                identifier: identifier,
                category: Category.general,
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true),
                for: contact
            )
        }
    }

    static func addBirthdayNotification(for contact: SelectedContact) async {
        guard var dateComponents = getBirthdayDateComponents(for: contact) else {
            Logger.notifications.error("Skipping a birthday notification with an unreadable date")
            return
        }
        dateComponents.calendar = gregorian()

        let content = UNMutableNotificationContent()
        content.title = "🥳 Today is \(contact.name)'s birthday!"
        content.body = "Be sure to CatchUp and wish them a great one!"

        await scheduleNotification(
            identifier: NotificationID.birthday(contact),
            category: Category.birthday,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true),
            for: contact
        )
    }

    static func addAnniversaryNotification(for contact: SelectedContact) async {
        guard var dateComponents = getAnniversaryDateComponents(for: contact) else {
            Logger.notifications.error("Skipping an anniversary notification with an unreadable date")
            return
        }
        dateComponents.calendar = gregorian()

        let content = UNMutableNotificationContent()
        content.title = "😍 Tomorrow is \(contact.name)'s anniversary!"
        content.body = "Be sure to CatchUp and wish them the best."

        await scheduleNotification(
            identifier: NotificationID.anniversary(contact),
            category: Category.anniversary,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true),
            for: contact
        )
    }

    static func checkNotificationAuthorizationStatusAndAddRequest() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        if settings.authorizationStatus == .authorized {
            return true
        }

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            Logger.notifications.info("Notification authorization granted: \(granted)")
            return granted
        } catch {
            Logger.notifications.error("Error requesting notification authorization: \(error)")
            return false
        }
    }

    private static func scheduleNotification(
        identifier: String,
        category: String,
        content: UNMutableNotificationContent,
        trigger: UNNotificationTrigger,
        for contact: SelectedContact
    ) async {
        content.sound = .default
        content.badge = 1
        // Thread and category identifiers group and filter notifications per contact.
        content.threadIdentifier = NotificationID.thread(contact)
        content.categoryIdentifier = category

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            Logger.notifications.error("Failed to schedule notification \(identifier): \(error)")
        }
    }

    /// Recalculates the stored next date, writing only when it changed so unchanged
    /// contacts don't re-render or sync.
    static func updateNextNotificationDateTimeFor(contact: SelectedContact) {
        let next = getNextNotificationDateFor(contact: contact)
        if contact.next_notification_date_time != next {
            contact.next_notification_date_time = next
        }
    }
}
