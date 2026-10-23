//
//  CatchUpApp.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/3/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftData
import SwiftUI

@main
struct CatchUpApp: App {
    let modelContainer: ModelContainer

    @State private var launchCoordinator = LaunchCoordinator()

    init() {
        // use the SQLite file created by Core Data originally, instead of SwiftData's default.store file
        let url = URL.applicationSupportDirectory.appending(path: "CatchUp-SwiftUI.sqlite")
        do {
            modelContainer = try ModelContainer(
                for: SelectedContact.self,
                configurations: ModelConfiguration(url: url))
        } catch {
            fatalError("Failed to initialize model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(launchCoordinator)
                .tint(.orange)
        }
        .modelContainer(modelContainer)
    }
}
