//
//  AppDelegate.swift
//  positifeedy
//
//  Created by Evyn Gonzalez  on 9/11/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import UIKit
import Firebase
import CoreData
import GoogleMobileAds
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import IQKeyboardManagerSwift
import FirebaseDynamicLinks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

    var arrBookMarkLink : [String] = []
    var myDocID : String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["891430e50eb0d8ffb21a4a28013d829b"]
        Messaging.messaging().delegate = self
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        setRoot()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        return true
    }
    
    func setRoot() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if (UserDefaults.standard.value(forKey: "isLogin") as? Bool ?? false)
        {
            let vcHome = storyboard.instantiateViewController(withIdentifier: "MyTabbarVC") as! MyTabbarVC
            
            self.window?.rootViewController = vcHome
            self.window?.makeKeyAndVisible()
            
        }
        else
        {
            let welcomeViewController = storyboard.instantiateViewController(withIdentifier: "navLogin") as! UINavigationController
            
            self.window?.rootViewController = welcomeViewController
            self.window?.makeKeyAndVisible()
        }
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            self.handleIncomingDynamicLink(dynamicLink)
            return true
        } else {
            return GIDSignIn.sharedInstance().handle(url) || ApplicationDelegate.shared.application(application, open: url, sourceApplication: (options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String), annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        }
    }
    
    func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
        print(userActivity)
    }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { [weak self] (dynamiclink, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let dynamiclink = dynamiclink {
                self?.handleIncomingDynamicLink(dynamiclink)
            }
        }
        
        return handled
    }
    
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url else {
            print("That's wired.")
            return
        }
        
        print(url.absoluteString)
        
        guard let component = URLComponents(url: url, resolvingAgainstBaseURL: false), let queryItems = component.queryItems else {
            return
        }
        
        
        
        if component.path == "/share" {
            
            if (UserDefaults.standard.value(forKey: "isLogin") as? Bool ?? false) {
                
                var feedURL: String = ""
                for queryItem in queryItems {
                    if queryItem.name == "feedURL" {
                        feedURL = queryItem.value ?? ""
                        break
                    }
                }
                
                if feedURL != "" {
                    if self.window!.rootViewController != nil {
                        
                        var isWebOpened: Bool = false
                        for vc in ((self.window!.rootViewController as! MyTabbarVC).selectedViewController as! UINavigationController).viewControllers {
                            if vc is WebViewVC {
                                isWebOpened = true
                                break
                            }
                        }
                        if isWebOpened {
                            let dict = ["isBookmark": self.isBookMark(link: feedURL), "url": feedURL] as [String : Any]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RELOAD_WEB"), object: dict)

                        } else {
                            let webVC = storyBoard.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
                            webVC.url = feedURL
                            webVC.myDocID = self.myDocID
                            webVC.isBookmark = isBookMark(link: feedURL)
                            ((self.window!.rootViewController as! MyTabbarVC).selectedViewController as! UINavigationController).pushViewController(webVC, animated: true)
                        }
                    } else {
                        
                    }
                }
            }

            
        } else {
            
            if Auth.auth().isSignIn(withEmailLink: url.absoluteString) {
                
                guard let email = UserDefaults.standard.value(forKey: "emailRegister") as? String, let password = UserDefaults.standard.value(forKey: "passwordRegister") as? String else {
                    return
                }
                
                let firstName = UserDefaults.standard.value(forKey: "firstNameRegister") as? String ?? ""
                let lastName = UserDefaults.standard.value(forKey: "lastNameRegister") as? String ?? ""
                
                // Create the user
                Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                    
                    // Check for errors
                    if err != nil {
                        self.window!.rootViewController?.view.makeToast(err!.localizedDescription)
                    } else {
                        self.createUserCloudData(firstName: firstName, lastName: lastName, uid: result!.user.uid)
                    }
                }
                //
                //            Auth.auth().signIn(withEmail: email, link: url.absoluteString) { (user, error) in
                //                if error != nil {
                //                    self.window!.rootViewController?.view.makeToast(error!.localizedDescription)
                //                } else {
                //
                //
                //
                //                    let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                //                    Auth.auth().currentUser?.link(with: credential) { authData, error in
                //                        if error != nil {
                //                        self.window!.rootViewController?.view.makeToast(error!.localizedDescription)
                //                        return
                //                      } else {
                //                          self.createUserCloudData(firstName: firstName, lastName: lastName, uid: user!.user.uid)
                //                      }
                //                      // The provider was successfully linked.
                //                      // The phone user can now sign in with their phone number or email.
                //                    }
                //
                //                }
                //            }
            }
        }
        
        

    }
    
    func createUserCloudData(firstName: String, lastName: String, uid: String) {
        
        // User was created successfully, now store the first name and last name
        let db = Firestore.firestore()
        
        db.collection("users").addDocument(data: ["firstname":firstName, "lastname":lastName, "uid": uid]) { (error) in
            
            if error != nil {
                // Show error message
                self.window!.rootViewController?.view.makeToast(error!.localizedDescription)
                return
            }
            
            UserDefaults.standard.removeObject(forKey: "emailRegister")
            UserDefaults.standard.removeObject(forKey: "passwordRegister")
            
            UserDefaults.standard.set(true, forKey: "isLogin")
            
            // Transition to the home screen
            self.setRoot()
        }
    }
    
    func isBookMark(link: String) -> Bool
    {
        let ind = self.arrBookMarkLink.firstIndex(of: link) ?? -1
        if ind > -1
        {
            return true
        }
        
        return false
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
       // If you are receiving a notification message while your app is in the background,
       // this callback will not be fired till the user taps on the notification launching the application.
       // TODO: Handle data of notification
       // With swizzling disabled you must let Messaging know about the message, for Analytics
       // Messaging.messaging().appDidReceiveMessage(userInfo)
       // Print message ID.
//       if let messageID = userInfo[gcmMessageIDKey] {
//         print("Message ID: \(messageID)")
//       }

       // Print full message.
       print(userInfo)
     }
    
    
      func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                       fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//          print("Message ID: \(messageID)")
//        }

        // Print full message.
        print(userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
      }
      // [END receive_message]
      func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
      }

      // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
      // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
      // the FCM registration token.
      func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")

        // With swizzling disabled you must set the APNs token here.
         Messaging.messaging().apnsToken = deviceToken
      }


    
lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "positifeedy")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
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
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    
}


extension AppDelegate : UNUserNotificationCenterDelegate
{
      func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
     {
         print("willPresent notification")
        completionHandler([.alert, .badge, .sound])
    }
    
    
      func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
     {
         print("didReceive notification")
        completionHandler()
    }
}


extension AppDelegate : MessagingDelegate
{
 
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
     //   NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
      }
      // [END refresh_token]
     
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        
        print( remoteMessage.appData)
    }
}



extension UIApplication {

    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }

}
