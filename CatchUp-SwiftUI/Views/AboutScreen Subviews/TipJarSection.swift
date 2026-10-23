//
//  TipJarSection.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import StoreKit
import SwiftUI

struct TipJarSection: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let iapService = IAPService.shared
    @State private var tipTrigger = 0
    @State private var status: IAPServiceAlertType?

    var body: some View {
        VStack(spacing: 15) {
            Text("Tip Jar")
                .font(.headline)

            Text("""
                CatchUp is free with no ads. If you find it useful, please consider supporting \
                development by leaving a tip or review.
                """)
                .multilineTextAlignment(.center)
                .padding(.bottom)

            // Stack the tips vertically at accessibility text sizes, which leave
            // no room side by side. AnyLayout keeps the buttons' identity.
            let layout = dynamicTypeSize.isAccessibilitySize ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())
            layout {
                TipButton(
                    amount: displayPrice(for: IAPService.graciousTipProductID, fallback: "$0.99"),
                    action: { purchase(productID: IAPService.graciousTipProductID) }
                )
                TipButton(
                    amount: displayPrice(for: IAPService.generousTipProductID, fallback: "$1.99"),
                    action: { purchase(productID: IAPService.generousTipProductID) }
                )
                TipButton(
                    amount: displayPrice(for: IAPService.gratuitousTipProductID, fallback: "$4.99"),
                    action: { purchase(productID: IAPService.gratuitousTipProductID) }
                )
            }
            .padding(.bottom, 20)
        }
        .sensoryFeedback(.success, trigger: tipTrigger)
        .task { await iapService.loadProducts() }
        .onChange(of: iapService.purchaseStatus) { _, newValue in
            guard let newValue else { return }
            status = newValue
            iapService.clearPurchaseStatus()
        }
        .alert(status?.title ?? "Thanks!", item: $status) { _ in
        } message: { status in
            Text(status.message)
        }
    }

    private func displayPrice(for productID: String, fallback: String) -> String {
        iapService.displayPrice(for: productID) ?? fallback
    }

    private func purchase(productID: String) {
        guard let product = iapService.product(for: productID) else { return }
        tipTrigger &+= 1
        Task { await iapService.purchase(product) }
    }
}

#Preview {
    TipJarSection()
}
