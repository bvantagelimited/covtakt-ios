//
//  PushNotificationConstants.swift
//  OpenTrace
import UIKit

struct PushNotificationConstants {
    // Bluetooth Status
    static let btStatusPushNotifContents = [
        [
            "contentTitle": "Turned Bluetooth off by mistake?",
            "contentBody": "Help stop the spread of COVID-19 by keeping your phone’s Bluetooth on until the outbreak is over."
        ]
    ]

    // Daily Reminders
    static let dailyRemPushNotifContents = [
        [
            "contentTitle": "We need you!",
            "contentBody": "Help stop the spread of COVID-19 by keeping your Bluetooth on and the app open in power saver mode when you’re in meetings, public spaces, or public transport."
        ]
    ]
    
    
    // Bluetooth Status
    static let btStatusPushNotifContents_rs = [
        [
            "contentTitle": "Greškom ste isključili Bluetooth?",
            "contentBody": "Pomozite da se zaustavi širenje COVID-19 tako što ćete Bluetooth držati uključenim do kraja epidemije."
        ]
    ]

    // Daily Reminders
    static let dailyRemPushNotifContents_rs = [
        [
            "contentTitle": "Potrebni ste nam!",
            "contentBody": "Pomozite da se zaustavi širenje COVID-19 tako što ćete Bluetooth držati uključenim, a aplikaciju otvorenom u režimu uštede energije, dok ste na sastancima, na javnim mestima ili u javnom prevozu."
        ]
    ]
}

extension Notification.Name {
    //JobsScreenViewController
    static let NotificationAlert = Notification.Name("Notification")
    static let BecomeActive = Notification.Name("BecomeActive")
}
