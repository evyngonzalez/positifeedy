//
//  SubscriptionViewController.swift
//  positifeedy
//
//  Created by Hiren Dhamecha on 10/12/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit
import CoreData
import Firebase
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage
import Toast_Swift
import AVKit
import AVFoundation
import SDWebImage
import SVProgressHUD

class SubscriptionViewController: UIViewController
{
    
    var myDocId : String!
    var selected : Int!
    @IBOutlet weak var btnmonth: UIButton!
    @IBOutlet weak var btnskup: UIButton!
    @IBOutlet weak var btnyear: UIButton!
    @IBOutlet weak var scrollview: UIScrollView!
    
    @IBOutlet weak var note: UILabel!
    var fromEnhancement = false
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.design()
        self.getProfileData()

    }
    
    func design() -> Void {
        
        self.btnyear.cornerRadidusbtn()
        self.btnmonth.cornerRadidusbtn()
        
        self.scrollview.contentSize = CGSize.init(width: self.view.frame.size.width, height: self.note.frame.origin.y + self.note.frame.size.height + 5)
        
        
        //self.note.text = "The price of Mindful status and Journal subscription is just $19.99 a year or $1.99 a month applied to your iTunes account on confirmation. The price may vary from time-to-time and may change without notice, but you can always see the exact price in the app. Subscriptions will automatically renew unless canceled within 24-hours before the end of the current period. You can cancel anytime with your iTunes account settings. Our Terms of use and Privacy-policy"
        
        self.note.colorString(text: "The price of Mindful status and Journal subscription is just $19.99 a year or $1.99 a month applied to your iTunes account on confirmation. The price may vary from time-to-time and may change without notice, but you can always see the exact price in the app. Subscriptions will automatically renew unless canceled within 24-hours before the end of the current period. You can cancel anytime with your iTunes account settings. Our Terms of use and Privacy-policy", coloredText1: "Our Terms of use", coloredText2: "Privacy-policy")
        
    }
    
    @IBAction func onclickforSkipForNow(_ sender: Any)
    {
        if(fromEnhancement){
            self.dismiss(animated: true, completion: nil)
        }else{
            let storyboard = UIStoryboard(name: "Enhancement", bundle: nil)
            let vcHome = storyboard.instantiateViewController(withIdentifier: "MyTabbarVC") as! MyTabbarVC
            vcHome.selectedIndex = 0
            vcHome.modalPresentationStyle = .fullScreen
            vcHome.modalTransitionStyle = .crossDissolve
            self.present(vcHome, animated: true, completion: nil)
        }

    }
    
    @IBAction func onclickforMonth(_ sender: Any)
    {
        self.selected = 0
        self.startInAppPurchase(strType: IN_APP_PURCHASE.BUY_MONTHLY_PLAN)
       //self.serviceCallToBuySubscription()
        
    }
    
    @IBAction func onclickforPrivacy(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let answ = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyScreenVC") as! PrivacyPolicyScreenVC
        answ.modalPresentationStyle = .fullScreen
        answ.modalTransitionStyle = .crossDissolve
        self.present(answ, animated: true, completion: nil)
    }
    
    
    @IBAction func onclickforTerms(_ sender: Any)
    {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let answ = storyboard.instantiateViewController(withIdentifier: "TermsNConditionVC") as! TermsNConditionVC
            answ.modalPresentationStyle = .fullScreen
            answ.modalTransitionStyle = .crossDissolve
            self.present(answ, animated: true, completion: nil)
    }
    
    
    @IBAction func onclickforYear(_ sender: Any)
    {
        self.selected = 1
        //self.serviceCallToBuySubscription()
        self.startInAppPurchase(strType: IN_APP_PURCHASE.BUY_ANNUAL_PLAN)
    }
    
    //MARK:- start in app purchase :
    func startInAppPurchase(strType : String)
    {
               
              // SwiftLoader.show(animated: true)
               
               //showLoader()
       //        if !APIManager.isConnectedToNetwork(){
       //            APIManager.shared.networkErrorMsg()
       //            return
       //        }
               //NetworkActivityIndicatorManager.networkOperationStarted()
        
              SVProgressHUD.show()
            self.view.isUserInteractionEnabled = false
               SwiftyStoreKit.purchaseProduct(strType, quantity: 1, atomically: true) { result in
                   
                   //SwiftLoader.hide()
                   //removeLoader()
                   //NetworkActivityIndicatorManager.networkOperationFinished()
                   switch result {
                   case .success(let purchase):
                       print(purchase.productId)
                       self.serviceCallToBuySubscription()
                       //self.serviceCallToBuySubscription(transaction: purchase.transaction)
                   case .error(let error):
                     SVProgressHUD.dismiss()
                     self.view.isUserInteractionEnabled = true
                       switch error.code {
                       case .unknown:
                         
                           self.showErrorAlert(title: "Purchase failed", message: error.localizedDescription)
                           break
                       case .clientInvalid: // client is not allowed to issue the request, etc.
                           self.showErrorAlert(title: "Purchase failed", message: "Not allowed to make the payment")
                           break
                       case .paymentCancelled: // user cancelled the request, etc.
                           break
                       case .paymentInvalid: // purchase identifier was invalid, etc.
                           self.showErrorAlert(title: "Purchase failed", message: "The purchase identifier was invalid")
                           break
                       case .paymentNotAllowed: // this device is not allowed to make the payment
                           self.showErrorAlert(title: "Purchase failed", message: "The device is not allowed to make the payment")
                           break
                       case .storeProductNotAvailable: // Product is not available in the current storefront
                           self.showErrorAlert(title: "Purchase failed", message: "The product is not available in the current storefront")
                           break
                       case .cloudServicePermissionDenied: // user has not allowed access to cloud service information
                           self.showErrorAlert(title: "Purchase failed", message: "Access to cloud service information is not allowed")
                           break
                       case .cloudServiceNetworkConnectionFailed: // the device could not connect to the nework
                           self.showErrorAlert(title: "Purchase failed", message: "Could not connect to the network")
                           break
                       case .cloudServiceRevoked: // user has revoked permission to use this cloud service
                           self.showErrorAlert(title: "Purchase failed", message: "Cloud service was revoked")
                           break
                       case .privacyAcknowledgementRequired:
                           break
                       case .unauthorizedRequestData:
                           break
                       case .invalidOfferIdentifier:
                           break
                       case .invalidSignature:
                           break
                       case .missingOfferParams:
                           break
                       case .invalidOfferPrice:
                           break
                       default:
                           break
                       }
                   }
               }
           }
           
    
    
    func serviceCallToBuySubscription()
    //func serviceCallToBuySubscription(transaction : PaymentTransaction)
    {
        //print("Subscription :\(transaction.transactionIdentifier) and \(transaction.transactionState)")
        
        var strType = ""
        if self.selected == 0
        {
            strType = "Monthly"
            UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE_MONTH)
            UserDefaults.standard.removeObject(forKey: PREF_SUBSCRIBE_ANNUAL)
        }
        else if self.selected == 1
        {
            strType = "Yearly"
            UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE_ANNUAL)
            UserDefaults.standard.removeObject(forKey: PREF_SUBSCRIBE_MONTH)
        }
        else
        {

        }
        
        UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE)
        
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let d = ["Subscription" : "1","Subscription_date":dateString,"Subscription_type":strType]
         var db: Firestore!
         db = Firestore.firestore()
         db.collection("users").document(self.myDocId!).updateData(d) { (error) in
             if error != nil
             {
                 print(error!.localizedDescription)
             }
            self.view.isUserInteractionEnabled = true
            //SVProgressHUD.dismiss()
            self.view.makeToast("Subscription Successfully done!")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vcHome = storyboard.instantiateViewController(withIdentifier: "MyTabbarVC") as! MyTabbarVC
            vcHome.selectedIndex = 1
            vcHome.modalPresentationStyle = .fullScreen
            vcHome.modalTransitionStyle = .crossDissolve
            self.present(vcHome, animated: true, completion: nil)
            
         }
        
        
//        let param = NSMutableDictionary.init()
//        param.setValue(transaction.transactionIdentifier, forKey: PARAM_TRANSACTION_ID)
//        param.setValue("success", forKey: PARAM_TRANSACTION_STATUS)
//
//        SwiftLoader.show(animated: true)
//        methodPOSTWithToken(url: API_USER_PURCHASE, param: param) { (resp) in
//
//            SwiftLoader.hide()
//
//            print("resp subscription ->:\(resp)")
//            if resp["status"] as? Int == 1
//            {
//
//                if self.selected == 0
//                {
//                    UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE_MONTH)
//                    UserDefaults.standard.removeObject(forKey: PREF_SUBSCRIBE_ANNUAL)
//                }
//                else if self.selected == 1
//                {
//                    UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE_ANNUAL)
//                    UserDefaults.standard.removeObject(forKey: PREF_SUBSCRIBE_MONTH)
//                }
//                else
//                {
//
//                }
//                UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE)
//                Toast.init(text: String.init(format: "%@",(resp["message"] as? CVarArg)!)).show()
//                self.tblList.reloadData()
//            }
//            else
//            {
//                Toast.init(text: String.init(format: "%@",(resp["message"] as? CVarArg)!)).show()
//            }
//        }
        
        
    }
    
    
      //MARK:- get profile data
        func getProfileData()
         {
             var db: Firestore!
             db = Firestore.firestore()
             db.collection("users").getDocuments { (snap, error) in
                 if error != nil
                 {
                     print("error ", error!.localizedDescription)
                     return
                 }
                 
                 for doc in snap?.documents ?? []
                 {
                     let  d = doc.data()
                     if d.count > 0
                     {
                         print("data = ",  d)
                         
                         if (d["uid"] as! String)  ==  Auth.auth().currentUser?.uid
                         {
                             self.myDocId = doc.documentID
                        }
                    }
                 }
             }
         }
    
           func showErrorAlert( title : String,  message : String)
           {
               print("title :\(title) and message :\(message)")
               
               let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
               alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
               self.present(alert, animated: true, completion: nil)
               
               
       //        showAlert(title, message: message) {
       //
       //        }
           }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIButton
{
    func cornerRadidusbtn() -> Void {
        
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor.init(red: 37/255, green: 250/255, blue: 168/255, alpha: 1).cgColor
        self.clipsToBounds = true
    }
    
}



