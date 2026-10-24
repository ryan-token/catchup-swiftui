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
    /// The contacts each test's model rescheduled, in order.
    private let rescheduled = RescheduleRecorder()

    @Test func readsPickerValuesFromTheContact() {
        let contact = SelectedContact.sampleData
        contact.notification_preference_hour = 18
        contact.notification_preference_minute = 45
        contact.notification_preference_custom_year = 2027
        contact.notification_preference_custom_month = 7
        contact.notification_preference_custom_day = 4

        let model = makeModel(editing: contact)
        let calendar = TestSupport.calendar

        let time = calendar.dateComponents([.hour, .minute], from: model.time)
        #expect(time.hour == 18)
        #expect(time.minute == 45)

        let date = calendar.dateComponents([.year, .month, .day], from: model.customDate)
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
        #expect(makeModel(editing: contact).whatDayText == prompt)
    }

    @Test func settingTheCurrentValuesChangesNothing() async {
        let contact = SelectedContact.sampleData
        contact.notification_preference = NotificationOption.weekly.rawValue
        contact.notification_preference_week_of_month = 3
        let model = makeModel(editing: contact)

        // Pickers can set the value they already show.
        model.preference = .weekly
        model.weekday = contact.notification_preference_weekday
        model.time = model.time
        await model.resetTask?.value

        #expect(contact.notification_preference_week_of_month == 3)
        #expect(rescheduled.contacts.isEmpty)
    }

    @Test func editsInQuickSuccessionRescheduleOnce() async {
        let contact = SelectedContact.sampleData
        let model = makeModel(editing: contact)

        model.preference = .monthly
        model.weekday = 5
        model.time = TestSupport.date(year: 2026, month: 10, day: 22, hour: 6, minute: 5)
        await model.resetTask?.value

        #expect(contact.notificationOption == .monthly)
        #expect(contact.notification_preference_weekday == 5)
        #expect(contact.notification_preference_hour == 6)
        #expect(contact.notification_preference_minute == 5)
        #expect(rescheduled.contacts.map(\.id) == [contact.id])
    }

    @Test func editsUpdateTheNextDateBeforeRescheduling() {
        let contact = SelectedContact.sampleData
        contact.birthday = ""
        contact.anniversary = ""
        contact.next_notification_date_time = ""
        let model = makeModel(editing: contact)

        model.preference = .daily
        #expect(!contact.next_notification_date_time.isEmpty)
        #expect(contact.next_notification_date_time == NotificationHelper.getNextNotificationDateFor(contact: contact))
        #expect(rescheduled.contacts.isEmpty)
    }

    @Test func monthlyPicksALaterWeekAndWeeklyClearsIt() {
        let contact = SelectedContact.sampleData
        let model = makeModel(editing: contact)

        model.preference = .monthly
        #expect((2..<5).contains(contact.notification_preference_week_of_month))

        model.preference = .weekly
        #expect(contact.notification_preference_week_of_month == 0)
    }

    @Test func quarterlyStartsCountingFromNow() {
        let contact = SelectedContact.sampleData
        contact.notification_preference_quarterly_set_time = .distantPast
        let before = Date.now

        makeModel(editing: contact).preference = .quarterly
        #expect(contact.notification_preference_quarterly_set_time >= before)
    }

    @Test func choosingACustomDateStoresIt() {
        let contact = SelectedContact.sampleData
        let model = makeModel(editing: contact)

        model.customDate = TestSupport.date(year: 2030, month: 3, day: 9)
        #expect(contact.notification_preference_custom_year == 2030)
        #expect(contact.notification_preference_custom_month == 3)
        #expect(contact.notification_preference_custom_day == 9)
    }

    @Test func editingTheTimeKeepsTheCustomYear() {
        let contact = SelectedContact.sampleData
        contact.notification_preference = NotificationOption.custom.rawValue
        contact.notification_preference_custom_year = 2030
        let model = makeModel(editing: contact)

        model.time = TestSupport.date(year: 2026, month: 10, day: 22, hour: 20)
        #expect(contact.notification_preference_custom_year == 2030)
    }

    /// A model for the contact that records its reschedules instead of touching the notification center.
    private func makeModel(editing contact: SelectedContact) -> NotificationPreferenceModel {
        let model = NotificationPreferenceModel(calendar: TestSupport.calendar, debounce: .zero) { [rescheduled] in
            rescheduled.contacts.append($0)
        }
        model.load(contact)
        return model
    }
}

private final class RescheduleRecorder {
    var contacts: [SelectedContact] = []
}
