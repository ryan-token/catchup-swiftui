//
//  Constants.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/10/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import Foundation

enum Constants {
    private static let writeReviewAddress =
        "https://apps.apple.com/us/app/catchup-keep-in-touch/id1358023550?action=write-review"

    /// Opens the App Store's "Write a Review" page for CatchUp.
    static var writeReviewURL: URL {
        guard let url = URL(string: writeReviewAddress) else {
            fatalError("The App Store review address is not a valid URL.")
        }
        return url
    }
}
