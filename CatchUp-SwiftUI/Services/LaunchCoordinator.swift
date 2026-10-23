//
//  LaunchCoordinator.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import Observation

/// Tracks app-wide, once-per-launch work.
///
/// The app can show several windows at once, on iPad and on iPhone Duo's inner
/// display, and each window creates its own home screen. Owning this flag at the
/// app level keeps cold-launch setup from running once per window.
@Observable
final class LaunchCoordinator {
    private(set) var hasStartedColdLaunchSetup = false

    /// Returns `true` the first time it's called in this process, and `false` afterward.
    func beginColdLaunchSetup() -> Bool {
        guard !hasStartedColdLaunchSetup else { return false }
        hasStartedColdLaunchSetup = true
        return true
    }
}
