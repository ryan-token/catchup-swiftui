//
//  NotificationPreferenceModel.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import Foundation
import Observation
import UserNotifications

/// Backs the reminder preference pickers, writing each edit to the contact and
/// rescheduling its general notification.
///
/// The pickers bind to this model rather than to the contact, so only the user's own
/// edits have side effects. Changes synced from another device, or made in another
/// window, update the pickers without picking a new week or rescheduling here.
@Observable
final class NotificationPreferenceModel {
    nonisolated static let weeklyDayPrompt = "What day?"
    nonisolated static let monthlyDayPrompt = "What day? We'll pick a random week."

    /// The contact being edited, set by `load(_:)`.
    private(set) var contact: SelectedContact?

    /// The pending debounced reschedule, if any.
    @ObservationIgnored private(set) var resetTask: Task<Void, Never>?
    @ObservationIgnored private let calendar: Calendar
    /// How long edits are batched before rescheduling.
    @ObservationIgnored private let debounce: Duration
    /// Reschedules the contact's notifications after an edit.
    @ObservationIgnored private let reschedule: Reschedule

    typealias Reschedule = @MainActor (SelectedContact) async -> Void

    /// - Parameters:
    ///   - calendar: The calendar the time and custom date pickers' values are read in.
    ///   - debounce: Shortened in tests.
    ///   - reschedule: Replaced in tests, which shouldn't touch the notification center.
    init(
        calendar: Calendar = .current,
        debounce: Duration = .milliseconds(300),
        reschedule: @escaping Reschedule = resetGeneralNotification
    ) {
        self.calendar = calendar
        self.debounce = debounce
        self.reschedule = reschedule
    }

    func load(_ contact: SelectedContact) {
        self.contact = contact
    }

    // MARK: Picker values

    var preference: NotificationOption {
        get { contact?.notificationOption ?? .never }
        set {
            guard let contact, newValue != contact.notificationOption else { return }
            contact.notification_preference = newValue.rawValue

            switch newValue {
            case .weekly:
                contact.notification_preference_week_of_month = 0
            case .monthly:
                contact.notification_preference_week_of_month = .random(in: 2..<5)
            case .quarterly:
                contact.notification_preference_quarterly_set_time = .now
            case .annually:
                NotificationHelper.setYearPreference(for: contact, calendar: calendar)
            case .never, .daily, .custom:
                break
            }

            scheduleDebouncedReset()
        }
    }

    /// The weekday picker's label, which differs for weekly and monthly reminders.
    var whatDayText: String {
        switch preference {
        case .weekly: Self.weeklyDayPrompt
        case .monthly: Self.monthlyDayPrompt
        default: ""
        }
    }

    var weekday: Int {
        get { contact?.notification_preference_weekday ?? 1 }
        set { update(\.notification_preference_weekday, to: newValue) }
    }

    var month: Int {
        get { contact?.notification_preference_custom_month ?? 1 }
        set { update(\.notification_preference_custom_month, to: newValue) }
    }

    var day: Int {
        get { contact?.notification_preference_custom_day ?? 1 }
        set { update(\.notification_preference_custom_day, to: newValue) }
    }

    /// The time picker's value, today at the contact's reminder time.
    var time: Date {
        get {
            guard let contact else { return .now }
            return calendar.date(
                bySettingHour: contact.notification_preference_hour,
                minute: contact.notification_preference_minute,
                second: 0,
                of: .now
            ) ?? .now
        }
        set {
            let components = calendar.dateComponents([.hour, .minute], from: newValue)
            guard let hour = components.hour, let minute = components.minute else { return }
            update([
                (\.notification_preference_hour, hour),
                (\.notification_preference_minute, minute)
            ])
        }
    }

    /// The custom date picker's value. Only its year, month, and day are used.
    var customDate: Date {
        get {
            guard let contact else { return .now }
            return calendar.date(from: DateComponents(
                year: contact.notification_preference_custom_year,
                month: contact.notification_preference_custom_month,
                day: contact.notification_preference_custom_day
            )) ?? .now
        }
        set {
            let components = calendar.dateComponents([.year, .month, .day], from: newValue)
            guard let year = components.year, let month = components.month, let day = components.day else { return }
            update([
                (\.notification_preference_custom_year, year),
                (\.notification_preference_custom_month, month),
                (\.notification_preference_custom_day, day)
            ])
        }
    }

    // MARK: Rescheduling

    private func update(_ keyPath: ReferenceWritableKeyPath<SelectedContact, Int>, to newValue: Int) {
        update([(keyPath, newValue)])
    }

    /// Writes the values that changed, then reschedules if any did.
    private func update(_ values: [(ReferenceWritableKeyPath<SelectedContact, Int>, Int)]) {
        guard let contact else { return }
        let changes = values.filter { keyPath, newValue in contact[keyPath: keyPath] != newValue }
        guard !changes.isEmpty else { return }

        for (keyPath, newValue) in changes {
            contact[keyPath: keyPath] = newValue
        }
        scheduleDebouncedReset()
    }

    /// Shows the edit's next date right away, and batches rapid edits into one reschedule.
    /// A pending reschedule is replaced by the next edit, but finishes even if the detail
    /// view closes in the meantime.
    private func scheduleDebouncedReset() {
        guard let contact else { return }

        // The date doesn't depend on the reschedule, which waits for the debounce and
        // does nothing without notification permission.
        NotificationHelper.updateNextNotificationDateTimeFor(contact: contact)

        resetTask?.cancel()
        resetTask = Task {
            try? await Task.sleep(for: debounce)
            guard !Task.isCancelled else { return }
            await reschedule(contact)
        }
    }

    private static func resetGeneralNotification(for contact: SelectedContact) async {
        let authorized = await NotificationHelper.checkNotificationAuthorizationStatusAndAddRequest()
        guard authorized else { return }

        // Inside the gate, so a reset or a deletion's purge can't interleave with it.
        await NotificationResetGate.shared.run {
            // The contact may have been deleted while this waited.
            guard !contact.isRemoved else { return }

            // Replace the general notification, whichever identifiers its old frequency used.
            await UNUserNotificationCenter.current().remove(NotificationID.allGeneral(contact))
            if contact.notificationOption != .never {
                await NotificationHelper.addGeneralNotification(for: contact)
            }
        }
    }
}
