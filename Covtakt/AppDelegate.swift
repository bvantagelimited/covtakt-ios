import UIKit
import CoreData
import Firebase
import FirebaseAuth
import FirebaseRemoteConfig
import CoreMotion
import Localize_Swift
import FirebaseMessaging
import SwiftyJSON
import SwiftMessages
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var pogoMM: PogoMotionManager!
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("didRegisterForRemoteNotificationsWithDeviceToken")
        Messaging.messaging().apnsToken = deviceToken
        //        print(isPRODUCTION)
        Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
        
        let savedDeviceToken = UserDefaults.standard.object(forKey: "deviceToken") as? String
        if savedDeviceToken == nil {
            let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
            UserDefaults.standard.set(token, forKey: "deviceToken")
            UserDefaults.standard.synchronize()
            print(token)
        }
    }
    
    private func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // Let FCM know about the message for analytics etc.
        Messaging.messaging().appDidReceiveMessage(userInfo)
        print("didReceiveRemoteNotification")
        // handle your message
        
        
        //         if let messageID = userInfo[gcmMessageIDKey] {
        //             print("Message ID didReceiveRemoteNotification fetchCompletionHandler: \(messageID)")
        //         }
        //
        let state = UIApplication.shared.applicationState
        if state == .background {
            print("App in Background")
        }else if state == .active {
            print("App in Foreground or Active")
        }
        else {
            print("App in InActive")
        }
        
        // Print full message.
        print(userInfo)
        let userInfoJSON = JSON(userInfo)
        
        if(userInfoJSON["com.google.firebase.auth"] != nil && userInfoJSON["com.google.firebase.auth"]["warning"] == "This fake notification should be forwarded to Firebase Auth."){
            completionHandler(.noData)
            return
        }
//        let isPrebook = userInfoJSON["pre_book"].boolValue
    }
    func configApplePush(_ application: UIApplication) {
//        if #available(iOS 10.0, *) {
//            // For iOS 10 display notification (sent via APNS)
////            UNUserNotificationCenter.current().delegate = self
//            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//            UNUserNotificationCenter.current().requestAuthorization(
//                options: authOptions,
//                completionHandler: {_, _ in })
//        } else {
//            let settings: UIUserNotificationSettings =
//                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            application.registerUserNotificationSettings(settings)
//        }
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        if let token = Messaging.messaging().fcmToken {
            print("FCM token: \(token)")
            let deviceToken = UserDefaults.standard.object(forKey: "deviceToken") as? String
            if deviceToken == nil || deviceToken! != token {
                UserDefaults.standard.set(token, forKey: "deviceToken")
                UserDefaults.standard.synchronize()
                //                NotificationCenter.default.post(name: NSNotification.Name.RegisterToken, object: nil)
            }
        }
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Localize.setCurrentLanguage("en")
        Bundle.set(language: Language.english(Language.English.us))
        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        //configure the database manager
        self.configureDatabaseManager()
        
        //the below can be in a single configure method inside the BluetraceManager
        let bluetoothAuthorised = BluetraceManager.shared.isBluetoothAuthorized()
        if  OnboardingManager.shared.completedBluetoothOnboarding && bluetoothAuthorised {
            BluetraceManager.shared.turnOn()
        } else {
            print("Onboarding not yet done.")
        }
        
       
        UIApplication.shared.isIdleTimerDisabled = true
        
       
        
        // setup pogo mode
        pogoMM = PogoMotionManager(window: self.window)
        
        // Remote config setup
        _ = TracerRemoteConfig()
        
        if !OnboardingManager.shared.completedIWantToHelp {
            do {
                try Auth.auth().signOut()
            } catch {
                Logger.DLog("Unable to signout")
            }
        }
        navigateToCorrectPage(application: application)
         EncounterMessageManager.shared.setup()
         BlueTraceLocalNotifications.shared.initialConfiguration()
        return true
    }
    
    func navigateToCorrectPage(application: UIApplication) {
        let navController = self.window!.rootViewController! as! UINavigationController
        let storyboard = navController.storyboard!
        configApplePush(application)
        let launchVCIdentifier = OnboardingManager.shared.returnCurrentLaunchPage()
        let vc = storyboard.instantiateViewController(withIdentifier: launchVCIdentifier)
        navController.setViewControllers([vc], animated: false)
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "tracer")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func configureDatabaseManager() {
        DatabaseManager.shared().persistentContainer = self.persistentContainer
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        Logger.DLog("applicationDidBecomeActive")
        pogoMM.startAccelerometerUpdates()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        Logger.DLog("applicationWillResignActive")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Logger.DLog("applicationDidEnterBackground")
        
        let magicNumber = Int.random(in: 0 ... PushNotificationConstants.btStatusPushNotifContents_rs.count - 1)
        pogoMM.stopAllMotion()
        
        BlueTraceLocalNotifications.shared.removePendingNotificationRequests()
        
        BlueTraceLocalNotifications.shared.triggerCalendarLocalPushNotifications(pnContent: PushNotificationConstants.btStatusPushNotifContents_rs[magicNumber], identifier: "appBackgroundNotifId")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        Logger.DLog("applicationWillEnterForeground")
        pogoMM.stopAllMotion()
        BluetraceUtils.removeData14DaysOld()
        
        BlueTraceLocalNotifications.shared.removePendingNotificationRequests()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        Logger.DLog("applicationWillTerminate")
        pogoMM.stopAllMotion()
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}



extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")

//        let dataDict:[String: String] = ["token": fcmToken]
        
        let deviceToken = UserDefaults.standard.object(forKey: "deviceToken") as? String
        if deviceToken == nil || deviceToken! != fcmToken {
            UserDefaults.standard.set(fcmToken, forKey: "deviceToken")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Notification.Name("RefreshFCMToken"), object: nil, userInfo: nil)
        }
    }
}
