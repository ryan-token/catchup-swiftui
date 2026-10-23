//
//  IAPServiceAlertType.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/19/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import Foundation

/// The outcome of a tip jar action, shown to the user in an alert.
enum IAPServiceAlertType: Equatable {
    case disabled
    case restored
    case purchased
    case failed

    var title: LocalizedStringResource {
        switch self {
        case .disabled, .failed: "Something Went Wrong"
        case .restored, .purchased: "Thanks!"
        }
    }

    var message: LocalizedStringResource {
        switch self {
        case .disabled: "It looks like in-app purchases are disabled for your device."
        case .restored: "You've successfully restored your purchase!"
        case .purchased: "Your tip was received. Thank you!"
        case .failed: "Your tip couldn't be completed. Please try again later."
        }
    }
}
