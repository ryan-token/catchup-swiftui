//
//  ContactHelperTests.swift
//  CatchUpTests
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

@testable import CatchUp
import Contacts
import Foundation
import Testing

struct ContactHelperTests {
    // MARK: Reading CNContact values

    @Test func joinsNamesOmittingEmptyParts() {
        let contact = CNMutableContact()
        contact.givenName = "Avery"
        contact.familyName = "Lee"
        #expect(ContactHelper.contactName(for: contact) == "Avery Lee")

        contact.familyName = ""
        #expect(ContactHelper.contactName(for: contact) == "Avery")

        contact.givenName = ""
        contact.familyName = "Lee"
        #expect(ContactHelper.contactName(for: contact) == "Lee")
    }

    @Test func readsPhoneNumbersByPosition() {
        let contact = CNMutableContact()
        contact.phoneNumbers = [
            CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: "555-0100")),
            CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue: "555-0199"))
        ]
        #expect(ContactHelper.phoneNumber(at: 0, of: contact) == "555-0100")
        #expect(ContactHelper.phoneNumber(at: 1, of: contact) == "555-0199")
        #expect(ContactHelper.phoneNumber(at: 2, of: contact).isEmpty)
    }

    @Test func flattensPostalAddressToOneLine() {
        let address = CNMutablePostalAddress()
        address.street = "1 Main St\nApt 2"
        address.city = "Tulsa"
        address.state = "OK"
        address.postalCode = "74104"

        let contact = CNMutableContact()
        contact.postalAddresses = [CNLabeledValue(label: CNLabelHome, value: address)]
        #expect(ContactHelper.postalAddress(at: 0, of: contact) == "1 Main St Apt 2, Tulsa, OK 74104")
        #expect(ContactHelper.postalAddress(at: 1, of: contact).isEmpty)
    }

    @Test func storesBirthdayMonthAndDayWithoutTimeZoneShifts() {
        let contact = CNMutableContact()
        contact.birthday = DateComponents(calendar: Calendar(identifier: .gregorian), year: 1994, month: 5, day: 16)
        #expect(ContactHelper.birthday(of: contact) == "05-16")
    }

    @Test func storesBirthdayWithoutYear() {
        let contact = CNMutableContact()
        contact.birthday = DateComponents(month: 12, day: 1)
        #expect(ContactHelper.birthday(of: contact) == "12-01")
    }

    @Test func missingBirthdayIsEmpty() {
        #expect(ContactHelper.birthday(of: CNMutableContact()).isEmpty)
    }

    @Test func findsTheAnniversaryAmongOtherDates() {
        let contact = CNMutableContact()
        contact.dates = [
            CNLabeledValue(label: CNLabelOther, value: DateComponents(month: 1, day: 2) as NSDateComponents),
            CNLabeledValue(label: CNLabelDateAnniversary, value: DateComponents(month: 6, day: 20) as NSDateComponents)
        ]
        #expect(ContactHelper.anniversary(of: contact) == "06-20")
    }

    @Test func noAnniversaryIsEmpty() {
        let contact = CNMutableContact()
        contact.dates = [
            CNLabeledValue(label: CNLabelOther, value: DateComponents(month: 1, day: 2) as NSDateComponents)
        ]
        #expect(ContactHelper.anniversary(of: contact).isEmpty)
    }

    @Test func contactWithoutPhotoStoresEmptyPicture() {
        #expect(ContactHelper.encodedPicture(for: CNMutableContact()).isEmpty)
    }

    // MARK: Display

    @Test func usesTheFirstWordAsTheFirstName() {
        let contact = SelectedContact.sampleData
        contact.name = "Mary Ann Smith"
        #expect(ContactHelper.firstName(for: contact) == "Mary")
    }

    @Test func describesNextCatchUpRelativeToToday() {
        let contact = SelectedContact.sampleData
        let now = TestSupport.date(year: 2026, month: 10, day: 22, hour: 10)

        func describe(_ stored: String, quarterly: Bool = false) -> String {
            contact.next_notification_date_time = stored
            return ContactHelper.friendlyNextCatchUpTime(
                for: contact,
                forQuarterlyPreference: quarterly,
                now: now,
                calendar: TestSupport.calendar,
                locale: TestSupport.locale
            ).normalizingSpaces
        }

        #expect(describe("2026-10-22 19:15:00") == "Today at 7:15 PM")
        #expect(describe("2026-10-23 07:15:00") == "Tomorrow at 7:15 AM")
        #expect(describe("2026-12-29 07:15:00") == "December 29 at 7:15 AM")
        #expect(describe("2026-12-29 07:15:00", quarterly: true) == "Quarterly at 7:15 AM")
        #expect(describe("") == "None")
        #expect(describe("Unknown") == "None")
    }
}
