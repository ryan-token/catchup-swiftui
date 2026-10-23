//
//  StoredDateFormat.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import Foundation

/// The fixed string formats CatchUp persists in SwiftData and syncs through CloudKit.
///
/// Notification times are stored as `yyyy-MM-dd HH:mm:ss` and compared as strings,
/// so the representation must stay zero-padded, Gregorian, and independent of the
/// user's locale. Birthdays and anniversaries are stored as `MM-dd`.
nonisolated enum StoredDateFormat {
    private static let gregorian = Calendar(identifier: .gregorian)

    private static let dateTimeFormat: Date.FormatString = """
        \(year: .padded(4))-\(month: .twoDigits)-\(day: .twoDigits) \
        \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits):\(second: .twoDigits)
        """

    /// Formats a date as a stored `yyyy-MM-dd HH:mm:ss` string in the given time zone.
    static func string(from date: Date, timeZone: TimeZone = .current) -> String {
        let style = Date.VerbatimFormatStyle(format: dateTimeFormat, timeZone: timeZone, calendar: gregorian)
        return date.formatted(style)
    }

    /// Parses a stored `yyyy-MM-dd HH:mm:ss` string, returning `nil` when it doesn't match.
    static func date(from string: String, timeZone: TimeZone = .current) -> Date? {
        let strategy = Date.ParseStrategy(
            format: dateTimeFormat,
            locale: Locale(identifier: "en_US_POSIX"),
            timeZone: timeZone,
            calendar: gregorian,
            isLenient: false
        )
        return try? Date(string, strategy: strategy)
    }

    /// Builds a stored `MM-dd` string, such as `05-16`.
    static func monthDayString(month: Int, day: Int) -> String {
        "\(twoDigits(month))-\(twoDigits(day))"
    }

    /// Reads the month and day from a stored `MM-dd` string, validating both ranges.
    static func monthDay(from string: String) -> (month: Int, day: Int)? {
        let parts = string.split(separator: "-")
        guard parts.count == 2,
              let month = Int(parts[0]), (1...12).contains(month),
              let day = Int(parts[1]), (1...31).contains(day) else {
            return nil
        }
        return (month, day)
    }

    private static func twoDigits(_ value: Int) -> String {
        value < 10 ? "0\(value)" : "\(value)"
    }
}
