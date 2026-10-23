//
//  HomeScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 6/26/19.
//  Copyright © 2019 Token Solutions. All rights reserved.
//

import Contacts
import StoreKit
import SwiftData
import SwiftUI

struct HomeScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.requestReview) private var requestReview
    @Environment(LaunchCoordinator.self) private var launchCoordinator

    /// The contact shown in the detail column.
    @Binding var selection: SelectedContact?

    @Query(sort: \SelectedContact.name) private var selectedContacts: [SelectedContact]
    @Query(HomeScreen.nextCatchUpsDescriptor) private var nextCatchUps: [SelectedContact]

    @AppStorage("savedVersion") private var savedVersion = "2.0.0"
    @AppStorage("timesUserHasLaunchedApp") private var timesUserHasLaunchedApp = 0
    // Bump the suffix to trigger a fresh full reset on the next launch (e.g. "_v4").
    @AppStorage("hasPerformedNuclearNotificationReset_v3") private var hasPerformedNuclearNotificationReset = false

    @State private var isShowingUpdatesSheet = false
    @State private var isShowingAboutSheet = false
    @State private var isShowingContactPicker = false
    @State private var pickedContact: CNContact?
    /// When the rows' unread indicators were last evaluated; refreshed each time the app becomes active.
    @State private var referenceDate = Date.now

    private static let addContactsSymbol = "person.crop.circle.fill.badge.plus"

    /// The four soonest contacts with a recurring reminder.
    private static var nextCatchUpsDescriptor: FetchDescriptor<SelectedContact> {
        var descriptor = FetchDescriptor<SelectedContact>(
            predicate: #Predicate {
                $0.notification_preference != 0 && !$0.next_notification_date_time.isEmpty
            },
            sortBy: [SortDescriptor(\.next_notification_date_time)]
        )
        descriptor.fetchLimit = 4
        return descriptor
    }

    var body: some View {
        List(selection: $selection) {
            if !nextCatchUps.isEmpty {
                Section("Next CatchUps") {
                    NextCatchUpsGridView(nextCatchUps: nextCatchUps, selection: $selection)
                }
            }

            if !selectedContacts.isEmpty {
                Section("All CatchUps") {
                    ForEach(selectedContacts) { contact in
                        NavigationLink(value: contact) {
                            ContactRowView(contact: contact, referenceDate: referenceDate)
                        }
                    }
                    .onDelete(perform: removePendingNotificationsAndDeleteContacts)
                }
            }
        }
        .overlay {
            if selectedContacts.isEmpty {
                ContentUnavailableView(
                    "No CatchUps Yet",
                    systemImage: "person.crop.circle.badge.plus",
                    description: Text("Tap \(Image(systemName: Self.addContactsSymbol)) to add some.")
                        // VoiceOver would read the symbol's name rather than the button's.
                        .accessibilityLabel("Tap Add Contacts to add some.")
                )
            }
        }
        .refreshable {
            // Refresh birthdays and anniversaries first, so the reschedule uses them.
            await ContactHelper.updateSelectedContacts(selectedContacts)
            await NotificationHelper.resetNotifications(for: selectedContacts, delayTime: 0)
        }
        .navigationTitle("CatchUp")
        .toolbar {
            // Colors only the large title; the inline title and VoiceOver still use `navigationTitle`.
            ToolbarItem(placement: .largeTitle) {
                Text("CatchUp")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityAddTraits(.isHeader)
            }

            ToolbarItem(placement: .topBarLeading) {
                EditButton()
                    .tint(.blue)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("About", systemImage: "person.crop.square", action: showAbout)
                    .tint(.blue)
            }
        }
        // A bar rather than a bottom toolbar item, which shows only the symbol and moves
        // into the top bar when the sidebar sits beside the detail, as on unfolded iPhone Duo.
        .safeAreaBar(edge: .bottom) {
            Button("Add Contacts", systemImage: Self.addContactsSymbol, action: showContactPicker)
                .font(.headline)
                .tint(.blue)
                .buttonStyle(.glass)
                .controlSize(.large)
        }
        .background {
            ContactPicker(isPresented: $isShowingContactPicker, pickedContact: $pickedContact)
                .frame(width: 0, height: 0)
                .accessibilityHidden(true)
        }
        .onChange(of: pickedContact) { _, newValue in
            guard let newValue else { return }
            saveSelectedContact(newValue)
            pickedContact = nil
        }
        .onChange(of: selectedContacts.count) {
            clearSelectionIfRemoved()
        }
        .task {
            await runColdLaunchSetupIfNeeded()
        }
        .task(id: scenePhase) {
            guard scenePhase == .active else { return }
            referenceDate = .now
            updateNextNotificationTime(for: selectedContacts)
            await Utils.clearAppIconNotificationBadge()
        }
        .sheet(isPresented: $isShowingUpdatesSheet) {
            UpdatesScreen()
        }
        .sheet(isPresented: $isShowingAboutSheet) {
            AboutScreen()
        }
    }

    private func showAbout() {
        isShowingAboutSheet = true
    }

    private func showContactPicker() {
        isShowingContactPicker = true
    }

    private func runColdLaunchSetupIfNeeded() async {
        // Runs once per launch, however many windows are open.
        guard launchCoordinator.beginColdLaunchSetup() else { return }

        // Only check version on cold launch (IAPs load lazily when the tip jar appears)
        checkForUpdate()

        if timesUserHasLaunchedApp > 5 && Int.random(in: 1...3) == 2 {
            requestReview()
        }

        timesUserHasLaunchedApp += 1

        if hasPerformedNuclearNotificationReset {
            // Defense-in-depth on every cold launch: cancel anything
            // whose identifier no longer corresponds to a contact in
            // SwiftData, then re-schedule for everyone who survives.
            await NotificationHelper.cleanupOrphanedNotifications(for: selectedContacts)
            await NotificationHelper.resetNotifications(for: selectedContacts, delayTime: 3)
        } else {
            // One-time recovery: wipe every pending/delivered notification
            // for this app and re-schedule from the current SwiftData
            // contact set. Cleans up orphans left by past builds whose
            // delete path targeted the wrong identifier.
            await NotificationHelper.performOneTimeNuclearReset(for: selectedContacts)
            hasPerformedNuclearNotificationReset = true
        }
    }

    private func updateNextNotificationTime(for contacts: [SelectedContact]) {
        for contact in contacts {
            NotificationHelper.updateNextNotificationDateTimeFor(contact: contact)
        }
    }

    private func saveSelectedContact(_ contact: CNContact) {
        let contactName = ContactHelper.contactName(for: contact)
        guard !selectedContacts.contains(where: { $0.name == contactName }) else { return }

        modelContext.insert(ContactHelper.createSelectedContact(contact: contact))

        // Autosave timing is unpredictable; persist immediately so a user who
        // adds a contact and backgrounds the app keeps it on next launch.
        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save after adding contacts: \(error)")
        }
    }

    /// Clears the detail column when its contact is deleted, here or on another device.
    private func clearSelectionIfRemoved() {
        if let selection, !selectedContacts.contains(selection) {
            self.selection = nil
        }
    }

    private func removePendingNotificationsAndDeleteContacts(at offsets: IndexSet) {
        let contactsToDelete = offsets.map { selectedContacts[$0] }

        // Stop showing a contact before it's deleted.
        if let selection, contactsToDelete.contains(selection) {
            self.selection = nil
        }

        // Delete right away so the list can animate the rows out.
        modelContext.remove(contactsToDelete)
    }

    private func checkForUpdate() {
        let latestVersion = Utils.currentAppVersion
        guard savedVersion != latestVersion else { return }

        if Utils.updateIsMajor(version: latestVersion) && timesUserHasLaunchedApp > 0 {
            isShowingUpdatesSheet = true
        }
        savedVersion = latestVersion
    }
}

#Preview {
    @Previewable @State var selection: SelectedContact?

    NavigationStack {
        HomeScreen(selection: $selection)
    }
    .modelContainer(PreviewSampleData.container)
    .environment(LaunchCoordinator())
}
