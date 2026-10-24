//
//  MonthPicker.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct MonthPicker: View {
    /// The Gregorian month, from 1 to 12.
    @Binding var selection: Int

    var body: some View {
        Picker("What month?", selection: $selection) {
            ForEach(1...12, id: \.self) { month in
                MonthName(month: month)
                    .tag(month)
            }
        }
    }
}

#Preview {
    List {
        MonthPicker(selection: .constant(1))
    }
}
