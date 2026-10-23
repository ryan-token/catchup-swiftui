//
//  NotificationResetGate.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 11/18/2025.
//  Copyright © 2025 Token Solutions. All rights reserved.
//

/// Serializes notification reset operations. Each call's work waits for any
/// previously enqueued work to finish before running, so concurrent resets
/// can't interleave their purge+reschedule phases on the shared notification queue.
actor NotificationResetGate {
    static let shared = NotificationResetGate()
    private var tail: Task<Void, Never>?

    func run(_ operation: sending @escaping @MainActor () async -> Void) async {
        let previous = tail
        let next = Task { @MainActor in
            await previous?.value
            await operation()
        }
        tail = next
        await next.value
    }
}
