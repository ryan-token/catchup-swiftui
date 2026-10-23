//
//  StoredDateFormatTests.swift
//  CatchUpTests
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

@testable import CatchUp
import Foundation
import Testing

struct StoredDateFormatTests {
    @Test(arguments: [
        (TestSupport.date(year: 2026, month: 3, day: 5, hour: 7, minute: 4), "2026-03-05 07:04:00"),
        (TestSupport.date(year: 2026, month: 12, day: 31, hour: 23, minute: 59), "2026-12-31 23:59:00"),
        (TestSupport.date(year: 2027, month: 1, day: 1), "2027-01-01 00:00:00")
    ])
    func formatsZeroPaddedTwentyFourHourTime(date: Date, expected: String) {
        #expect(StoredDateFormat.string(from: date, timeZone: TestSupport.utc) == expected)
    }

    @Test func roundTripsThroughParsing() throws {
        let date = TestSupport.date(year: 2026, month: 10, day: 22, hour: 17, minute: 30)
        let string = StoredDateFormat.string(from: date, timeZone: TestSupport.utc)
        let parsed = try #require(StoredDateFormat.date(from: string, timeZone: TestSupport.utc))
        #expect(parsed == date)
    }

    @Test(arguments: ["", "None", "Unknown", "2026-13-01 00:00:00", "2026-02-30 00:00:00", "2026-10-22"])
    func rejectsMalformedStrings(_ string: String) {
        #expect(StoredDateFormat.date(from: string, timeZone: TestSupport.utc) == nil)
    }

    @Test func stringOrderMatchesDateOrder() {
        let earlier = TestSupport.date(year: 2026, month: 9, day: 30, hour: 23)
        let later = TestSupport.date(year: 2026, month: 10, day: 1, hour: 1)
        let earlierString = StoredDateFormat.string(from: earlier, timeZone: TestSupport.utc)
        let laterString = StoredDateFormat.string(from: later, timeZone: TestSupport.utc)
        #expect(earlierString < laterString)
    }

    @Test func buildsZeroPaddedMonthDay() {
        #expect(StoredDateFormat.monthDayString(month: 5, day: 6) == "05-06")
        #expect(StoredDateFormat.monthDayString(month: 12, day: 25) == "12-25")
    }

    @Test func parsesMonthDay() throws {
        let monthDay = try #require(StoredDateFormat.monthDay(from: "05-16"))
        #expect(monthDay.month == 5)
        #expect(monthDay.day == 16)
    }

    @Test(arguments: ["", "13-01", "00-10", "05-00", "05-32", "05/16/1994", "May 16"])
    func rejectsMalformedMonthDay(_ string: String) {
        #expect(StoredDateFormat.monthDay(from: string) == nil)
    }
}
