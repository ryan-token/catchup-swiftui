//
//  SelectedContact.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/3/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//
//

import Foundation
import SwiftData

// The snake_case property names mirror the original Core Data store and the
// CloudKit record schema derived from it. Renaming them would orphan existing
// data and break sync with older app versions, so they stay as they are.
// swiftlint:disable identifier_name

@Model
class SelectedContact {
    #Index<SelectedContact>([\.name], [\.next_notification_date_time])

    var address: String = ""
    /// The anniversary as a zero-padded `MM-dd` string, or empty when unknown.
    var anniversary: String = ""
    var anniversary_notification_id: UUID = UUID()
    /// The birthday as a zero-padded `MM-dd` string, or empty when unknown.
    var birthday: String = ""
    var birthday_notification_id: UUID = UUID()
    var email: String = ""
    var id: UUID = UUID()
    var name: String = ""
    var notification_identifier: UUID = UUID()
    /// The raw value of a `NotificationOption`.
    var notification_preference: Int = 0
    var notification_preference_custom_day: Int = 0
    var notification_preference_custom_month: Int = 0
    var notification_preference_custom_year: Int = 0
    var notification_preference_hour: Int = 0
    var notification_preference_minute: Int = 0
    var notification_preference_quarterly_set_time: Date = Date.now
    /// The Gregorian weekday, where 1 is Sunday.
    var notification_preference_weekday: Int = 1
    var notification_preference_week_of_month: Int = 0
    var phone: String = ""
    /// A Base64-encoded thumbnail, or empty to use the default photo.
    var picture: String = ""
    var secondary_address: String = ""
    var secondary_email: String = ""
    var secondary_phone: String = ""
    /// The next time any notification fires, in `StoredDateFormat`.
    var next_notification_date_time: String = ""
    /// The `StoredDateFormat` time after which the unread indicator shows.
    var unread_badge_date_time: String = ""

    init(
        address: String,
        anniversary: String,
        anniversary_notification_id: UUID,
        birthday: String,
        birthday_notification_id: UUID,
        email: String,
        id: UUID,
        name: String,
        next_notification_date_time: String,
        notification_identifier: UUID,
        notification_preference: Int,
        notification_preference_custom_day: Int,
        notification_preference_custom_month: Int,
        notification_preference_custom_year: Int,
        notification_preference_hour: Int,
        notification_preference_minute: Int,
        notification_preference_quarterly_set_time: Date,
        notification_preference_weekday: Int,
        notification_preference_week_of_month: Int,
        phone: String,
        picture: String,
        secondary_address: String,
        secondary_email: String,
        secondary_phone: String,
        unread_badge_date_time: String
    ) {
        self.address = address
        self.anniversary = anniversary
        self.anniversary_notification_id = anniversary_notification_id
        self.birthday = birthday
        self.birthday_notification_id = birthday_notification_id
        self.email = email
        self.id = id
        self.name = name
        self.next_notification_date_time = next_notification_date_time
        self.notification_identifier = notification_identifier
        self.notification_preference = notification_preference
        self.notification_preference_custom_day = notification_preference_custom_day
        self.notification_preference_custom_month = notification_preference_custom_month
        self.notification_preference_custom_year = notification_preference_custom_year
        self.notification_preference_hour = notification_preference_hour
        self.notification_preference_minute = notification_preference_minute
        self.notification_preference_quarterly_set_time = notification_preference_quarterly_set_time
        self.notification_preference_weekday = notification_preference_weekday
        self.notification_preference_week_of_month = notification_preference_week_of_month
        self.phone = phone
        self.picture = picture
        self.secondary_address = secondary_address
        self.secondary_email = secondary_email
        self.secondary_phone = secondary_phone
        self.unread_badge_date_time = unread_badge_date_time
    }

    /// The reminder frequency, treating unrecognized stored values as `.never`.
    var notificationOption: NotificationOption {
        NotificationOption(rawValue: notification_preference) ?? .never
    }

    /// Whether the contact has been deleted. One deleted on another device can lose its
    /// context without being marked deleted, so a missing context counts too.
    var isRemoved: Bool { isDeleted || modelContext == nil }

    var hasPhone: Bool { !phone.isEmpty }
    var hasSecondaryPhone: Bool { !secondary_phone.isEmpty }
    var hasEmail: Bool { !email.isEmpty }
    var hasSecondaryEmail: Bool { !secondary_email.isEmpty }
    var hasAddress: Bool { !address.isEmpty }
    var hasSecondaryAddress: Bool { !secondary_address.isEmpty }
    var hasBirthday: Bool { !birthday.isEmpty }
    var hasAnniversary: Bool { !anniversary.isEmpty }

    var hasContactInfo: Bool {
        hasPhone || hasSecondaryPhone || hasEmail || hasSecondaryEmail
            || hasAddress || hasSecondaryAddress || hasBirthday || hasAnniversary
    }

    // A factory (not a stored static) so each call site — previews, the
    // preview container loop — gets a distinct SwiftData instance instead of
    // sharing one identity (which SwiftData would de-dupe on insert).
    static var sampleData: SelectedContact {
        SelectedContact(
            address: "2190 E 11th Ave",
            anniversary: "06-20",
            anniversary_notification_id: UUID(),
            birthday: "05-16",
            birthday_notification_id: UUID(),
            email: "ryantoken13@gmail.com",
            id: UUID(),
            name: "Ryan Token",
            next_notification_date_time: "",
            notification_identifier: UUID(),
            notification_preference: NotificationOption.never.rawValue,
            notification_preference_custom_day: 3,
            notification_preference_custom_month: 1,
            notification_preference_custom_year: 0,
            notification_preference_hour: 12,
            notification_preference_minute: 0,
            notification_preference_quarterly_set_time: .now,
            notification_preference_weekday: 3,
            notification_preference_week_of_month: 2,
            phone: "6363687771",
            picture: "",
            secondary_address: "",
            secondary_email: "",
            secondary_phone: "",
            unread_badge_date_time: ""
        )
    }
}

// swiftlint:enable identifier_name
