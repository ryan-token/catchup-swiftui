//
//  NotificationPreferenceView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/29/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

/// The list rows for choosing how often, and when, to be reminded about a contact.
///
/// This view produces several rows, so it carries no lifecycle or change modifiers:
/// those would attach to every row. `DetailScreen` forwards edits to the model instead.
struct NotificationPreferenceView: View {
    @Bindable var contact: SelectedContact
    @Bindable var model: NotificationPreferenceModel

    var body: some View {
        HowOftenPicker(selection: $contact.notification_preference)

        switch contact.notificationOption {
        case .daily:
            TimePickerRow(notificationPreferenceTime: $model.notificationPreferenceTime)
        case .weekly, .monthly:
            WeekdayPicker(selection: $contact.notification_preference_weekday, label: model.whatDayText)
            TimePickerRow(notificationPreferenceTime: $model.notificationPreferenceTime)
        case .annually:
            MonthPicker(selection: $contact.notification_preference_custom_month)
            DayOfMonthPicker(selection: $contact.notification_preference_custom_day)
            TimePickerRow(notificationPreferenceTime: $model.notificationPreferenceTime)
        case .custom:
            CustomDatePicker(selection: $model.notificationPreferenceCustomDate)
            TimePickerRow(notificationPreferenceTime: $model.notificationPreferenceTime)
        case .never, .quarterly:
            EmptyView()
        }
    }
}

#Preview {
    let contact = SelectedContact.sampleData
    let model = NotificationPreferenceModel()
    model.load(contact)

    return List {
        NotificationPreferenceView(contact: contact, model: model)
    }
}
