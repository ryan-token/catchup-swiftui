//
//  ScreenshotAvatar.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/23/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

#if DEBUG
import SwiftUI

/// Initials on a gradient, rendered into a photo for screenshot contacts.
struct ScreenshotAvatar: View {
    let initials: String
    let colors: [Color]

    var body: some View {
        // A fixed size, because this is rendered to an image rather than shown.
        Text(initials)
            .font(.system(size: 64, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: 160, height: 160)
            .background(.linearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

#Preview {
    ScreenshotAvatar(initials: "MR", colors: [.pink, .orange])
}
#endif
