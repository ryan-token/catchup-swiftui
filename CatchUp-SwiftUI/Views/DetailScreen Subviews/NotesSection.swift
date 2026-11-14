//
//  NotesSection.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 11/13/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import OSLog
import SwiftData
import SwiftUI

/// Free-form notes about the contact, saved and synced with the rest of its details.
///
/// Its own view, so each keystroke updates only this section rather than the whole detail screen.
struct NotesSection: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @Bindable var contact: SelectedContact

    @FocusState private var isEditing: Bool

    var body: some View {
        Section("Notes") {
            // A vertical text field rather than a text editor: it shows a placeholder, and
            // keeps room for a few lines, at any Dynamic Type size, before growing with the text.
            TextField("Add notes", text: $contact.notes, axis: .vertical)
                .lineLimit(4...)
                .focused($isEditing)
        }
        // Keystrokes only change the model in memory. Save once editing ends — the keyboard
        // closes, the screen goes away, or the app leaves the foreground — so the notes are
        // on disk and queued for CloudKit, rather than waiting on autosave's timing.
        // Disappearing covers the split view switching contacts mid-edit, where the focus
        // change may not arrive; a repeat save with nothing changed writes nothing.
        .onChange(of: isEditing) { _, isEditing in
            if !isEditing { save() }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { save() }
        }
        .onDisappear(perform: save)
    }

    private func save() {
        do {
            try modelContext.save()
        } catch {
            Logger.persistence.error("Failed to save notes: \(error)")
            assertionFailure("Failed to save notes: \(error)")
        }
    }
}

#Preview {
    List {
        NotesSection(contact: .sampleData)
    }
    .modelContainer(PreviewSampleData.container)
}
