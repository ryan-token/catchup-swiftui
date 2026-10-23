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
/// The pickers bind to the model, which applies each edit to the contact.
struct NotificationPreferenceView: View {
    @Bindable var model: NotificationPreferenceModel

    var body: some View {
        HowOftenPicker(selection: $model.preference)

        switch model.preference {
        case .daily:
            TimePickerRow(notificationPreferenceTime: $model.time)
        case .weekly, .monthly:
            WeekdayPicker(selection: $model.weekday, label: model.whatDayText)
            TimePickerRow(notificationPreferenceTime: $model.time)
        case .annually:
            MonthPicker(selection: $model.month)
            DayOfMonthPicker(selection: $model.day)
            TimePickerRow(notificationPreferenceTime: $model.time)
        case .custom:
            CustomDatePicker(selection: $model.customDate)
            TimePickerRow(notificationPreferenceTime: $model.time)
        case .never, .quarterly:
            EmptyView()
        }
    }
}

#Preview {
    let model = NotificationPreferenceModel()
    model.load(.sampleData)

    return List {
        NotificationPreferenceView(model: model)
    }
}
