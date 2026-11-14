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
        guard contact.hasNotificationsToSchedule else {
            contact.next_notification_date_time = ""
            return
        }

        updateNextNotificationDateTimeFor(contact: contact)

        // Checked once per contact rather than per request: each check asks the system for
        // its settings, and a reset runs this for every contact while holding the gate.
        guard await canScheduleNotifications() else { return }

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

    /// Asks for permission to notify, the first time any of the contacts has a reminder to schedule.
    ///
    /// Asking only once there's a reminder keeps the prompt in context, as Apple recommends:
    /// it follows the user choosing a frequency or adding a contact with a birthday, or opening
    /// the app with reminders already set up, such as on a new device. The system prompts only
    /// while permission is undetermined, so later calls return without asking.
    ///
    /// Call this before entering `NotificationResetGate`, never inside it: the prompt stays up
    /// until the user answers, and would hold up every other notification change meanwhile.
    static func requestAuthorizationIfNeeded(for contacts: [SelectedContact]) async {
        guard contacts.contains(where: { !$0.isRemoved && $0.hasNotificationsToSchedule }) else { return }

        let center = UNUserNotificationCenter.current()
        guard await center.notificationSettings().authorizationStatus == .notDetermined else { return }

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            Logger.notifications.info("Notification authorization granted: \(granted)")
        } catch {
            Logger.notifications.error("Error requesting notification authorization: \(error)")
        }
    }

    /// The app's current notification permission, checked without asking.
    static func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    /// Whether the app may add notification requests, checked without asking.
    ///
    /// Without permission, adding a request fails with an error, so callers check this before
    /// scheduling; permission is asked for beforehand, by `requestAuthorizationIfNeeded(for:)`.
    static func canScheduleNotifications() async -> Bool {
        await authorizationStatus().allowsScheduling
    }

    /// Schedules a just-added contact's reminders, such as its birthday, rather than waiting
    /// for the next launch, and starts its unread indicator from its first reminder.
    static func scheduleNotifications(forAdded contact: SelectedContact) async {
        await requestAuthorizationIfNeeded(for: [contact])
        await NotificationResetGate.shared.run {
            guard !contact.isRemoved else { return }
            await createNewNotification(for: contact)
            contact.markAsRead()
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
    static func updateNextNotificationDateTimeFor(
        contact: SelectedContact,
        now: Date = .now,
        calendar: Calendar = .current
    ) {
        let next = getNextNotificationDateFor(contact: contact, now: now, calendar: calendar)
        if contact.next_notification_date_time != next {
            contact.next_notification_date_time = next
        }
    }
}
