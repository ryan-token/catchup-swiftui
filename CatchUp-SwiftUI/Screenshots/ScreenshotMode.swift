//
//  ScreenshotMode.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/23/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

#if DEBUG
import OSLog
import SwiftData
import SwiftUI

/// Made-up contacts for App Store screenshots, turned on with the `-ScreenshotMode` launch argument.
///
/// The store is in memory and never syncs, so screenshots never show or change real contacts.
/// Captures don't refresh or edit, which would still schedule notifications for these contacts.
enum ScreenshotMode {
    static let isEnabled = ProcessInfo.processInfo.arguments.contains("-ScreenshotMode")

    static func makeContainer() -> ModelContainer {
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
            let container = try ModelContainer(for: SelectedContact.self, configurations: configuration)
            for contact in sampleContacts() {
                container.mainContext.insert(contact)
                NotificationHelper.updateNextNotificationDateTimeFor(contact: contact)
            }
            return container
        } catch {
            fatalError("Failed to create the screenshot container: \(error)")
        }
    }

    /// The contact named by the `-ScreenshotContact <name>` launch argument,
    /// for displays that can't be driven by touch.
    static func contactToOpen(in container: ModelContainer) -> SelectedContact? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let flag = arguments.firstIndex(of: "-ScreenshotContact"), arguments.indices.contains(flag + 1) else {
            return nil
        }
        let name = arguments[flag + 1]
        var descriptor = FetchDescriptor<SelectedContact>(predicate: #Predicate { $0.name == name })
        descriptor.fetchLimit = 1
        let contact = try? container.mainContext.fetch(descriptor).first
        if contact == nil {
            Logger.store.error("No screenshot contact named \(name, privacy: .public)")
        }
        return contact
    }

    /// Weekdays and Theo's birthday are relative to today, so the Next CatchUps grid reads
    /// "Today" and "Tomorrow" whenever it's captured before 6 PM. Other dates change day to day.
    private static func sampleContacts() -> [SelectedContact] {
        // Stored dates are Gregorian, whatever the device's calendar.
        let calendar = NotificationHelper.gregorian()
        let today = calendar.component(.weekday, from: .now)
        func weekday(inDays days: Int) -> Int { (today - 1 + days) % 7 + 1 }
        func monthDay(inDays days: Int) -> String {
            let date = calendar.date(byAdding: .day, value: days, to: .now) ?? .now
            let components = calendar.dateComponents([.month, .day], from: date)
            return StoredDateFormat.monthDayString(month: components.month ?? 1, day: components.day ?? 1)
        }
        let unread = StoredDateFormat.string(from: calendar.date(byAdding: .hour, value: -2, to: .now) ?? .now)

        let maya = contact("Maya Rodriguez", colors: [.pink, .orange], preference: .weekly, hour: 18)
        maya.notification_preference_weekday = weekday(inDays: 0)
        maya.phone = "+1 415 555 0142"
        maya.email = "maya.rodriguez@example.com"
        maya.address = "1200 Lakeshore Ave, Oakland, CA"
        maya.birthday = "04-12"
        maya.anniversary = "09-08"

        let theo = contact("Theo Bennett", colors: [.teal, .blue], preference: .monthly, hour: 12)
        theo.notification_preference_weekday = weekday(inDays: 3)
        theo.notification_preference_week_of_month = 4
        theo.birthday = monthDay(inDays: 1)
        theo.phone = "+1 312 555 0188"

        let rose = contact("Grandma Rose", colors: [.purple, .pink], preference: .weekly, hour: 10)
        rose.notification_preference_weekday = weekday(inDays: 2)
        rose.phone = "+1 503 555 0117"

        let jordan = contact("Jordan Ellis", colors: [.green, .teal], preference: .weekly, hour: 19, minute: 30)
        jordan.notification_preference_weekday = weekday(inDays: 4)
        jordan.unread_badge_date_time = unread

        let priya = contact("Priya Shah", colors: [.orange, .yellow], preference: .quarterly, hour: 9)
        priya.notification_preference_quarterly_set_time =
            calendar.date(bySettingHour: 9, minute: 0, second: 0, of: .now) ?? .now
        priya.unread_badge_date_time = unread

        let sam = contact("Sam Okafor", colors: [.indigo, .cyan], preference: .monthly, hour: 17)
        sam.notification_preference_weekday = weekday(inDays: 6)
        sam.notification_preference_week_of_month = 3

        let lena = contact("Lena Fischer", colors: [.red, .orange], preference: .annually, hour: 8)
        lena.notification_preference_custom_month = 3
        lena.notification_preference_custom_day = 21

        let marcus = contact("Marcus Hill", colors: [.blue, .indigo], preference: .custom, hour: 15)
        marcus.notification_preference_custom_year = calendar.component(.year, from: .now) + 1
        marcus.notification_preference_custom_month = 2
        marcus.notification_preference_custom_day = 14

        return [maya, theo, rose, jordan, priya, sam, lena, marcus]
    }

    private static func contact(
        _ name: String,
        colors: [Color],
        preference: NotificationOption,
        hour: Int,
        minute: Int = 0
    ) -> SelectedContact {
        let contact = SelectedContact.sampleData
        contact.name = name
        contact.picture = avatar(for: name, colors: colors)
        contact.notification_preference = preference.rawValue
        contact.notification_preference_hour = hour
        contact.notification_preference_minute = minute
        contact.phone = ""
        contact.email = ""
        contact.address = ""
        contact.birthday = ""
        contact.anniversary = ""
        return contact
    }

    /// A Base64 PNG of the name's initials, stored the way contact photos are.
    private static func avatar(for name: String, colors: [Color]) -> String {
        let initials = String(name.split(separator: " ").compactMap(\.first))
        let renderer = ImageRenderer(content: ScreenshotAvatar(initials: initials, colors: colors))
        renderer.scale = 3
        return renderer.uiImage?.pngData()?.base64EncodedString() ?? ""
    }
}
#endif
