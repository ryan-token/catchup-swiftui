//
//  WeekdayName.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

/// The localized name of a Gregorian weekday, such as "Sunday" for 1.
struct WeekdayName: View {
    @Environment(\.locale) private var locale

    let weekday: Int

    var body: some View {
        Text(DateSymbols.weekdayName(weekday, locale: locale) ?? "")
    }
}

#Preview {
    WeekdayName(weekday: 1)
}
