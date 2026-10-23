//
//  NoContactSelectedScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/1/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

/// Fills the detail column until a contact is selected.
struct NoContactSelectedScreen: View {
    var body: some View {
        ContentUnavailableView {
            Label {
                Text("Select a contact from the sidebar to get started.")
                    .bold()
            } icon: {
                Image(.catchUp)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(.rect(cornerRadius: 20))
                    .shadow(radius: 15)
                    .accessibilityHidden(true)
            }
        }
        // Matches the detail screen's grouped list, which SwiftUI has no style for.
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

#Preview {
    NoContactSelectedScreen()
}
