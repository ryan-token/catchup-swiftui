//
//  MonthName.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

/// The localized name of a Gregorian month, such as "January" for 1.
struct MonthName: View {
    @Environment(\.locale) private var locale

    let month: Int

    var body: some View {
        Text(DateSymbols.monthName(month, locale: locale) ?? "")
    }
}

#Preview {
    MonthName(month: 1)
}
