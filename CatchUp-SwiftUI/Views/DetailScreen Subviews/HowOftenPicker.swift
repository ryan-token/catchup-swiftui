//
//  HowOftenPicker.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct HowOftenPicker: View {
    @Binding var selection: NotificationOption

    var body: some View {
        Picker("How often?", selection: $selection) {
            ForEach(NotificationOption.allCases) { option in
                Text(option.title)
                    .tag(option)
            }
        }
    }
}

#Preview {
    List {
        HowOftenPicker(selection: .constant(.never))
    }
}
