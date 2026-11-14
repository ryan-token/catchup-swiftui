//
//  SelectedContact+Unread.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 11/13/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import Foundation

extension SelectedContact {
    /// Whether the contact's unread indicator shows at the given time: once a reminder
    /// has fired since the contact was last viewed.
    ///
    /// Stored times are zero-padded, so comparing the strings compares the dates.
    func isUnread(at date: Date) -> Bool {
        guard !unread_badge_date_time.isEmpty else { return false }
        return StoredDateFormat.string(from: date) >= unread_badge_date_time
    }

    /// Clears the unread indicator until the contact's next reminder fires.
    ///
    /// Recalculates the next reminder first: when the contact is opened from the
    /// notification that just fired, the stored next time is that notification's, which
    /// has already passed and would leave the indicator showing.
    ///
    /// Main-actor isolated like the date calculations it relies on; the model is
    /// nonisolated, so the extension doesn't inherit the target's default isolation.
    @MainActor
    func markAsRead(now: Date = .now, calendar: Calendar = .current) {
        NotificationHelper.updateNextNotificationDateTimeFor(contact: self, now: now, calendar: calendar)
        if unread_badge_date_time != next_notification_date_time {
            unread_badge_date_time = next_notification_date_time
        }
    }
}
