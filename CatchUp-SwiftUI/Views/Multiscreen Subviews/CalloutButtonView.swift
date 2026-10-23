//
//  CalloutButtonView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/12/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

/// A full-width, filled label for a screen's prominent call to action.
struct CalloutButtonView: View {
    let title: LocalizedStringKey
    let color: Color

    var body: some View {
        Text(title)
            .bold()
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.vertical, 6)
            .padding(.horizontal)
            .foregroundStyle(.white)
            .background(color, in: .rect(cornerRadius: 20))
    }
}

#Preview {
    CalloutButtonView(title: "Remove Bee", color: .red)
}
