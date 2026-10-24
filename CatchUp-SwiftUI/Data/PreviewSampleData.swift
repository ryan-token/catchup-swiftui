//
//  PreviewSampleData.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/31/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftData

/// An in-memory store populated with sample contacts for SwiftUI previews.
enum PreviewSampleData {
    static let container: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: SelectedContact.self, configurations: config)

            let sampleNames = [
                "Ryan Token", "Jordan Smith", "Avery Lee", "Riley Chen",
                "Morgan Patel", "Casey Nguyen", "Quinn Garcia", "Drew Kim", "Sam Brown"
            ]
            for name in sampleNames {
                let contact = SelectedContact.sampleData
                contact.name = name
                container.mainContext.insert(contact)
            }

            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()
}
