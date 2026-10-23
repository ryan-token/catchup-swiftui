//
//  GradientView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

/// A decorative blue glow that fades into whatever is behind it.
struct GradientView: View {
    /// The glow's height. Its radii scale with it, so it keeps its shape however tall it is.
    let height: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        RadialGradient(
            colors: [.blue, .clear],
            center: .bottom,
            startRadius: height * (colorScheme == .light ? 0.55 : 0.3),
            endRadius: height * 1.35
        )
        .frame(height: height)
        .accessibilityHidden(true)
    }
}

#Preview {
    GradientView(height: 150)
        .frame(maxHeight: .infinity, alignment: .top)
}
