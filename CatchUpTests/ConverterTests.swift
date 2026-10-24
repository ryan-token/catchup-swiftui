//
//  ConverterTests.swift
//  CatchUpTests
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

@testable import CatchUp
import Foundation
import Testing

struct ConverterTests {
    private func contact(
        _ option: NotificationOption,
        hour: Int = 13,
        minute: Int = 30,
        weekday: Int = 3,
        month: Int = 1,
        day: Int = 5,
        year: Int = 2027
    ) -> SelectedContact {
        let contact = SelectedContact.sampleData
        contact.notification_preference = option.rawValue
        contact.notification_preference_hour = hour
        contact.notification_preference_minute = minute
        contact.notification_preference_weekday = weekday
        contact.notification_preference_custom_month = month
        contact.notification_preference_custom_day = day
        contact.notification_preference_custom_year = year
        return contact
    }

    private func description(for contact: SelectedContact) -> String {
        Converter.notificationPreferenceDescription(
            for: contact,
            calendar: TestSupport.calendar,
            locale: TestSupport.locale
        )
        .normalizingSpaces
    }

    // MARK: Birthdays and anniversaries

    @Test(arguments: [("05-16", "May 16"), ("12-01", "December 1"), ("02-29", "February 29")])
    func formatsStoredMonthDay(stored: String, expected: String) {
        #expect(Converter.formattedBirthdayOrAnniversary(from: stored, locale: TestSupport.locale) == expected)
    }

    @Test func returnsUnreadableMonthDayUnchanged() {
        #expect(Converter.formattedBirthdayOrAnniversary(from: "04-31", locale: TestSupport.locale) == "04-31")
        #expect(Converter.formattedBirthdayOrAnniversary(from: "soon", locale: TestSupport.locale) == "soon")
    }

    // MARK: Phone and email

    @Test func makesTelURLFromDigitsAndPlusSigns() {
        #expect(Converter.tappablePhoneNumber(from: "(636) 368-7771") == URL(string: "tel://6363687771"))
        #expect(Converter.tappablePhoneNumber(from: "+1 636 368 7771") == URL(string: "tel://+16363687771"))
    }

    @Test func rejectsPhoneNumbersWithoutDigits() {
        #expect(Converter.tappablePhoneNumber(from: "no number") == nil)
    }

    // MARK: Notification preferences

    @Test(arguments: [
        (NotificationOption.never, "No Reminder Set"),
        (.daily, "Daily at 1:30 PM"),
        (.weekly, "Tuesdays at 1:30 PM"),
        (.monthly, "Monthly on Tuesdays"),
        (.annually, "Annually on January 5"),
        (.custom, "January 5, 2027")
    ])
    func describesEachFrequency(option: NotificationOption, expected: String) {
        #expect(description(for: contact(option)) == expected)
    }

    @Test func describesMidnightAndNoon() {
        #expect(description(for: contact(.daily, hour: 0, minute: 5)) == "Daily at 12:05 AM")
        #expect(description(for: contact(.daily, hour: 12, minute: 0)) == "Daily at 12:00 PM")
    }

    @Test func describesImpossibleDates() {
        #expect(description(for: contact(.custom, month: 4, day: 31)) == "Unknown")
        #expect(description(for: contact(.annually, month: 0, day: 0)) == "Annually")
    }

    @Test func describesUnknownWeekdayByFrequency() {
        #expect(description(for: contact(.weekly, weekday: 9)) == "Weekly at 1:30 PM")
        #expect(description(for: contact(.monthly, weekday: 9)) == "Monthly")
    }
}
