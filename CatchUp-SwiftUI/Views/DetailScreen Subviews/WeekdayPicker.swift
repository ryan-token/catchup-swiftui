//
//  WeekdayPicker.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct WeekdayPicker: View {
    /// The Gregorian weekday, where 1 is Sunday.
    @Binding var selection: Int
    let label: String

    var body: some View {
        Picker(selection: $selection) {
            ForEach(1...7, id: \.self) { weekday in
                WeekdayName(weekday: weekday)
                    .tag(weekday)
            }
        } label: {
            Text(label)
        }
    }
}

#Preview {
    List {
        WeekdayPicker(selection: .constant(1), label: "What day?")
    }
}
