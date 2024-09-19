//
//  FCM_TestApp.swift
//  FCM-Test
//
//  Created by Denys on 10.09.2024.
//

import SwiftUI
import FirebaseMessaging
import FirebaseAnalytics
import UserNotificationsUI
import FirebaseCore


@main
struct FCM_TestApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}



class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func sendFCMTokenToServer(fcmToken: String) {
        // Укажите URL вашего сервера с токеном как параметром
        let urlString = "https://applemaze.info/api/fcm-test.php?token=\(fcmToken)"
        
        // Преобразуем строку в URL
        guard let url = URL(string: urlString) else {
            print("Некорректный URL")
            return
        }
        
        // Формируем запрос
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // Указанный URL предполагает использование GET запроса
        
        // Отправляем запрос
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Проверяем на ошибки
            if let error = error {
                print("Ошибка запроса: \(error.localizedDescription)")
                return
            }
            
            // Проверяем статус-код ответа
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Токен успешно отправлен на сервер")
            } else {
                print("Ошибка сервера или некорректный ответ")
            }
        }
        
        // Выполняем запрос
        task.resume()
    }
    
    static var orientationLock = UIInterfaceOrientationMask.all

    var window: UIWindow?

    // Called when the application is about to finish launching
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // Set the messaging delegate
        Messaging.messaging().delegate = self
        
        // Register for remote notifications
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    

    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications with error: \(error.localizedDescription)")
    }
}

// MARK: - Messaging Delegate
extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        sendFCMTokenToServer(fcmToken: fcmToken!)
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}

// MARK: - UNUserNotificationCenterDelegate
@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([[.alert, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}
