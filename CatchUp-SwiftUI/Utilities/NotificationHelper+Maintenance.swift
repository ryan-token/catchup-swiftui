//
//  NotificationHelper+Maintenance.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import UserNotifications

extension NotificationHelper {
    /// Removes every pending and delivered notification belonging to a contact.
    ///
    /// Matches by stable identifier, by thread identifier, and (defensively) by
    /// legacy UUID fields and by title, so it cleans up notifications scheduled
    /// by any previous version of the app.
    static func removeExistingNotifications(for contact: SelectedContact) async {
        await removeNotifications(matching: ContactNotificationKeys(contact))
    }

    /// Removes the notifications of deleted contacts, using keys captured before deletion.
    ///
    /// Waits for any reset in progress, so the reset can't re-add them afterward.
    static func removeNotifications(matching keys: [ContactNotificationKeys]) async {
        await NotificationResetGate.shared.run {
            for contactKeys in keys {
                await removeNotifications(matching: contactKeys)
            }
        }
    }

    private static func removeNotifications(matching keys: ContactNotificationKeys) async {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        let delivered = await center.deliveredNotifications()

        let pendingTargets = pending.filter(keys.matches).map(\.identifier)
        let deliveredTargets = delivered.map(\.request).filter(keys.matches).map(\.identifier)

        if !pendingTargets.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: pendingTargets)
        }
        if !deliveredTargets.isEmpty {
            center.removeDeliveredNotifications(withIdentifiers: deliveredTargets)
        }
    }

    /// Reconciles iOS's notification queue against the current SwiftData contact set.
    /// Cancels every pending or delivered notification whose embedded contact UUID
    /// doesn't match an existing contact, as well as any notification whose
    /// identifier doesn't follow the stable scheme at all (legacy entries).
    ///
    /// Run on every cold launch as defense-in-depth: if a removal ever fails to
    /// land — for any reason — the next launch reconciles it. The operation is
    /// idempotent and surgical (it does not touch valid notifications).
    static func cleanupOrphanedNotifications(for selectedContacts: [SelectedContact]) async {
        let validContactIds = Set(selectedContacts.map(\.id.uuidString))
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        let delivered = await center.deliveredNotifications()

        let isOrphan: (UNNotificationRequest) -> Bool = { request in
            let embedded = NotificationID.extractContactUUID(from: request.identifier)
                ?? NotificationID.extractContactUUID(from: request.content.threadIdentifier)
            guard let embedded else {
                // No recognizable stable-scheme contact UUID — treat as legacy.
                return true
            }
            return !validContactIds.contains(embedded)
        }

        let pendingOrphans = pending.filter(isOrphan).map(\.identifier)
        let deliveredOrphans = delivered.map(\.request).filter(isOrphan).map(\.identifier)

        if !pendingOrphans.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: pendingOrphans)
        }
        if !deliveredOrphans.isEmpty {
            center.removeDeliveredNotifications(withIdentifiers: deliveredOrphans)
        }
    }

    /// One-time "nuclear" reset: cancels every pending and delivered notification
    /// belonging to this app, then re-schedules from the current SwiftData contact
    /// set as the single source of truth. Used once on next launch (gated by
    /// `@AppStorage`) to recover from notifications stranded by past builds whose
    /// removal code targeted the wrong identifiers.
    static func performOneTimeNuclearReset(for selectedContacts: [SelectedContact]) async {
        await NotificationResetGate.shared.run {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
            center.removeAllDeliveredNotifications()

            // Give the system a moment to settle before re-scheduling.
            try? await Task.sleep(for: .milliseconds(200))

            // `createNewNotification` short-circuits for contacts with nothing to
            // schedule, so we can iterate the full set without an extra filter.
            for contact in selectedContacts where !contact.isRemoved {
                await createNewNotification(for: contact)
            }
        }
    }

    /// Purges and re-schedules every contact's notifications.
    ///
    /// The loops deliberately don't stop on cancellation: abandoning the work after
    /// the purge phase would leave contacts without their scheduled reminders.
    static func resetNotifications(for selectedContacts: [SelectedContact], delayTime: Double) async {
        // Serialize concurrent resets — both the purge and the reschedule run inside
        // the gate, so two interleaved callers can't fight over the notification queue.
        await NotificationResetGate.shared.run {
            if delayTime > 0 {
                try? await Task.sleep(for: .seconds(delayTime))
            }

            // Contacts deleted since the caller captured them have had their notifications
            // purged already, and can't be read. Checked on each pass, since a contact can
            // be deleted while an earlier one is awaited.

            // Phase 1: Purge all existing notifications for each contact.
            for contact in selectedContacts where !contact.isRemoved {
                await removeExistingNotifications(for: contact)
            }

            // Phase 2: Re-schedule notifications with stable identifiers. This includes
            // contacts set to Never, which still get birthday and anniversary reminders.
            for contact in selectedContacts where !contact.isRemoved {
                await createNewNotification(for: contact)
            }

            let needsUnreadTime = { (contact: SelectedContact) in
                !contact.isRemoved && !isComparableUnreadTime(contact.unread_badge_date_time)
            }
            for contact in selectedContacts where needsUnreadTime(contact) {
                contact.unread_badge_date_time = contact.next_notification_date_time
            }
        }
    }

    /// Whether a stored unread time can be compared against the current time.
    ///
    /// Empty means none has been set. Older versions wrote it in the device's calendar and
    /// clock format, which can fail to parse, or parse to a year centuries away, such as
    /// 2569 from the Buddhist calendar or 0008 from the Japanese one.
    nonisolated static func isComparableUnreadTime(_ string: String, now: Date = .now) -> Bool {
        // Parsing ignores trailing text such as " AM", so also require the exact format.
        guard let date = StoredDateFormat.date(from: string),
              StoredDateFormat.string(from: date) == string else {
            return false
        }
        let century: TimeInterval = 100 * 365 * 86_400
        return abs(date.timeIntervalSince(now)) < century
    }
}
