//
//  DetailHeader.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

/// The contact's photo over a gradient, followed by their name and reminder preference.
struct DetailHeader: View {
    let contact: SelectedContact
    /// The height of the bars above the list, which the gradient extends up behind.
    var topInset: CGFloat = 0

    var body: some View {
        VStack(spacing: 10) {
            ContactPhoto(picture: contact.picture)
                .padding(.top, 30)

            NameAndPreferenceStack(contact: contact)
        }
        .frame(maxWidth: .infinity)
        .background(alignment: .top) {
            GradientView(height: Self.gradientHeight + topInset)
                .offset(y: -topInset)
        }
    }

    /// How far the gradient reaches into the header, about halfway down the photo.
    private static let gradientHeight: CGFloat = 140
}

#Preview {
    List {
        Section {
            DetailHeader(contact: .sampleData)
        }
        .listSectionMargins(.horizontal, 0)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
}
