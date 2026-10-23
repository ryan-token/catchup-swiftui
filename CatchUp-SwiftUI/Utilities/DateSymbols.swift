//
//  DateSymbols.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import Foundation

/// Localized Gregorian month and weekday names.
///
/// Stored preferences use Gregorian numbering (months 1–12, weekdays 1–7 from
/// Sunday), so names always come from a Gregorian calendar in the given locale.
nonisolated enum DateSymbols {
    /// The standalone name of a month, such as "January", or `nil` outside 1–12.
    static func monthName(_ month: Int, locale: Locale = .current) -> String? {
        let symbols = calendar(for: locale).standaloneMonthSymbols
        return symbols.indices.contains(month - 1) ? symbols[month - 1] : nil
    }

    /// The standalone name of a weekday, such as "Sunday" for 1, or `nil` outside 1–7.
    static func weekdayName(_ weekday: Int, locale: Locale = .current) -> String? {
        let symbols = calendar(for: locale).standaloneWeekdaySymbols
        return symbols.indices.contains(weekday - 1) ? symbols[weekday - 1] : nil
    }

    private static func calendar(for locale: Locale) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        return calendar
    }
}
