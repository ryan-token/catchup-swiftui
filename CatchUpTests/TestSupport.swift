//
//  TestSupport.swift
//  CatchUpTests
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import Foundation

/// Fixed locale, calendar, and time zone so tests don't depend on the machine's settings.
nonisolated enum TestSupport {
    static let locale = Locale(identifier: "en_US")
    static let utc = TimeZone.gmt

    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        calendar.timeZone = utc
        return calendar
    }

    /// A UTC date, for building fixed reference points.
    static func date(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0) -> Date {
        let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
        guard let date = calendar.date(from: components) else {
            fatalError("Invalid test date components: \(components)")
        }
        return date
    }
}

extension String {
    /// Replaces the narrow no-break space that time formats use before AM and PM with a regular space.
    var normalizingSpaces: String {
        replacing("\u{202F}", with: " ").replacing("\u{00A0}", with: " ")
    }
}
