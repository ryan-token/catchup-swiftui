//
//  NotificationPreferenceModelTests.swift
//  CatchUpTests
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

@testable import CatchUp
import Foundation
import Testing

struct NotificationPreferenceModelTests {
    @Test func loadsPickerValuesFromTheContact() {
        let contact = SelectedContact.sampleData
        contact.notification_preference_hour = 18
        contact.notification_preference_minute = 45
        contact.notification_preference_custom_year = 2027
        contact.notification_preference_custom_month = 7
        contact.notification_preference_custom_day = 4

        let model = makeModel()
        model.load(contact, calendar: TestSupport.calendar)
        let calendar = TestSupport.calendar

        let time = calendar.dateComponents([.hour, .minute], from: model.notificationPreferenceTime)
        #expect(time.hour == 18)
        #expect(time.minute == 45)

        let date = calendar.dateComponents([.year, .month, .day], from: model.notificationPreferenceCustomDate)
        #expect(date.year == 2027)
        #expect(date.month == 7)
        #expect(date.day == 4)
    }

    @Test(arguments: [
        (NotificationOption.weekly, NotificationPreferenceModel.weeklyDayPrompt),
        (NotificationOption.monthly, NotificationPreferenceModel.monthlyDayPrompt),
        (NotificationOption.daily, "")
    ])
    func choosesTheWeekdayPrompt(option: NotificationOption, prompt: String) {
        let contact = SelectedContact.sampleData
        contact.notification_preference = option.rawValue
        let model = makeModel()
        model.load(contact)
        #expect(model.whatDayText == prompt)
    }

    @Test func reselectingTheLoadedPreferenceChangesNothing() {
        let contact = SelectedContact.sampleData
        contact.notification_preference = NotificationOption.weekly.rawValue
        contact.notification_preference_week_of_month = 3

        let model = makeModel()
        model.load(contact)
        // Seeing the loaded value again is the initial load, not an edit.
        model.preferenceChanged(to: NotificationOption.weekly.rawValue)
        #expect(contact.notification_preference_week_of_month == 3)
    }

    @Test func monthlyPicksALaterWeekAndWeeklyClearsIt() {
        let contact = SelectedContact.sampleData
        let model = makeModel()
        model.load(contact)

        model.preferenceChanged(to: NotificationOption.monthly.rawValue)
        #expect((2..<5).contains(contact.notification_preference_week_of_month))

        model.preferenceChanged(to: NotificationOption.weekly.rawValue)
        #expect(contact.notification_preference_week_of_month == 0)
    }

    @Test func quarterlyStartsCountingFromNow() {
        let contact = SelectedContact.sampleData
        contact.notification_preference_quarterly_set_time = .distantPast
        let model = makeModel()
        model.load(contact)

        model.preferenceChanged(to: NotificationOption.quarterly.rawValue)
        #expect(contact.notification_preference_quarterly_set_time > .now.addingTimeInterval(-60))
    }

    @Test func returningToTheStartingPreferenceStillCountsAsAnEdit() {
        let contact = SelectedContact.sampleData
        contact.notification_preference = NotificationOption.weekly.rawValue
        contact.notification_preference_week_of_month = 3
        let model = makeModel()
        model.load(contact)

        model.preferenceChanged(to: NotificationOption.daily.rawValue)
        model.preferenceChanged(to: NotificationOption.weekly.rawValue)
        #expect(contact.notification_preference_week_of_month == 0)
    }

    @Test func editingACustomReminderKeepsItsYear() {
        let contact = SelectedContact.sampleData
        contact.notification_preference = NotificationOption.custom.rawValue
        contact.notification_preference_custom_year = 2030
        let model = makeModel()
        model.load(contact)

        model.timeChanged(from: model.notificationPreferenceTime, to: .now.addingTimeInterval(3600))
        model.customMonthOrDayChanged()
        #expect(contact.notification_preference_custom_year == 2030)
    }

    /// A model that doesn't reschedule, since tests shouldn't touch the notification center.
    private func makeModel() -> NotificationPreferenceModel {
        NotificationPreferenceModel { _ in }
    }
}
