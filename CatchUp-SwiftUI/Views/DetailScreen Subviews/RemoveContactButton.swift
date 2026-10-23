//
//  RemoveContactButton.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/30/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftData
import SwiftUI

struct RemoveContactButton: View {
    @Environment(\.modelContext) private var modelContext

    let contact: SelectedContact
    /// The split view's selection; clearing it leaves the detail view in every layout.
    @Binding var selection: SelectedContact?

    @State private var isShowingDeleteContactAlert = false

    var body: some View {
        Button(action: confirmRemoval) {
            CalloutButtonView(title: "Remove \(contact.name)", color: .red)
        }
        .listRowBackground(Color.clear)
        .alert("Remove \(contact.name)?", isPresented: $isShowingDeleteContactAlert) {
            Button("Remove", role: .destructive, action: deleteContact)
            Button("Cancel", role: .cancel) {}
        }
    }

    private func confirmRemoval() {
        isShowingDeleteContactAlert = true
    }

    private func deleteContact() {
        // Leave the detail view first so nothing renders the contact once it's deleted.
        // This pops the stack when collapsed and clears the detail column when expanded.
        selection = nil

        // Delete on the next turn, once the detail view has stopped rendering the contact.
        Task {
            modelContext.remove([contact])
        }
    }
}

#Preview {
    List {
        RemoveContactButton(contact: .sampleData, selection: .constant(nil))
    }
}
