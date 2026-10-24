//
//  TipButton.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct TipButton: View {
    let amount: String
    // A closure is fine here: the tip jar re-renders only when products load or a purchase finishes.
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            // Styling the label, not the button, makes the whole capsule tappable.
            Text(amount)
                .font(.headline)
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.linearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom),
                            in: .rect(cornerRadius: 20))
                .shadow(radius: 10)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        TipButton(amount: "$0.99", action: {})
        TipButton(amount: "$1.99", action: {})
        TipButton(amount: "$4.99", action: {})
    }
    .padding()
}
