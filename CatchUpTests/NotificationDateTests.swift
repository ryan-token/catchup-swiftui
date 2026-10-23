//
//  NotificationDateTests.swift
//  CatchUpTests
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

@testable import CatchUp
import Foundation
import Testing

struct NotificationDateTests {
    // MARK: Birthdays and anniversaries

    @Test func birthdayFiresAtQuarterPastSevenOnTheDay() throws {
        let components = try #require(NotificationHelper.birthdayDateComponents(fromStored: "05-16"))
        #expect(components == DateComponents(month: 5, day: 16, hour: 7, minute: 15))
    }

    @Test(arguments: [
        ("06-20", 6, 19),
        ("01-01", 12, 31),
        ("03-01", 2, 28),
        ("02-29", 2, 28)
    ])
    func anniversaryFiresTheDayBeforeAtHalfPastSeven(stored: String, month: Int, day: Int) throws {
        let components = try #require(NotificationHelper.anniversaryDateComponents(fromStored: stored))
        #expect(components == DateComponents(month: month, day: day, hour: 7, minute: 30))
    }

    // MARK: Quarterly

    @Test func quarterlyRepeatsYearlyInEachQuarterFromTheChosenMonth() {
        let chosen = TestSupport.date(year: 2026, month: 11, day: 30, hour: 10, minute: 15)
        let components = NotificationHelper.quarterlyDateComponents(from: chosen, calendar: TestSupport.calendar)

        #expect(components.map(\.month) == [11, 2, 5, 8])
        // Capped, so February has the day too.
        #expect(components.allSatisfy { $0.day == 28 && $0.hour == 10 && $0.minute == 15 })
    }

    @Test func quarterlyKeepsFiringWithoutBeingRescheduled() {
        // Chosen years earlier, and never rescheduled since.
        let contact = SelectedContact.sampleData
        contact.birthday = ""
        contact.anniversary = ""
        contact.notification_preference = NotificationOption.quarterly.rawValue
        contact.notification_preference_quarterly_set_time = TestSupport.date(year: 2020, month: 1, day: 15, hour: 9)
        #expect(nextNotification(for: contact) == "2027-01-15 09:00:00")
    }

    // MARK: Matching components

    @Test func findsTheNextMatchingDate() {
        let after = TestSupport.date(year: 2026, month: 10, day: 22, hour: 8)
        let components = DateComponents(hour: 7, minute: 15)
        let string = NotificationHelper.calculateDateStringFromComponents(
            components,
            after: after,
            calendar: TestSupport.calendar
        )
        #expect(string == "2026-10-23 07:15:00")
    }

    @Test func findsTheNextAnnualDate() {
        let after = TestSupport.date(year: 2026, month: 10, day: 22)
        let components = DateComponents(month: 5, day: 16, hour: 7, minute: 15)
        let string = NotificationHelper.calculateDateStringFromComponents(
            components,
            after: after,
            calendar: TestSupport.calendar
        )
        #expect(string == "2027-05-16 07:15:00")
    }

    // MARK: Soonest notification

    @Test func neverWithoutSpecialDatesHasNoNextNotification() {
        let contact = SelectedContact.sampleData
        contact.notification_preference = NotificationOption.never.rawValue
        contact.birthday = ""
        contact.anniversary = ""
        #expect(NotificationHelper.getNextNotificationDateFor(contact: contact).isEmpty)
    }

    @Test(arguments: [
        ("05-16", "06-20", "2027-05-16 07:15:00"),
        ("12-01", "11-10", "2026-11-09 07:30:00")
    ])
    func neverUsesTheSoonerOfBirthdayAndAnniversary(birthday: String, anniversary: String, expected: String) {
        let contact = SelectedContact.sampleData
        contact.notification_preference = NotificationOption.never.rawValue
        contact.birthday = birthday
        contact.anniversary = anniversary
        #expect(nextNotification(for: contact) == expected)
    }

    @Test func generalReminderWinsWhenSooner() {
        let contact = SelectedContact.sampleData
        contact.birthday = "10-24"
        contact.anniversary = "10-26"
        contact.notification_preference = NotificationOption.daily.rawValue
        contact.notification_preference_hour = 9
        contact.notification_preference_minute = 0
        #expect(nextNotification(for: contact) == "2026-10-23 09:00:00")
    }

    @Test func weeklyReminderIgnoresAStoredWeekOfMonth() {
        // Older and synced rows can carry a week of the month, which the weekly trigger ignores.
        let contact = SelectedContact.sampleData
        contact.notification_preference = NotificationOption.weekly.rawValue
        contact.notification_preference_weekday = 2
        contact.notification_preference_week_of_month = 5
        contact.notification_preference_hour = 9
        contact.notification_preference_minute = 30
        #expect(nextNotification(for: contact) == "2026-10-26 09:30:00")
    }

    @Test(arguments: [
        (NotificationOption.daily, "2026-10-23 09:30:00"),
        (.weekly, "2026-10-26 09:30:00"),
        (.monthly, "2026-11-16 09:30:00"),
        (.annually, "2027-07-04 09:30:00"),
        (.custom, "2028-07-04 09:30:00")
    ])
    func nextReminderForEachFrequency(option: NotificationOption, expected: String) {
        let contact = SelectedContact.sampleData
        contact.birthday = ""
        contact.anniversary = ""
        contact.notification_preference = option.rawValue
        contact.notification_preference_hour = 9
        contact.notification_preference_minute = 30
        contact.notification_preference_weekday = 2
        contact.notification_preference_week_of_month = 3
        contact.notification_preference_custom_month = 7
        contact.notification_preference_custom_day = 4
        contact.notification_preference_custom_year = 2028
        #expect(nextNotification(for: contact) == expected)
    }

    @Test func customReminderInThePastIsUnknown() {
        let contact = SelectedContact.sampleData
        contact.birthday = ""
        contact.anniversary = ""
        contact.notification_preference = NotificationOption.custom.rawValue
        contact.notification_preference_custom_month = 7
        contact.notification_preference_custom_day = 4
        contact.notification_preference_custom_year = 2025
        #expect(nextNotification(for: contact) == "Unknown")
    }

    @Test func leapDayBirthdayIsNextOnTheNextLeapDay() {
        let contact = SelectedContact.sampleData
        contact.notification_preference = NotificationOption.never.rawValue
        contact.birthday = "02-29"
        contact.anniversary = ""
        #expect(nextNotification(for: contact) == "2028-02-29 07:15:00")
    }

    // MARK: Unread times

    @Test(arguments: [
        ("2026-10-22 10:00:00", true),
        ("2027-06-01 07:15:00", true),
        ("", false),
        ("2026-10-22 10:00:00 AM", false),
        // Written in the Buddhist and Japanese calendars by older versions.
        ("2569-10-22 10:00:00", false),
        ("0008-10-22 10:00:00", false)
    ])
    func recognizesComparableUnreadTimes(stored: String, isComparable: Bool) {
        let now = TestSupport.date(year: 2026, month: 10, day: 22)
        #expect(NotificationHelper.isComparableUnreadTime(stored, now: now) == isComparable)
    }

    /// The next notification as seen at 10 AM UTC on Thursday, October 22, 2026.
    private func nextNotification(for contact: SelectedContact) -> String {
        NotificationHelper.getNextNotificationDateFor(
            contact: contact,
            now: TestSupport.date(year: 2026, month: 10, day: 22, hour: 10),
            calendar: TestSupport.calendar
        )
    }
}
