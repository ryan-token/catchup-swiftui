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
        let specialDates = [
            nextBirthdayDate(for: contact, after: now, calendar: calendar),
            nextAnniversaryDate(for: contact, after: now, calendar: calendar)
        ].compactMap(\.self)

        // With no general reminder, only birthdays and anniversaries count.
        guard contact.notificationOption != .never else {
            return specialDates.min() ?? ""
        }

        // Use the triggers' own components, so the date shown is the date one fires.
        let general = generalDateComponents(for: contact, calendar: calendar)
            .map { calculateDateStringFromComponents($0, after: now, calendar: $0.calendar ?? calendar) }
            .min() ?? "Unknown"

        // Stored strings are zero-padded, so string order matches date order.
        return ([general] + specialDates).min() ?? general
    }

    /// The components that the general reminder's repeating calendar triggers match, each
    /// carrying the calendar it's read in.
    ///
    /// Quarterly reminders need a trigger for each quarter, each repeating yearly. Every
    /// other frequency needs one trigger, and Never needs none.
    static func generalDateComponents(for contact: SelectedContact, calendar: Calendar = .current) -> [DateComponents] {
        let hour = contact.notification_preference_hour
        let minute = contact.notification_preference_minute
        let weekday = contact.notification_preference_weekday

        return switch contact.notificationOption {
        case .never:
            []
        case .daily:
            [DateComponents(calendar: calendar, hour: hour, minute: minute)]
        case .weekly:
            [DateComponents(calendar: calendar, hour: hour, minute: minute, weekday: weekday)]
        case .monthly:
            [DateComponents(
                calendar: calendar,
                hour: hour,
                minute: minute,
                weekday: weekday,
                weekOfMonth: contact.notification_preference_week_of_month
            )]
        case .quarterly:
            quarterlyDateComponents(
                from: contact.notification_preference_quarterly_set_time,
                calendar: gregorian(in: calendar.timeZone)
            )
        case .annually:
            [DateComponents(
                calendar: gregorian(in: calendar.timeZone),
                month: contact.notification_preference_custom_month,
                day: contact.notification_preference_custom_day,
                hour: hour,
                minute: minute
            )]
        case .custom:
            [DateComponents(
                calendar: calendar,
                year: contact.notification_preference_custom_year,
                month: contact.notification_preference_custom_month,
                day: contact.notification_preference_custom_day,
                hour: hour,
                minute: minute
            )]
        }
    }

    /// One set of components per quarter, each repeating yearly, starting in the month
    /// quarterly was chosen and at the time it was chosen.
    ///
    /// The day is capped at 28, so it exists in every quarter's month.
    nonisolated static func quarterlyDateComponents(from anchor: Date, calendar: Calendar) -> [DateComponents] {
        let start = calendar.dateComponents([.month, .day, .hour, .minute], from: anchor)
        guard let month = start.month, let day = start.day else { return [] }

        return (0..<4).map { quarter in
            DateComponents(
                calendar: calendar,
                month: (month - 1 + 3 * quarter) % 12 + 1,
                day: min(day, 28),
                hour: start.hour,
                minute: start.minute
            )
        }
    }

    /// A Gregorian calendar in the given time zone.
    ///
    /// Birthdays and anniversaries from Contacts, and annual and quarterly dates, are
    /// Gregorian whatever calendar the device uses. Custom dates use the device's calendar,
    /// as earlier versions stored them that way.
    nonisolated static func gregorian(in timeZone: TimeZone = .current) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }

    // MARK: Birthdays and anniversaries

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

    /// The next birthday notification as a `StoredDateFormat` string, or `nil` without a birthday.
    static func nextBirthdayDate(
        for contact: SelectedContact,
        after now: Date = .now,
        calendar: Calendar = .current
    ) -> String? {
        getBirthdayDateComponents(for: contact).map {
            // Strict, so a February 29 birthday finds the next leap day, the only day it fires.
            calculateDateStringFromComponents(
                $0,
                after: now,
                calendar: gregorian(in: calendar.timeZone),
                matchingPolicy: .strict
            )
        }
    }

    /// The next anniversary notification as a `StoredDateFormat` string, or `nil` without an anniversary.
    static func nextAnniversaryDate(
        for contact: SelectedContact,
        after now: Date = .now,
        calendar: Calendar = .current
    ) -> String? {
        getAnniversaryDateComponents(for: contact).map {
            calculateDateStringFromComponents($0, after: now, calendar: gregorian(in: calendar.timeZone))
        }
    }

    // MARK: Calculating dates

    /// The next date after `date` matching the components, as a `StoredDateFormat` string,
    /// or "Unknown" when no date matches.
    nonisolated static func calculateDateStringFromComponents(
        _ dateComponents: DateComponents,
        after date: Date = .now,
        calendar: Calendar = .current,
        matchingPolicy: Calendar.MatchingPolicy = .nextTime
    ) -> String {
        guard let calculatedDate = calendar.nextDate(
            after: date,
            matching: dateComponents,
            matchingPolicy: matchingPolicy
        ) else {
            return "Unknown"
        }
        return StoredDateFormat.string(from: calculatedDate, timeZone: calendar.timeZone)
    }

    /// Sets the custom year to this year, or next year if the custom date has already passed,
    /// so the custom date picker starts on an upcoming date.
    static func setYearPreference(for contact: SelectedContact, now: Date = .now, calendar: Calendar = .current) {
        let currentYear = calendar.component(.year, from: now)
        let thisYear = DateComponents(
            year: currentYear,
            month: contact.notification_preference_custom_month,
            day: contact.notification_preference_custom_day,
            hour: contact.notification_preference_hour,
            minute: contact.notification_preference_minute
        )
        guard let date = calendar.date(from: thisYear) else { return }

        contact.notification_preference_custom_year = date < now ? currentYear + 1 : currentYear
    }
}
