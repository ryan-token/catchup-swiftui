//
//  Conversions.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/12/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import OSLog
import PhoneNumberKit
import SwiftUI

/// Turns stored contact values into display strings, URLs, and images.
enum Converter {
    /// Shared because creating a `PhoneNumberUtility` loads its metadata, which is expensive.
    private static let phoneNumberUtility = PhoneNumberUtility()

    private nonisolated static let gregorian = Calendar(identifier: .gregorian)

    /// Decoded photos keyed by their Base64 string, so rows scrolling back into view don't decode again.
    private static let pictureCache = NSCache<NSString, UIImage>()

    // MARK: Contact details

    /// Formats a phone number internationally, or returns it unchanged if it can't be parsed.
    static func formattedPhoneNumber(from phoneNumber: String) -> String {
        do {
            let parsed = try phoneNumberUtility.parse(phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines))
            return phoneNumberUtility.format(parsed, toType: .international)
        } catch {
            Logger.contacts.debug("Couldn't parse a phone number: \(error)")
            return phoneNumber
        }
    }

    /// A `tel:` URL containing only the digits and `+` signs of the number.
    nonisolated static func tappablePhoneNumber(from phoneNumber: String) -> URL? {
        let digits = phoneNumber.replacing(/[^\d+]/, with: "")
        guard !digits.isEmpty else { return nil }
        return URL(string: "tel://\(digits)")
    }

    /// A `mailto:` URL for the address, or `nil` if the address can't form a URL.
    nonisolated static func tappableEmail(from emailAddress: String) -> URL? {
        URL(string: "mailto:\(emailAddress)")
    }

    /// Formats a stored `MM-dd` birthday or anniversary, such as "May 16".
    ///
    /// Returns the stored string unchanged when it isn't in the expected format.
    nonisolated static func formattedBirthdayOrAnniversary(
        from storedDate: String,
        locale: Locale = .current
    ) -> String {
        guard let monthDay = StoredDateFormat.monthDay(from: storedDate),
              // 2000 is a leap year, so February 29 stays valid.
              let date = gregorianDate(year: 2000, month: monthDay.month, day: monthDay.day) else {
            return storedDate
        }
        return date.formatted(monthDayStyle(locale: locale))
    }

    /// Decodes a stored Base64 photo, falling back to the default contact photo.
    static func contactPicture(from base64String: String) -> Image {
        let key = base64String as NSString
        if let cached = pictureCache.object(forKey: key) {
            return Image(uiImage: cached)
        }
        guard let data = Data(base64Encoded: base64String),
              let uiImage = UIImage(data: data) else {
            return Image(.defaultPhoto)
        }
        pictureCache.setObject(uiImage, forKey: key)
        return Image(uiImage: uiImage)
    }

    // MARK: Notification preferences

    /// A short description of the contact's reminder, such as "Tuesdays at 12:00 PM".
    static func notificationPreferenceDescription(for contact: SelectedContact, locale: Locale = .current) -> String {
        let time = notificationTimeDescription(for: contact, locale: locale)
        let weekday = DateSymbols.weekdayName(contact.notification_preference_weekday, locale: locale)

        return switch contact.notificationOption {
        case .never:
            "No Reminder Set"
        case .daily:
            "Daily at \(time)"
        case .weekly:
            weekday.map { "\($0)s at \(time)" } ?? "Weekly at \(time)"
        case .monthly:
            weekday.map { "Monthly on \($0)s" } ?? "Monthly"
        case .quarterly:
            ContactHelper.friendlyNextCatchUpTime(for: contact, forQuarterlyPreference: true, locale: locale)
        case .annually:
            customDateDescription(for: contact, includesYear: false, locale: locale).map { "Annually on \($0)" }
                ?? "Annually"
        case .custom:
            customDateDescription(for: contact, includesYear: true, locale: locale) ?? "Unknown"
        }
    }

    /// The contact's reminder time, such as "12:00 PM".
    static func notificationTimeDescription(for contact: SelectedContact, locale: Locale = .current) -> String {
        let components = DateComponents(
            year: 2000,
            month: 1,
            day: 1,
            hour: contact.notification_preference_hour,
            minute: contact.notification_preference_minute
        )
        guard (0...23).contains(contact.notification_preference_hour),
              (0...59).contains(contact.notification_preference_minute),
              let date = gregorian.date(from: components) else {
            return "Unknown"
        }
        var style = Date.FormatStyle(date: .omitted, time: .shortened, locale: locale, calendar: gregorian)
        style.timeZone = gregorian.timeZone
        return date.formatted(style)
    }

    /// The contact's annual or custom reminder date, such as "January 5" or "January 5, 2027",
    /// or `nil` if the stored date doesn't exist.
    private static func customDateDescription(
        for contact: SelectedContact,
        includesYear: Bool,
        locale: Locale
    ) -> String? {
        let year = includesYear ? contact.notification_preference_custom_year : 2000
        guard let date = gregorianDate(
            year: year,
            month: contact.notification_preference_custom_month,
            day: contact.notification_preference_custom_day
        ) else {
            return nil
        }
        let style = monthDayStyle(locale: locale)
        return date.formatted(includesYear ? style.year() : style)
    }

    // MARK: Helpers

    /// A Gregorian date for the given day, or `nil` if the month or day is out of range.
    private nonisolated static func gregorianDate(year: Int, month: Int, day: Int) -> Date? {
        guard (1...12).contains(month), (1...31).contains(day) else { return nil }
        let components = DateComponents(year: year, month: month, day: day)
        guard let date = gregorian.date(from: components),
              gregorian.component(.day, from: date) == day else {
            // The day doesn't exist in that month, such as April 31.
            return nil
        }
        return date
    }

    private nonisolated static func monthDayStyle(locale: Locale) -> Date.FormatStyle {
        var style = Date.FormatStyle(locale: locale, calendar: gregorian).month(.wide).day()
        style.timeZone = gregorian.timeZone
        return style
    }
}
