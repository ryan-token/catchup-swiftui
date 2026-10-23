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

/// Owns the editing state for a contact's reminder preference, and reschedules the
/// contact's general notification as the preference changes.
@Observable
final class NotificationPreferenceModel {
    nonisolated static let weeklyDayPrompt = "What day?"
    nonisolated static let monthlyDayPrompt = "What day? We'll pick a random week."

    /// Marks a starting value as used, so returning to it still counts as an edit.
    private static let noInitialValue = -1

    /// The contact being edited, set by `load(_:calendar:)`.
    private(set) var contact: SelectedContact?

    /// The time picker's value. Only its hour and minute are used.
    var notificationPreferenceTime = Date.now
    /// The custom date picker's value. Only its year, month, and day are used.
    var notificationPreferenceCustomDate = Date.now
    /// The weekday picker's label, which differs for weekly and monthly reminders.
    private(set) var whatDayText = ""

    // The values loaded from the contact. Seeing one of these again is the initial
    // load rather than an edit, so it shouldn't reschedule anything.
    @ObservationIgnored private var initialPreference = NotificationOption.never.rawValue
    @ObservationIgnored private var initialWeekday = 1
    @ObservationIgnored private var initialTime = Date.now
    @ObservationIgnored private var initialCustomDate = Date.now
    @ObservationIgnored private var resetTask: Task<Void, Never>?
    /// Reschedules the contact's notifications after an edit.
    @ObservationIgnored private let reschedule: Reschedule

    typealias Reschedule = @MainActor (SelectedContact) async -> Void

    /// - Parameter reschedule: Replaced in tests, which shouldn't touch the notification center.
    init(reschedule: @escaping Reschedule = resetGeneralNotification) {
        self.reschedule = reschedule
    }

    /// Loads the pickers' values from a contact.
    func load(_ contact: SelectedContact, calendar: Calendar = .current) {
        self.contact = contact

        let time = calendar.date(from: DateComponents(
            calendar: calendar,
            hour: contact.notification_preference_hour,
            minute: contact.notification_preference_minute
        )) ?? .now

        let customDate = calendar.date(from: DateComponents(
            calendar: calendar,
            year: contact.notification_preference_custom_year,
            month: contact.notification_preference_custom_month,
            day: contact.notification_preference_custom_day
        )) ?? .now

        // Record the starting values before updating the pickers, so the resulting
        // change callbacks recognize them as the initial load.
        initialPreference = contact.notification_preference
        initialWeekday = contact.notification_preference_weekday
        initialTime = time
        initialCustomDate = customDate
        notificationPreferenceTime = time
        notificationPreferenceCustomDate = customDate

        whatDayText = switch contact.notificationOption {
        case .weekly: Self.weeklyDayPrompt
        case .monthly: Self.monthlyDayPrompt
        default: ""
        }
    }

    // MARK: Responding to edits

    func preferenceChanged(to newValue: Int) {
        guard let contact, newValue != initialPreference else { return }
        initialPreference = Self.noInitialValue

        switch NotificationOption(rawValue: newValue) {
        case .weekly:
            whatDayText = Self.weeklyDayPrompt
            contact.notification_preference_week_of_month = 0
        case .monthly:
            whatDayText = Self.monthlyDayPrompt
            contact.notification_preference_week_of_month = .random(in: 2..<5)
        case .quarterly:
            contact.notification_preference_quarterly_set_time = .now
        case .annually:
            NotificationHelper.setYearPreference(for: contact)
        default:
            break
        }

        scheduleDebouncedReset()
    }

    func weekdayChanged(to newValue: Int) {
        guard newValue != initialWeekday else { return }
        initialWeekday = Self.noInitialValue
        scheduleDebouncedReset()
    }

    func customMonthOrDayChanged() {
        guard contact != nil else { return }
        scheduleDebouncedReset()
    }

    func timeChanged(from oldTime: Date, to newTime: Date) {
        guard let contact, newTime != initialTime else { return }
        initialTime = .now
        let components = Calendar.current.dateComponents([.hour, .minute], from: newTime)

        guard let hour = components.hour, let minute = components.minute else {
            notificationPreferenceTime = oldTime
            return
        }
        NotificationHelper.updateNotificationTime(for: contact, hour: hour, minute: minute)
        scheduleDebouncedReset()
    }

    func customDateChanged(to newDate: Date) {
        guard let contact, newDate != initialCustomDate else { return }
        initialCustomDate = .now
        let calendar = Calendar.current
        let date = calendar.dateComponents([.year, .month, .day], from: newDate)
        let time = calendar.dateComponents([.hour, .minute], from: notificationPreferenceTime)

        NotificationHelper.updateNotificationTime(for: contact, hour: time.hour ?? 0, minute: time.minute ?? 0)
        NotificationHelper.updateNotificationCustomDate(
            for: contact,
            month: date.month ?? 1,
            day: date.day ?? 1,
            year: date.year ?? 0
        )
        scheduleDebouncedReset()
    }

    // MARK: Rescheduling

    /// Batches rapid edits into one reschedule. A pending reschedule is replaced by
    /// the next edit, but finishes even if the detail view closes in the meantime.
    private func scheduleDebouncedReset() {
        resetTask?.cancel()
        resetTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled, let contact else { return }
            await reschedule(contact)
        }
    }

    private static func resetGeneralNotification(for contact: SelectedContact) async {
        let authorized = await NotificationHelper.checkNotificationAuthorizationStatusAndAddRequest()
        guard authorized else { return }

        // Replace only the general notification, using its stable identifier.
        await UNUserNotificationCenter.current().remove([NotificationID.general(contact)])
        if contact.notificationOption != .never {
            await NotificationHelper.addGeneralNotification(for: contact)
        }

        NotificationHelper.updateNextNotificationDateTimeFor(contact: contact)
    }
}
