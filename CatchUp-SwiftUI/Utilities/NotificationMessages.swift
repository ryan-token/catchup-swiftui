//
//  NotificationMessages.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 10/22/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

/// The rotating bodies used for general CatchUp reminders.
nonisolated enum NotificationMessages {
    static let generalBodies = [
        "Now you can be best buddies again",
        "A little birdy told me they really miss you",
        "It's time to check back in",
        """
        You're a good friend. Good for you. Tell this person to get CatchUp too so it's not always \
        you who's reaching out
        """,
        "Today is the perfect day to get back in touch",
        "Remember to keep in touch with the people that matter most",
        "You know what they say: 'A CatchUp a day keeps the needy friends at bay'",
        "Have you written a physical letter in a while? Maybe give that a try this time. People like that",
        "Here's that reminder you set to check in with someone important. Maybe you'll make their day",
        """
        Once a good person, always a good person (you are a good person, and probably so is the person \
        you want to be reminded to CatchUp with)
        """,
        "Here's another reminder to get back in touch with ⬆️",
        "Time to get back in contact with one of your favorite people",
        "So nice of you to want to stay in touch with the people you care about",
        "You know they'll really appreciate it",
        "I'm not guilting you into this or anything, but this person will probably be sad if you don't say hello.",
        """
        You have this app, so you must be cool and nice. Now send a thoughtful message to this also cool \
        and nice person
        """,
        """
        Once upon a time, there was a nice person. The end. (Spoiler: you're the nice person - keep being \
        nice and reach out to your friend)
        """,
        "Another timely reminder to catch up. Just the way you wanted it",
        "Now is the time! Seize the moment!",
        "Good job keeping your friends close. Now keep your enemies closer 😉"
    ]

    static func randomGeneralBody() -> String {
        generalBodies.randomElement() ?? "Keep in touch"
    }
}
