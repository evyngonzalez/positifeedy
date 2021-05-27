//
//  AppDelegate.swift
//  positifeedy
//
//  Created by Evyn Gonzalez  on 9/11/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

//com.weapp.recipeapp
//com.staypos.StayPositive

// local : ca-app-pub-3940256099942544~1458002511
// live : ca-app-pub-5392374810652881~7194283561

// live : Native Ad Unit ID: ca-app-pub-5392374810652881/4568120220



import UIKit
import Firebase
import CoreData
import GoogleMobileAds
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import IQKeyboardManagerSwift
import FirebaseDynamicLinks
import LinkPresentation
import StoreKit
import SwiftyStoreKit
import AuthenticationServices

struct IN_APP_PURCHASE {

    //static let BUY_ANNUAL_PLAN = "annual.subs"
    //static let BUY_MONTHLY_PLAN = "monthly.subs"
    
    static let BUY_ANNUAL_PLAN = "journal.yearly"
    static let BUY_MONTHLY_PLAN = "journal.monthly"
    
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

    var arrBookMarkLink : [String] = []
    var arrBookMarkLinkFeedy : [String] = []
    var arrBookMarkLinkBookMark : [timeStampandData] = []

    var myDocID : String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
                
       // UserDefaults.standard.register(defaults: ["UserAgent" : "iOS-CompanyName/versionNumber"])
        
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        //GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["891430e50eb0d8ffb21a4a28013d829b"]
        //GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["970c6883a45372bb5e1343fd1d951c22"]
        Messaging.messaging().delegate = self
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
//        var db: Firestore!
//        db = Firestore.firestore()
//        let d = ["Affirmation" : arrTheme]
//
//        db.collection("Affirmation").addDocument(data: dict as! [String : Any]) { (error) in
//             if error != nil
//             {
//                 print(error!.localizedDescription)
//             }
//        }

        if #available(iOS 13, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: KeychainItem.currentUserIdentifier ?? "") { (credentialState, error) in
                switch credentialState {
                case .authorized:
                    // The Apple ID credential is valid. Show Home UI Here
                    DispatchQueue.main.async {
                        //HomeViewController.Push()
                    }
                    break
                case .revoked:
                    // The Apple ID credential is revoked. Show SignIn UI Here.
                    break
                case .notFound:
                    // No credential was found. Show SignIn UI Here.
                    break
                default:
                    break
                }
            }
        }
        
        
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
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        application.registerForRemoteNotifications()
        
        setRoot()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
//        for obj in arrFeedy {
//            self.addFeedyPost(data: obj)
//        }
  
        // set current date first time :
        if KeychainItem.store_start_date != nil
        {
            
           if KeychainItem.store_start_date !=  ""
           {
                //KeychainItem.store_start_date = ""
                let dateString = KeychainItem.store_start_date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let start_date = dateFormatter.date(from: dateString!)
                let final_date = Date()
                let diff = final_date.interval(ofComponent: .day, fromDate: start_date!)
                print("diffrent day :\(diff)")
                
                // here in future set 100
                if diff > 100
                {
                    UserDefaults.standard.setValue(0, forKey: PREF_DAILY_QUESTION_COUNT)
                    
                    let date = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let dateString = dateFormatter.string(from: date)
                    KeychainItem.store_start_date = dateString

                }
                else
                {
                    UserDefaults.standard.setValue(diff, forKey: PREF_DAILY_QUESTION_COUNT)
                }
            }
            else
            {
                    let date = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let dateString = dateFormatter.string(from: date)
                    KeychainItem.store_start_date = dateString
                    
                    let dateString1 = dateString
                    let dateFormatter1 = DateFormatter()
                    dateFormatter1.dateFormat = "yyyy-MM-dd"
                    let start_date = dateFormatter1.date(from: dateString1)
                    let final_date = Date()
                    let diff = final_date.interval(ofComponent: .day, fromDate: start_date!)
                    print("diffrent day :\(diff)")
                    UserDefaults.standard.setValue(0, forKey: PREF_DAILY_QUESTION_COUNT)
            }
        }
        else
        {
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)
            KeychainItem.store_start_date = dateString
            
            let dateString1 = dateString
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "yyyy-MM-dd"
            let start_date = dateFormatter1.date(from: dateString1)
            let final_date = Date()
            let diff = final_date.interval(ofComponent: .day, fromDate: start_date!)
            print("diffrent day :\(diff)")
            UserDefaults.standard.setValue(0, forKey: PREF_DAILY_QUESTION_COUNT)
        }
        
        
       /* let prefdate = UserDefaults.standard.object(forKey: PREF_CURRENT_DATE) as? String
        if prefdate != nil
        {
            let dateString = prefdate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let start_date = dateFormatter.date(from: dateString!)
            let final_date = Date()
            let diff = final_date.interval(ofComponent: .day, fromDate: start_date!)
            print("diffrent day :\(diff)")
            
            // here in future set 100
            if diff > 10
            {
                UserDefaults.standard.setValue(1, forKey: PREF_DAILY_QUESTION_COUNT)
            }
            else
            {
                UserDefaults.standard.setValue(diff, forKey: PREF_DAILY_QUESTION_COUNT)
            }
            
            
//            let dateFormatter1 = DateFormatter()
//            dateFormatter1.dateFormat = "yyyy-MM-dd"
//            let final_date = dateFormatter1.date(from: "2020-12-20")
            
            

            
        }
        else
        {
            
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)
            UserDefaults.standard.setValue(dateString, forKey: PREF_CURRENT_DATE)
            
            let dateString1 = dateString
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "yyyy-MM-dd"
            let start_date = dateFormatter1.date(from: dateString1)
            let final_date = Date()
            let diff = final_date.interval(ofComponent: .day, fromDate: start_date!)
            print("diffrent day :\(diff)")
            UserDefaults.standard.setValue(diff, forKey: PREF_DAILY_QUESTION_COUNT)
        }
        */
        
        completeIAPTransactions()
        checkIfPurchaed()
        
        return true
    }
    
    
    func updateSubscription(isPurchased: Bool){
        if(self.myDocID != nil && self.myDocID != ""){
            let subscription = isPurchased ? "1" : "0"
            let d = ["Subscription" : subscription]
            var db: Firestore!
            db = Firestore.firestore()
            db.collection("users").document(self.myDocID!).updateData(d) { (error) in
                 if error != nil
                 {
                     print(error!.localizedDescription)
                 }
            }
        }
    }
    
     func checkIfPurchaed () {
            
            // monthly plan :
//            let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "eb8e064a837a42c5b7f9e7910f517911")
//            SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
//                switch result {
//                case .success(let receipt):
//                    let productId = IN_APP_PURCHASE.BUY_MONTHLY_PLAN
//                    // Verify the purchase of a Subscription
//                    let purchaseResult = SwiftyStoreKit.verifySubscription(
//                        ofType: .autoRenewable, //or .nonRenewing
//                        productId: productId,
//                        inReceipt: receipt)
//
//                    var isPurchased = false
//                    switch purchaseResult {
//                    case .purchased(let expiryDate, let items):
//                        isPurchased = true
//                        let currentdate = Date()
//                        if currentdate.isGreaterThan(expiryDate)
//                        {
//                            //alerady expired !
//                            UserDefaults.standard.removeObject(forKey: PREF_SUBSCRIBE_MONTH)
//                        }
//                        else
//                        {
//                            UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE_MONTH)
//                        }
//                        print("\(productId) is valid until \(expiryDate)\n\(items)\n")
//
//                        //UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE)
//                    case .expired(let expiryDate, let items):
//                        print("\(productId) is expired since \(expiryDate)\n\(items)\n")
//                        isPurchased = false
//                        let currentdate = Date()
//                        if currentdate.isGreaterThan(expiryDate)
//                        {
//                            //alerady expired !
//                            UserDefaults.standard.removeObject(forKey: PREF_SUBSCRIBE_MONTH)
//                        }
//                        else
//                        {
//                            UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE_MONTH)
//                        }
//                       //  UserDefaults.standard.removeObject(forKey: PREF_SUBSCRIBE)
//                    case .notPurchased:
//                        isPurchased = false
//                        print("The user has never purchased \(productId)")
//                    }
//                    self.updateSubscription(isPurchased: isPurchased)
//                case .error(let error):
//                    print("Receipt verification failed: \(error)")
//                }
//            }
            
            // Annual Plan :
            
            let appleValidator1 = AppleReceiptValidator(service: .production, sharedSecret: "eb8e064a837a42c5b7f9e7910f517911")
            SwiftyStoreKit.verifyReceipt(using: appleValidator1) { result in
                switch result {
                case .success(let receipt):
                    let productId = IN_APP_PURCHASE.BUY_ANNUAL_PLAN
                    // Verify the purchase of a Subscription
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable, //or .nonRenewing
                        productId: productId,
                        inReceipt: receipt)
                    var isPurchased = false
                    switch purchaseResult {
                    case .purchased(let expiryDate, let items):
                        isPurchased = true
                        let currentdate = Date()
                        if currentdate.isGreaterThan(expiryDate)
                        {
                            //already expired!
                            UserDefaults.standard.removeObject(forKey: PREF_SUBSCRIBE_ANNUAL)
                        }
                        else
                        {
                            UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE_ANNUAL)
                        }
                        
                        print("\(productId) is valid until \(expiryDate)\n\(items)\n")
                        //UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE_ANNUAL)
                        
                        //UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE)
                    case .expired(let expiryDate, let items):
                        isPurchased = false
                        print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                        
                        
                        let currentdate = Date()
                        if currentdate.isGreaterThan(expiryDate)
                        {
                            //alerady expired !
                            UserDefaults.standard.removeObject(forKey: PREF_SUBSCRIBE_ANNUAL)
                        }
                        else
                        {
                            UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE_ANNUAL)
                        }
                        
                        //UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE)
                        //UserDefaults.standard.removeObject(forKey: PREF_SUBSCRIBE)
                    case .notPurchased:
                        isPurchased = false
                        print("The user has never purchased \(productId)")
                    }
                    self.updateSubscription(isPurchased: isPurchased)

                case .error(let error):
                    print("Receipt verification failed: \(error)")
                }
            }
            
            
            let annual = UserDefaults.standard.object(forKey: PREF_SUBSCRIBE_ANNUAL) as? String
            let monthly = UserDefaults.standard.object(forKey: PREF_SUBSCRIBE_MONTH) as? String
            
            if annual != nil || monthly != nil
            {
                UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE)
                
                
            }
            else
            {
                //No any item subscribe!
                UserDefaults.standard.removeObject(forKey: PREF_SUBSCRIBE)
            }
       

        }
        
        //MARK:- In App Purchase Code :

        func completeIAPTransactions()
        {
           
            SwiftyStoreKit.completeTransactions(atomically: true) { purchases in

                print("purchases:\(purchases)")

                for purchase in purchases {
                    switch purchase.transaction.transactionState {
                    case .purchased, .restored:
                        if purchase.needsFinishTransaction {
                            // Deliver content from server, then:
                            SwiftyStoreKit.finishTransaction(purchase.transaction)
                        }
                        print("\(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                        print("Last :\(purchase.productId)")
                    case .failed, .purchasing, .deferred:
                        break // do nothing
                    }
                }
            }
        }

        func retrieveInAppPurchase(){
               SwiftyStoreKit.retrieveProductsInfo([IN_APP_PURCHASE.BUY_ANNUAL_PLAN]) { result in
                   
                   if let product : SKProduct = result.retrievedProducts.first {
                       print(product)
                   }
                   else if let invalidProductId = result.invalidProductIDs.first {
                       print(invalidProductId)
                   }
                   else {
                       
                   }
               }
           }

        func restoreInAppPurchase(_ isInitially:Bool = false){
               
               if(isInitially == false){
                   //showLoader()
               }
               //NetworkActivityIndicatorManager.networkOperationStarted()
               SwiftyStoreKit.restorePurchases(atomically: true) { results in
                 //  NetworkActivityIndicatorManager.networkOperationFinished()
                   if(isInitially == false){
                   //    self.removeLoader()
                   }
                   if results.restoreFailedPurchases.count > 0 {
                       if(isInitially == false){
                        
                        print("Restore Failed")
    //                       showAlert("", message: "Restore Failed", completion: {
    //
    //                       })
                       }
                   }
                   else if results.restoredPurchases.count > 0 {
                       for i in 0..<results.restoredPurchases.count{
                           print("Purchase : ", results.restoredPurchases[i].productId)
                       }
                       if(isInitially == false){
                          // displayToast("Restored successfully.")
                        print("Restore successfully")
                       }
                   }
                   else {
                       if(isInitially == false){
                        print("Nothing to Restore")
    //                       showAlert("", message: "Nothing to Restore", completion: {
    //
    //                       })
                       }
                   }
               }
           }
    
    
    
    func addFeedyPost(data: [String: String]) {
        
        let db = Firestore.firestore()
        
        db.collection("Positifeedy").addDocument(data: data) { (error) in
            
            if error != nil {
                // Show error message
                print("Error saving user data")
                return
            }
        }
    }
    
    func setRoot() {
        
        let storyboard = UIStoryboard(name: "Enhancement", bundle: nil)
        if (UserDefaults.standard.value(forKey: "isLogin") as? Bool ?? false)
               {
                   
                   let vcHome = storyboard.instantiateViewController(withIdentifier: "MyTabbarVC") as! MyTabbarVC
                   
                   self.window?.rootViewController = vcHome
                   self.window?.makeKeyAndVisible()
                   
               }
//               let vc = storyboard.instantiateViewController(withIdentifier: "AdminLoginViewController") as! AdminLoginViewController
//                      self.navigationController?.pushViewController(vc, animated: true)
        
      //  let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if (UserDefaults.standard.value(forKey: "isLogin") as? Bool ?? false)
//        {
//
//            let vcHome = storyboard.instantiateViewController(withIdentifier: "MyTabbarVC") as! MyTabbarVC
//
//            self.window?.rootViewController = vcHome
//            self.window?.makeKeyAndVisible()
//
//        }
        else
        {
            UserDefaults.standard.removeObject(forKey: "UserProfileImage")
            UserDefaults.standard.synchronize()

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let welcomeViewController = storyboard.instantiateViewController(withIdentifier: "navLogin") as! UINavigationController

            self.window?.rootViewController = welcomeViewController
            self.window?.makeKeyAndVisible()
        }
    }
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
       let strUrl = String.init(format: "%@", url as CVarArg)
        print("str url :\(strUrl)")
        if strUrl.contains("fb")
        {
            if #available(iOS 9.0 , *){
                return ApplicationDelegate.shared.application(application, open: url, sourceApplication: "UIApplicationOpenURLOptionsKey", annotation: nil)
            }
            return true
        }
        else
        {
            return true
        }
        
    }
     
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        
        let strUrl = String.init(format: "%@", url as CVarArg)
        print("str url :\(strUrl)")
        if strUrl.contains("fb")
        {
            if #available(iOS 9.0 , *){
                return ApplicationDelegate.shared.application(application, open: url, sourceApplication: "UIApplicationOpenURLOptionsKey", annotation: nil)
            }
            
            return true

            
        }else
        {
            if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
                self.handleIncomingDynamicLink(dynamicLink)
                return true
            } else {
                return GIDSignIn.sharedInstance().handle(url) || ApplicationDelegate.shared.application(application, open: url, sourceApplication: (options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String), annotation: options[UIApplication.OpenURLOptionsKey.annotation])
            }
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
            
            setRoot()
            
            if (UserDefaults.standard.value(forKey: "isLogin") as? Bool ?? false) {
                
                var dict = [String: Any]()
                
                var feedURL: String = ""
                for queryItem in queryItems {
                    if queryItem.name == "feedURL" {
                        feedURL = queryItem.value ?? ""
                        dict["feedURL"] = feedURL
                    }
                    if queryItem.name == "feedTitle" {
                        let val = queryItem.value ?? ""
                        if let base64Decoded = Data(base64Encoded: val, options: Data.Base64DecodingOptions(rawValue: 0))
                        .map({ String(data: $0, encoding: .utf8) }) {
                            dict["feedTitle"] = base64Decoded ?? ""
                        }
                    }
                    if queryItem.name == "feedDesc" {
                        let val = queryItem.value ?? ""
                        if let base64Decoded = Data(base64Encoded: val, options: Data.Base64DecodingOptions(rawValue: 0))
                        .map({ String(data: $0, encoding: .utf8) }) {
                            dict["feedDesc"] = base64Decoded ?? ""
                        }
                    }
                    
                    if queryItem.name == "feedVideo" {
                        dict["feedVideo"] = queryItem.value ?? ""
                    }
                    if queryItem.name == "feedImage" {
                        dict["feedImage"] = queryItem.value ?? ""
                    }
                    if queryItem.name == "feedType" {
                        dict["feedType"] = queryItem.value ?? ""
                    }
                    if queryItem.name == "feedTime" {
                        dict["feedTime"] = queryItem.value ?? ""
                    }
                    if queryItem.name == "feedLink" {
                        dict["feedLink"] = queryItem.value ?? ""
                    }
                }
                
                if feedURL != "" {
                    if self.window!.rootViewController != nil {
                        
                        var isWebOpened: Bool = false
                        var isDetailOpened: Bool = false
                        var isWebFeedyOpened: Bool = false

                        for vc in ((self.window!.rootViewController as! MyTabbarVC).selectedViewController as! UINavigationController).viewControllers {
                            if vc is WebViewVC {
                                isWebOpened = true
                                break
                            }
                            if vc is PostDetailViewController {
                                isDetailOpened = true
                                break
                            }
                            if vc is WebViewFeedy {
                                isWebFeedyOpened = true
                                break
                            }
                        }
                        
                        dict["isBookmark"] = self.isBookMark(link: feedURL)

                        if feedURL.contains("http") { // web case
                            
                                
                                if isWebOpened {
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RELOAD_WEB"), object: dict)

                                } else {
                                    let webVC = storyBoard.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
                                    webVC.url = feedURL
                                    webVC.myDocID = self.myDocID
                                    webVC.isBookmark = isBookMark(link: feedURL)
                                    ((self.window!.rootViewController as! MyTabbarVC).selectedViewController as! UINavigationController).pushViewController(webVC, animated: true)
                                }
                            
                            
                        } else { // positifeedy case
                            
                            let obj = PositifeedAllSet.init(
                                title: dict["feedTitle"] as? String,
                                desc: dict["feedDesc"] as? String,
                                feed_type: dict["feedType"] as? String,
                                feed_url: dict["feedLink"] as? String,
                                feed_image: dict["feedImage"] as? String,
                                feed_video: dict["feedVideo"] as? String,
                                timestamp: dict["feedTime"] as? String,
                                documentID: dict["feedURL"] as? String,
                                
                                link: (dict["link"] as? String) ?? "", guid: (dict["guid"] as? String) ?? "",
                                time: (dict["time"] as? String) ?? "", description_d: (dict["description_d"] as? String) ?? ""
                                
                            )
                            
                            if (dict["feedType"] as? String ?? "") == "link" {
                                
                                if isWebFeedyOpened {
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RELOAD_WEB_FEED"), object: dict)

                                } else {
                                    let webVC = storyBoard.instantiateViewController(withIdentifier: "WebViewFeedy") as! WebViewFeedy
                                    webVC.positifeedy = obj
                                    webVC.myDocID = self.myDocID
                                    webVC.isBookmark = isBookMark(link: feedURL)
                                    ((self.window!.rootViewController as! MyTabbarVC).selectedViewController as! UINavigationController).pushViewController(webVC, animated: true)
                                }
                                
                            } else {
                                if isDetailOpened {
                                    
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RELOAD_DETAIL"), object: dict)
                                    
                                } else {
                                    
                                    let webVC = storyBoard.instantiateViewController(withIdentifier: "PostDetailViewController") as! PostDetailViewController
                                    webVC.positifeedy = obj
                                    webVC.myDocID = self.myDocID
                                    webVC.isBookmark = isBookMark(link: feedURL)
                                    ((self.window!.rootViewController as! MyTabbarVC).selectedViewController as! UINavigationController).pushViewController(webVC, animated: true)
                                }
                            }
                            
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
            
                let storyboard = UIStoryboard(name: "Enhancement", bundle: nil)
//                let vcSubscri = storyboard.instantiateViewController(withIdentifier: "SubsciptionVc") as! SubsciptionVc
//                vcSubscri.modalPresentationStyle = .fullScreen
//                vcSubscri.modalTransitionStyle = .crossDissolve
//                self.window?.rootViewController = vcSubscri
            
            
            let welcomeViewController = storyboard.instantiateViewController(withIdentifier: "navLogin") as! UINavigationController
            self.window?.rootViewController = welcomeViewController
            self.window?.makeKeyAndVisible()

                //self.present(vcSubscri, animated: true, completion: nil)
            
            // Transition to the home screen
            //self.setRoot()
        }
    }
    
    func isBookMark(link: String) -> Bool
    {
        let ind = self.arrBookMarkLink.firstIndex(of: link) ?? -1
        if ind > -1
        {
            return true
        }
        else
        {
            let indSecond = self.arrBookMarkLinkFeedy.firstIndex(of: link) ?? -1
            if indSecond > -1
            {
                return true
            }
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
//      func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
//     {
//         print("willPresent notification")
//        completionHandler([.alert, .badge, .sound])
//    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
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

extension Date {
    func daysSinceDate(_ fromDate: Date = Date()) -> Int {
        let earliest = self < fromDate ? self  : fromDate
        let latest = (earliest == self) ? fromDate : self

        let earlierComponents:DateComponents = Calendar.current.dateComponents([.day], from: earliest)
        let laterComponents:DateComponents = Calendar.current.dateComponents([.day], from: latest)
        guard
            let earlierDay = earlierComponents.day,
            let laterDay = laterComponents.day,
            laterDay >= earlierDay
            else {
            return 0
        }
        return laterDay - earlierDay
    }

    func dateForDaysFromNow(_ days: Int) -> Date? {
        var dayComponent = DateComponents()
        dayComponent.day = days
        return Calendar.current.date(byAdding: dayComponent, to: self)
    }
}




extension Date {

    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {

        let currentCalendar = Calendar.current

        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }

        return end - start
    }

}

extension Date {

  func isEqualTo(_ date: Date) -> Bool {
    return self == date
  }
  
  func isGreaterThan(_ date: Date) -> Bool {
     return self > date
  }
  
  func isSmallerThan(_ date: Date) -> Bool {
     return self < date
  }
}

