//
//  ContactPictureView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/24/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

/// A small circular contact photo that scales with Dynamic Type.
struct ContactPictureView: View {
    /// The stored Base64 photo. Passing the string rather than the contact means
    /// this view decodes the image again only when the photo changes.
    let picture: String

    @ScaledMetric(relativeTo: .headline) private var size = 45

    var body: some View {
        Converter.contactPicture(from: picture)
            .renderingMode(.original)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(.circle)
            .accessibilityHidden(true)
    }
}

#Preview {
    ContactPictureView(picture: "")
}
