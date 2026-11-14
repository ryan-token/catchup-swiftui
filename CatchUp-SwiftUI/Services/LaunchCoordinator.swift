//
//  LaunchCoordinator.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import Observation
import UserNotifications

/// Tracks app-wide work that should run once, however many windows are open.
///
/// The app can show several windows at once, on iPad and on iPhone Duo's inner
/// display, and each window creates its own home screen. Owning this state at the
/// app level keeps cold-launch setup, and rescheduling after permission changes,
/// from running once per window.
@Observable
final class LaunchCoordinator {
    private(set) var hasStartedColdLaunchSetup = false

    /// The notification permission seen when the app last became active, `nil` before the first check.
    @ObservationIgnored private var lastAuthorizationStatus: UNAuthorizationStatus?

    /// Returns `true` the first time it's called in this process, and `false` afterward.
    func beginColdLaunchSetup() -> Bool {
        guard !hasStartedColdLaunchSetup else { return false }
        hasStartedColdLaunchSetup = true
        return true
    }

    /// Records the notification permission seen as the app becomes active, returning `true`
    /// when it was denied last time and now allows notifications: the user turned them on in
    /// Settings, and nothing has scheduled reminders since.
    ///
    /// Permission granted from the in-app prompt returns `false`, because it goes from
    /// undetermined rather than denied, and the code that asked schedules the reminders itself.
    func recordAuthorizationStatus(_ status: UNAuthorizationStatus) -> Bool {
        defer { lastAuthorizationStatus = status }
        return lastAuthorizationStatus == .denied && status.allowsScheduling
    }
}
