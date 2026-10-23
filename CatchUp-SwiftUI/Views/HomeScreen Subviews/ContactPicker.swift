//
//  ContactPicker.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import ContactsUI
import SwiftUI

/// Presents the system contact picker from the window that contains this view.
///
/// `CNContactPickerViewController` must be presented modally by UIKit, so this
/// view hosts an invisible view controller to present from. Presenting from the
/// hosting window, rather than the first connected scene, keeps the picker in the
/// right window when the app has several open.
struct ContactPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var pickedContact: CNContact?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ presenter: UIViewController, context: Context) {
        context.coordinator.parent = self

        guard isPresented, presenter.presentedViewController == nil else { return }
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        presenter.present(picker, animated: true)

        // Treat each request as one-shot, so the next tap presents again however this
        // picker ends up dismissed. Deferred, since state can't change during an update.
        Task {
            isPresented = false
        }
    }

    final class Coordinator: NSObject, CNContactPickerDelegate {
        var parent: ContactPicker

        init(parent: ContactPicker) {
            self.parent = parent
        }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            parent.pickedContact = contact
        }
    }
}
