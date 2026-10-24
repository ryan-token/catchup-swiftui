//
//  ContactPhoto.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct ContactPhoto: View {
    /// The stored Base64 photo. Passing the string rather than an `Image` lets
    /// SwiftUI skip decoding when the photo hasn't changed.
    let picture: String

    var body: some View {
        Converter.contactPicture(from: picture)
            .resizable()
            .scaledToFill()
            .frame(width: 150, height: 150)
            .clipShape(.circle)
            .overlay {
                Circle().stroke(.white, lineWidth: 4)
            }
            .shadow(radius: 10)
            .accessibilityHidden(true)
    }
}

#Preview {
    ContactPhoto(picture: "")
}
