import UserNotifications

@available(iOS 11.0, *)
class NasaLocalNotificationBuilder {
    private let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
    private var notificationActions: [UNNotificationAction] = []
    private var notificationContent = UNMutableNotificationContent()

    func setActions() -> NasaLocalNotificationBuilder {
        notificationActions.append(
            UNNotificationAction(identifier: "view",
                                 title: "View Photo in app",
                                 options: [.foreground, .authenticationRequired])
        )
        notificationActions.append(
            UNNotificationAction(identifier: "skip",
                                 title: "Skip",
                                 options: [])
        )
        return self
    }

    @available(iOS 11.0, *)
    func setCategory() -> NasaLocalNotificationBuilder {
        if #available(iOS 11.0, *) {
            let notificationCategory = UNNotificationCategory(identifier: "NasaDailyPhoto",
                                                              actions: notificationActions,
                                                              intentIdentifiers: [],
                                                              hiddenPreviewsBodyPlaceholder: "",
                                                              options: .customDismissAction)
            notificationCenter.setNotificationCategories([notificationCategory])
        }
        return self
    }

    @available(iOS 15.2, *)
    func setContent() -> NasaLocalNotificationBuilder {
        
        notificationContent.title = "Your Nasa Daily Photo"
        notificationContent.body = "Long press to see you daily nasa photo"
        notificationContent.sound = UNNotificationSound.defaultRingtone
        notificationContent.categoryIdentifier = "NasaDailyPhoto"
        return self
    }

    func build() {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "NasaDailyPhoto",
                                            content: notificationContent,
                                            trigger: trigger)
        notificationCenter.add(request, withCompletionHandler: nil)
    }
}
