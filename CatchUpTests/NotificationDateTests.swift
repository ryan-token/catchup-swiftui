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
import UserNotifications

struct NotificationDateTests {
    // MARK: Birthdays and anniversaries

    @Test func birthdayFiresAtQuarterPastSevenOnTheDay() throws {
        let components = try #require(NotificationHelper.birthdayDateComponents(fromStored: "05-16"))
        #expect(components == DateComponents(month: 5, day: 16, hour: 7, minute: 15))
    }

    @Test(arguments: ["", "16-05", "05/16/1994"])
    func unreadableBirthdayHasNoComponents(_ stored: String) {
        #expect(NotificationHelper.birthdayDateComponents(fromStored: stored) == nil)
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

    @Test func unreadableAnniversaryHasNoComponents() {
        #expect(NotificationHelper.anniversaryDateComponents(fromStored: "anniversary") == nil)
    }

    // MARK: Quarterly

    @Test func futureQuarterlyAnchorIsTheNextFireDate() {
        let now = TestSupport.date(year: 2026, month: 10, day: 22)
        let anchor = now.addingTimeInterval(3600)
        #expect(NotificationHelper.nextQuarterlyFireDate(from: anchor, now: now) == anchor)
    }

    @Test func quarterlyOnAnIntervalBoundaryMovesToTheNextOne() {
        let now = TestSupport.date(year: 2026, month: 10, day: 22)
        let anchor = now - Constants.ninetyDaysInSeconds
        #expect(NotificationHelper.nextQuarterlyFireDate(from: anchor, now: now) == now + Constants.ninetyDaysInSeconds)
    }

    @Test func quarterlyRoundsUpToTheNextInterval() {
        let now = TestSupport.date(year: 2026, month: 10, day: 22)
        let ninetyDays = Constants.ninetyDaysInSeconds

        let tenDaysAgo = now.addingTimeInterval(-10 * 86400)
        #expect(NotificationHelper.nextQuarterlyFireDate(from: tenDaysAgo, now: now) == tenDaysAgo + ninetyDays)

        let hundredDaysAgo = now.addingTimeInterval(-100 * 86400)
        let afterTwoQuarters = hundredDaysAgo + 2 * ninetyDays
        #expect(NotificationHelper.nextQuarterlyFireDate(from: hundredDaysAgo, now: now) == afterTwoQuarters)
    }

    @Test(arguments: [(0.0, 1.0), (10, 1), (89.9, 1), (90.1, 2)])
    func quarterlyReminderFiresOnTheNextMarkHoweverOftenItsRescheduled(
        daysSinceChosen: Double,
        quarter: Double
    ) throws {
        let chosen = TestSupport.date(year: 2026, month: 10, day: 22, hour: 10)
        let contact = SelectedContact.sampleData
        contact.notification_preference = NotificationOption.quarterly.rawValue
        contact.notification_preference_quarterly_set_time = chosen

        let now = chosen + daysSinceChosen * 86400
        let trigger = try #require(
            NotificationHelper.generalTrigger(for: contact, now: now) as? UNTimeIntervalNotificationTrigger
        )
        #expect(trigger.repeats == false)
        #expect(now + trigger.timeInterval == chosen + quarter * Constants.ninetyDaysInSeconds)
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

    @Test func triggerComponentsMatchEachFrequency() {
        let contact = SelectedContact.sampleData
        contact.notification_preference_hour = 9
        contact.notification_preference_minute = 30
        contact.notification_preference_weekday = 2
        contact.notification_preference_week_of_month = 3
        contact.notification_preference_custom_month = 7
        contact.notification_preference_custom_day = 4
        contact.notification_preference_custom_year = 2027

        contact.notification_preference = NotificationOption.weekly.rawValue
        #expect(NotificationHelper.getNotificationDateComponents(for: contact)
            == DateComponents(hour: 9, minute: 30, weekday: 2))

        contact.notification_preference = NotificationOption.monthly.rawValue
        #expect(NotificationHelper.getNotificationDateComponents(for: contact)
            == DateComponents(hour: 9, minute: 30, weekday: 2, weekOfMonth: 3))

        contact.notification_preference = NotificationOption.annually.rawValue
        #expect(NotificationHelper.getNotificationDateComponents(for: contact)
            == DateComponents(month: 7, day: 4, hour: 9, minute: 30))

        contact.notification_preference = NotificationOption.custom.rawValue
        #expect(NotificationHelper.getNotificationDateComponents(for: contact)
            == DateComponents(year: 2027, month: 7, day: 4, hour: 9, minute: 30))

        contact.notification_preference = NotificationOption.never.rawValue
        #expect(NotificationHelper.getNotificationDateComponents(for: contact) == DateComponents())
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
