//
//  NotificationHelper+Dates.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import Foundation

extension NotificationHelper {
    /// The soonest upcoming notification for the contact, as a `StoredDateFormat` string.
    ///
    /// Includes the general reminder, birthday, and anniversary. Returns an empty
    /// string when nothing is scheduled.
    static func getNextNotificationDateFor(
        contact: SelectedContact,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> String {
        let nextDate = { (components: DateComponents) in
            calculateDateStringFromComponents(components, after: now, calendar: calendar)
        }
        let birthday = getBirthdayDateComponents(for: contact).map(nextDate)
        let anniversary = getAnniversaryDateComponents(for: contact).map(nextDate)
        let specialDates = [birthday, anniversary].compactMap(\.self)

        // With no general reminder, only birthdays and anniversaries count.
        guard contact.notificationOption != .never else {
            return specialDates.min() ?? ""
        }

        // Use the trigger's own components, so the date shown is the date it fires.
        let general = if contact.notificationOption == .quarterly {
            calculateDateStringFromDate(
                nextQuarterlyFireDate(from: contact.notification_preference_quarterly_set_time, now: now),
                calendar: calendar
            )
        } else {
            nextDate(getNotificationDateComponents(for: contact))
        }

        // Stored strings are zero-padded, so string order matches date order.
        return ([general] + specialDates).min() ?? general
    }

    /// The components that the general reminder's repeating calendar trigger matches.
    static func getNotificationDateComponents(for contact: SelectedContact) -> DateComponents {
        var dateComponents = DateComponents()

        switch contact.notificationOption {
        case .daily:
            dateComponents.hour = contact.notification_preference_hour
            dateComponents.minute = contact.notification_preference_minute
        case .weekly:
            dateComponents.hour = contact.notification_preference_hour
            dateComponents.minute = contact.notification_preference_minute
            dateComponents.weekday = contact.notification_preference_weekday
        case .monthly:
            dateComponents.hour = contact.notification_preference_hour
            dateComponents.minute = contact.notification_preference_minute
            dateComponents.weekday = contact.notification_preference_weekday
            dateComponents.weekOfMonth = contact.notification_preference_week_of_month
        case .annually, .custom:
            if contact.notificationOption == .custom {
                dateComponents.year = contact.notification_preference_custom_year
            }
            dateComponents.month = contact.notification_preference_custom_month
            dateComponents.day = contact.notification_preference_custom_day
            dateComponents.hour = contact.notification_preference_hour
            dateComponents.minute = contact.notification_preference_minute
        case .never, .quarterly:
            break
        }

        return dateComponents
    }

    /// The first 90-day mark after the anchor that falls after `now`, so always later than `now`.
    nonisolated static func nextQuarterlyFireDate(from anchor: Date, now: Date = .now) -> Date {
        let ninetyDays = Constants.ninetyDaysInSeconds
        let elapsed = now.timeIntervalSince(anchor)

        // An anchor in the future, such as one synced from a device whose clock runs ahead,
        // is the next fire date.
        guard elapsed >= 0 else { return anchor }

        // Count the whole quarters already passed, then step to the next one.
        let nextQuarter = (elapsed / ninetyDays).rounded(.down) + 1
        return anchor.addingTimeInterval(nextQuarter * ninetyDays)
    }

    /// Birthday notifications fire at 7:15 AM on the day, or `nil` if there's no readable birthday.
    static func getBirthdayDateComponents(for contact: SelectedContact) -> DateComponents? {
        birthdayDateComponents(fromStored: contact.birthday)
    }

    nonisolated static func birthdayDateComponents(fromStored birthday: String) -> DateComponents? {
        StoredDateFormat.monthDay(from: birthday).map {
            DateComponents(month: $0.month, day: $0.day, hour: 7, minute: 15)
        }
    }

    /// Anniversary notifications fire at 7:30 AM the day before, or `nil` if there's no readable anniversary.
    static func getAnniversaryDateComponents(for contact: SelectedContact) -> DateComponents? {
        anniversaryDateComponents(fromStored: contact.anniversary)
    }

    nonisolated static func anniversaryDateComponents(fromStored anniversary: String) -> DateComponents? {
        guard let monthDay = StoredDateFormat.monthDay(from: anniversary) else { return nil }

        // Work in a non-leap year so a March 1 anniversary is preceded by February 28,
        // which recurs every year. February 29 rolls over to March 1, then back to February 28.
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 2001, month: monthDay.month, day: monthDay.day)
        guard let anniversaryDate = calendar.date(from: components),
              let previousDay = calendar.date(byAdding: .day, value: -1, to: anniversaryDate) else {
            return nil
        }

        let previous = calendar.dateComponents([.month, .day], from: previousDay)
        return DateComponents(month: previous.month, day: previous.day, hour: 7, minute: 30)
    }

    nonisolated static func calculateDateStringFromDate(_ date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        return calculateDateStringFromComponents(components, calendar: calendar)
    }

    /// The next date after `date` matching the components, as a `StoredDateFormat` string,
    /// or "Unknown" when no date matches.
    nonisolated static func calculateDateStringFromComponents(
        _ dateComponents: DateComponents,
        after date: Date = .now,
        calendar: Calendar = .current
    ) -> String {
        guard let calculatedDate = calendar.nextDate(
            after: date,
            matching: dateComponents,
            matchingPolicy: .nextTime
        ) else {
            return "Unknown"
        }
        return StoredDateFormat.string(from: calculatedDate, timeZone: calendar.timeZone)
    }

    /// Sets the custom year to this year, or next year if the date has already passed.
    static func setYearPreference(for contact: SelectedContact, now: Date = .now) {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: now)

        var components = getNotificationDateComponents(for: contact)
        components.year = currentYear
        guard let nextNotificationDate = calendar.date(from: components) else { return }

        contact.notification_preference_custom_year = nextNotificationDate < now ? currentYear + 1 : currentYear
    }
}
