//
//  HowOftenPicker.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct HowOftenPicker: View {
    /// The raw value of the selected `NotificationOption`.
    @Binding var selection: Int

    var body: some View {
        Picker("How often?", selection: $selection) {
            ForEach(NotificationOption.allCases) { option in
                Text(option.title)
                    .tag(option.rawValue)
            }
        }
    }
}

#Preview {
    List {
        HowOftenPicker(selection: .constant(0))
    }
}
