# CatchUp: Keep in Touch

Keep in touch with your friends, family, business associates, and anyone else in your iOS Contacts list. Pick the people you want to stay close to, choose how often, and CatchUp reminds you when it's time to catch up with them again.

Free with no ads!

[Download on the App Store](https://apps.apple.com/us/app/catchup-keep-in-touch/id1358023550)

*Step One*: Add Contacts

*Step Two*: Set your Notification Preference (how often you want to be reminded to catch up with that individual)

*Step Three*: There is no step three

## Features

- **Reminders:** daily, weekly, monthly, quarterly, annually, or a custom day that you pick, at whatever time of day you choose. They arrive even when you're not connected to the internet.
- **Birthdays and anniversaries:** automatic reminders for any you have set in your Contacts app.
- **Up next:** a grid of your upcoming catchups, with unread indicators for the contacts it's time to CatchUp with.
- **Contact details:** call, email, or open an address in Maps right from a contact.
- **Notes:** save notes for each contact, like what you talked about last time or what to ask about next, synced through iCloud with everything else.
- **Fresh info:** pull down on the home screen to update your contacts' pictures and information.
- **Sync:** your contacts and preferences, synced across your Apple devices with iCloud.
- **Tip Jar:** CatchUp is a passion project that honestly helps me out, and I'd rather not muddy the waters with advertising I can't control. If you'd like to support development, you're welcome to leave a tip.

It runs on iPhone and iPad, with full light and dark mode support, and can open in several windows at once on iPad and on both displays of iPhone Duo.

## How it's built

Swift 6 and SwiftUI, with one third-party dependency, [PhoneNumberKit](https://github.com/marmelroy/PhoneNumberKit), for formatting phone numbers. It requires iOS 26.

99% of the user interface is SwiftUI. The contact picker is the only bridge into UIKit.

| Folder | Holds |
| --- | --- |
| `CatchUp-SwiftUI/CatchUpApp.swift` | The app's entry point and its SwiftData container |
| `CatchUp-SwiftUI/Views` | The home, detail, about, and updates screens, each with a folder of its subviews |
| `CatchUp-SwiftUI/ViewModels` | `NotificationPreferenceModel`, the `@Observable` model behind a contact's reminder settings |
| `CatchUp-SwiftUI/Data` | `SelectedContact`, the SwiftData model, and the reminder options |
| `CatchUp-SwiftUI/Services` | Tips with StoreKit 2, opening the contact whose notification you tapped, and once-per-launch setup |
| `CatchUp-SwiftUI/Utilities` | Reading from Contacts, and scheduling and rescheduling local notifications |
| `CatchUp-SwiftUI/Extensions` | Small additions to SwiftData, UserNotifications, and logging |
| `CatchUp-SwiftUI/Screenshots` | A Debug-only mode that loads made-up contacts for App Store screenshots |
| `CatchUpTests` | Unit tests, written with Swift Testing |

All persistence is done with SwiftData, synced through your own iCloud account with CloudKit. It still reads the SQLite file Core Data created in earlier versions, so updating never loses anyone. Reminders are local notifications scheduled on your device, and resets run one at a time so two can never interleave and leave a contact with duplicate or missing reminders.

## A note on privacy

I store NONE of your contacts or any of your personal information. The contacts you choose and the preferences you set for them stay on your device and in your own iCloud account, and are never sent to my servers or anywhere else. Read my full privacy policy at https://ryantoken.com/privacy-policy

## Press

- [Featured on TapSmart](https://www.tapsmart.com/features/catchup-apps-roundup/)
- [Featured on Brett Terpstra's *Systematic* Podcast](https://esn.fm/systematic/218) (around the 46:00 mark)
- [Featured once in Germany on iPhone-Ticker.de](https://www.iphone-ticker.de/catchup-app-hilft-in-kontakt-zu-bleiben-160121/)
- [Featured again in Germany on iPhone-Ticker.de](https://www.iphone-ticker.de/catchup-3-0-app-erinnert-an-freunde-und-bekannte-232703/)
