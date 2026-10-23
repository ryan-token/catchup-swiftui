//
//  ContactHelper.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import Contacts
import Foundation
import OSLog

/// Creates and refreshes `SelectedContact` records from the Contacts store.
enum ContactHelper {
    // MARK: Reading CNContact values

    /// The contact's thumbnail as Base64, or empty when there is no photo.
    nonisolated static func encodedPicture(for contact: CNContact) -> String {
        guard contact.isKeyAvailable(CNContactImageDataAvailableKey),
              contact.isKeyAvailable(CNContactThumbnailImageDataKey),
              contact.imageDataAvailable,
              let data = contact.thumbnailImageData else {
            return ""
        }
        return data.base64EncodedString()
    }

    /// The given and family names joined by a space, omitting whichever is empty.
    nonisolated static func contactName(for contact: CNContact) -> String {
        [contact.givenName, contact.familyName]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// The phone number at the given position, or empty when there isn't one.
    nonisolated static func phoneNumber(at index: Int, of contact: CNContact) -> String {
        let numbers = contact.phoneNumbers
        return numbers.indices.contains(index) ? numbers[index].value.stringValue : ""
    }

    /// The email address at the given position, or empty when there isn't one.
    nonisolated static func emailAddress(at index: Int, of contact: CNContact) -> String {
        let addresses = contact.emailAddresses
        return addresses.indices.contains(index) ? addresses[index].value as String : ""
    }

    /// The postal address at the given position on one line, or empty when there isn't one.
    nonisolated static func postalAddress(at index: Int, of contact: CNContact) -> String {
        let addresses = contact.postalAddresses
        guard addresses.indices.contains(index) else { return "" }
        let address = addresses[index].value
        // This single-line layout is stored and later geocoded, so keep it stable.
        let fullAddress = "\(address.street), \(address.city), \(address.state) \(address.postalCode)"
        return fullAddress.replacing("\n", with: " ")
    }

    /// The birthday as a stored `MM-dd` string, or empty when unknown.
    nonisolated static func birthday(of contact: CNContact) -> String {
        guard contact.isKeyAvailable(CNContactBirthdayKey) else { return "" }
        return monthDayString(from: contact.birthday)
    }

    /// The first date labeled as an anniversary, as a stored `MM-dd` string, or empty when unknown.
    nonisolated static func anniversary(of contact: CNContact) -> String {
        guard contact.isKeyAvailable(CNContactDatesKey) else { return "" }
        let anniversary = contact.dates.first { $0.label?.contains("Anniversary") == true }
        return monthDayString(from: anniversary.map { $0.value as DateComponents })
    }

    /// Reads the month and day directly, so the stored value never shifts with time zones.
    nonisolated static func monthDayString(from components: DateComponents?) -> String {
        guard let month = components?.month, let day = components?.day,
              (1...12).contains(month), (1...31).contains(day) else {
            return ""
        }
        return StoredDateFormat.monthDayString(month: month, day: day)
    }

    // MARK: Display

    static func firstName(for contact: SelectedContact) -> String {
        contact.name.split(separator: " ").first.map(String.init) ?? contact.name
    }

    /// Describes when the next notification fires, such as "Today at 7:15 AM" or "December 29 at 7:15 AM".
    static func friendlyNextCatchUpTime(
        for contact: SelectedContact,
        forQuarterlyPreference: Bool,
        now: Date = .now,
        calendar: Calendar = .current,
        locale: Locale = .current
    ) -> String {
        let storedDate = contact.next_notification_date_time
        guard let date = StoredDateFormat.date(from: storedDate, timeZone: calendar.timeZone) else {
            return "None"
        }

        var timeStyle = Date.FormatStyle(date: .omitted, time: .shortened, locale: locale, calendar: calendar)
        timeStyle.timeZone = calendar.timeZone
        let time = date.formatted(timeStyle)

        if forQuarterlyPreference {
            return "Quarterly at \(time)"
        } else if calendar.isDate(date, inSameDayAs: now) {
            return "Today at \(time)"
        } else if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
                  calendar.isDate(date, inSameDayAs: tomorrow) {
            return "Tomorrow at \(time)"
        } else {
            var style = Date.FormatStyle(locale: locale, calendar: calendar).month(.wide).day().hour().minute()
            style.timeZone = calendar.timeZone
            return date.formatted(style)
        }
    }

    // MARK: Creating and updating

    static func createSelectedContact(contact: CNContact) -> SelectedContact {
        let now = Date.now
        let calendar = Calendar.current

        return SelectedContact(
            address: postalAddress(at: 0, of: contact),
            anniversary: anniversary(of: contact),
            anniversary_notification_id: UUID(),
            birthday: birthday(of: contact),
            birthday_notification_id: UUID(),
            email: emailAddress(at: 0, of: contact),
            id: UUID(),
            name: contactName(for: contact),
            next_notification_date_time: "",
            notification_identifier: UUID(),
            notification_preference: NotificationOption.never.rawValue,
            notification_preference_custom_day: calendar.component(.day, from: now),
            notification_preference_custom_month: calendar.component(.month, from: now),
            notification_preference_custom_year: calendar.component(.year, from: now),
            notification_preference_hour: calendar.component(.hour, from: now),
            notification_preference_minute: calendar.component(.minute, from: now),
            notification_preference_quarterly_set_time: now,
            notification_preference_weekday: 1,
            notification_preference_week_of_month: calendar.component(.weekOfMonth, from: now),
            phone: phoneNumber(at: 0, of: contact),
            picture: encodedPicture(for: contact),
            secondary_address: postalAddress(at: 1, of: contact),
            secondary_email: emailAddress(at: 1, of: contact),
            secondary_phone: phoneNumber(at: 1, of: contact),
            unread_badge_date_time: ""
        )
    }

    static func updateSelectedContacts(_ selectedContacts: [SelectedContact]) async {
        // Look up snapshots in parallel off the main actor, then apply on main.
        let names = selectedContacts.map(\.name)

        let snapshotsByName: [String: ContactSnapshot] = await withTaskGroup(
            of: (String, ContactSnapshot?).self
        ) { group in
            for name in names {
                group.addTask { (name, await contactSnapshot(named: name)) }
            }
            var result: [String: ContactSnapshot] = [:]
            for await (name, snapshot) in group {
                if let snapshot { result[name] = snapshot }
            }
            return result
        }

        for contact in selectedContacts {
            if let snapshot = snapshotsByName[contact.name] {
                apply(snapshot, to: contact)
            } else {
                Logger.contacts.info("No contact named \(contact.name) was found")
            }
        }
    }

    private static func apply(_ snapshot: ContactSnapshot, to selectedContact: SelectedContact) {
        selectedContact.name = snapshot.name
        selectedContact.phone = snapshot.phone
        selectedContact.secondary_phone = snapshot.secondaryPhone
        selectedContact.email = snapshot.email
        selectedContact.secondary_email = snapshot.secondaryEmail
        selectedContact.address = snapshot.address
        selectedContact.secondary_address = snapshot.secondaryAddress
        selectedContact.picture = snapshot.picture
        selectedContact.birthday = snapshot.birthday
        selectedContact.anniversary = snapshot.anniversary
        NotificationHelper.updateNextNotificationDateTimeFor(contact: selectedContact)
    }

    /// Looks up a `CNContact` by name and returns a `Sendable` snapshot of its fields.
    /// Runs on the concurrent pool so it doesn't block the main actor during the
    /// synchronous `unifiedContacts` query.
    @concurrent
    nonisolated static func contactSnapshot(named name: String) async -> ContactSnapshot? {
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactPostalAddressesKey as CNKeyDescriptor,
            CNContactImageDataAvailableKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor,
            CNContactBirthdayKey as CNKeyDescriptor,
            CNContactDatesKey as CNKeyDescriptor
        ]

        do {
            let predicate = CNContact.predicateForContacts(matchingName: name)
            let contacts = try CNContactStore().unifiedContacts(matching: predicate, keysToFetch: keysToFetch)

            // Match the same name format that `createSelectedContact` stored.
            guard let contact = contacts.first(where: { contactName(for: $0) == name }) else {
                return nil
            }

            return ContactSnapshot(
                name: contactName(for: contact),
                phone: phoneNumber(at: 0, of: contact),
                secondaryPhone: phoneNumber(at: 1, of: contact),
                email: emailAddress(at: 0, of: contact),
                secondaryEmail: emailAddress(at: 1, of: contact),
                address: postalAddress(at: 0, of: contact),
                secondaryAddress: postalAddress(at: 1, of: contact),
                picture: encodedPicture(for: contact),
                birthday: birthday(of: contact),
                anniversary: anniversary(of: contact)
            )
        } catch {
            Logger.contacts.error("Unable to fetch contacts: \(error)")
            return nil
        }
    }
}
