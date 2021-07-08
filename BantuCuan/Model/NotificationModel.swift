//
//  NotificationModel.swift
//  ByteCoin
//
//  Created by Jehnsen Hirena Kane on 29/04/21.
//  Copyright © 2021 The App Brewery. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationModel {
    var userData = UserDefaults.standard
    func prepare (body: String) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (_, _) in
            // harusnya ad acode
        }
        let content = UNMutableNotificationContent()
        content.title = "Hey kamu, ayo cek market sekarang!"
        content.body = body
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: userData.string(forKey: "notificationSound") ?? "sound1.wav"))
//
        let date = Date().addingTimeInterval(6)
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute,.second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        center.add(request) { (error) in
            if let error = error {
                print(error)
            }
        }
        print("Notif sudah terpanggil")

    }
}
