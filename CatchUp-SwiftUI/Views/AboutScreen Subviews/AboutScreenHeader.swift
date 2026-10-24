//
//  AboutScreenHeader.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct AboutScreenHeader: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(.catchUp)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(.rect(cornerRadius: 15))
                .shadow(radius: 10)
                .accessibilityHidden(true)
                .padding(.top, 12)

            Text("CatchUp")
                .foregroundStyle(.orange)
                .font(.largeTitle)
                .bold()
                .accessibilityAddTraits(.isHeader)

            Text("Made with ❤️ by an independent developer")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom)
        }
    }
}

#Preview {
    AboutScreenHeader()
}
