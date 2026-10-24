//
//  SupportingTypeTests.swift
//  CatchUpTests
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

@testable import CatchUp
import Foundation
import Testing

struct SupportingTypeTests {
    @Test func notificationOptionRawValuesNeverChange() {
        // These values are persisted and synced, so changing one corrupts existing preferences.
        #expect(NotificationOption.allCases.map(\.rawValue) == [0, 1, 2, 3, 4, 5, 6])
        #expect(NotificationOption(rawValue: 4) == .quarterly)
    }

    @Test func unrecognizedPreferenceIsTreatedAsNever() {
        let contact = SelectedContact.sampleData
        contact.notification_preference = 42
        #expect(contact.notificationOption == .never)
    }

    @Test func namesGregorianMonthsAndWeekdays() {
        #expect(DateSymbols.monthName(1, locale: TestSupport.locale) == "January")
        #expect(DateSymbols.monthName(12, locale: TestSupport.locale) == "December")
        #expect(DateSymbols.weekdayName(1, locale: TestSupport.locale) == "Sunday")
        #expect(DateSymbols.weekdayName(7, locale: TestSupport.locale) == "Saturday")
    }

    @Test(arguments: [0, 13])
    func rejectsOutOfRangeMonths(_ month: Int) {
        #expect(DateSymbols.monthName(month, locale: TestSupport.locale) == nil)
    }

    @Test(arguments: [0, 8])
    func rejectsOutOfRangeWeekdays(_ weekday: Int) {
        #expect(DateSymbols.weekdayName(weekday, locale: TestSupport.locale) == nil)
    }

    @Test func extractsContactUUIDFromStableIdentifiers() {
        let contact = SelectedContact.sampleData
        let uuid = contact.id.uuidString
        #expect(NotificationID.extractContactUUID(from: NotificationID.thread(contact)) == uuid)
        #expect(NotificationID.extractContactUUID(from: NotificationID.general(contact)) == uuid)
        #expect(NotificationID.extractContactUUID(from: NotificationID.birthday(contact)) == uuid)
        #expect(NotificationID.quarters(contact).allSatisfy { NotificationID.extractContactUUID(from: $0) == uuid })
    }

    @Test func tappedNotificationOpensItsContactOnce() {
        let contact = SelectedContact.sampleData
        let router = NotificationRouter()

        // Older notifications carry a random identifier but a stable thread.
        router.notificationTapped(identifier: UUID().uuidString, threadIdentifier: NotificationID.thread(contact))
        #expect(router.takePendingContactID() == contact.id)
        #expect(router.takePendingContactID() == nil)

        router.notificationTapped(identifier: "legacy", threadIdentifier: "")
        #expect(router.pendingContactID == nil)
    }

    @Test(arguments: ["", "contact.", "contact.not-a-uuid.general", "8C0E1E0B-2F4A-4C38-9A57-3B8F0D1C2E44"])
    func treatsOtherIdentifiersAsLegacy(_ identifier: String) {
        #expect(NotificationID.extractContactUUID(from: identifier) == nil)
    }

    @Test(arguments: [("4.0", true), ("3.2.0", true), ("3.2.3", false), ("3.10", false)])
    func detectsMajorUpdates(version: String, isMajor: Bool) {
        #expect(Utils.updateIsMajor(version: version) == isMajor)
    }

    @Test func launchCoordinatorRunsSetupOnce() {
        let coordinator = LaunchCoordinator()
        #expect(coordinator.beginColdLaunchSetup())
        #expect(coordinator.beginColdLaunchSetup() == false)
    }
}
