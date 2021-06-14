//
//  SubsciptionVc.swift
//  positifeedy
//
//  Created by iMac on 13/05/21.
//  Copyright © 2021 Evyn Gonzalez . All rights reserved.

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

class SubsciptionVc: UIViewController {
    
    var myDocId : String!
    var Isselected : Int!
    var fromEnhancement : Bool = false
    var fromLogin : Bool = false
    @IBOutlet weak var subscribeBtn : UIButton!
    @IBOutlet weak var scrollview : UIScrollView!
    @IBOutlet weak var Scinsideview : UIView!
  //  @IBOutlet weak var note: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //design()
        getProfileData()
    }
      
    
    @IBAction func onClickSubscibe(_ sender: Any)
    {
        self.startInAppPurchase(strType: IN_APP_PURCHASE.BUY_ANNUAL_PLAN)
    }
    
    
    @IBAction func onClickCancel(_ sender: Any)
    {
        if(fromEnhancement){
            self.dismiss(animated: true, completion: nil)
        }else{
            let storyboard = UIStoryboard(name: "Enhancement", bundle: nil)
            let vcHome = storyboard.instantiateViewController(withIdentifier: "MyTabbarVC") as! MyTabbarVC
            self.navigationController?.pushViewController(vcHome, animated: true)
        }
    }
    
    //MARK:- Subsciption
    func startInAppPurchase(strType : String)
    {
              SVProgressHUD.show()
            self.view.isUserInteractionEnabled = false
               SwiftyStoreKit.purchaseProduct(strType, quantity: 1, atomically: true) { result in
                   
                   //SwiftLoader.hide()
                   //removeLoader()
                   //NetworkActivityIndicatorManager.networkOperationFinished()
                   switch result {
                   case .success(let purchase):
                       print(purchase.productId)
                    print(purchase.transaction.transactionIdentifier)
                       self.serviceCallToBuySubscription()
                    
                       //self.serviceCallTo BuySubscription(transaction: purchase.transaction)
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
    
    //MARK:-
    func serviceCallToBuySubscription()
        //func serviceCallToB uySubscription(transaction : PaymentTransaction)
        {
            //print("Subscription :\(transaction.transactionIdentifier) and \(transaction.transactionState)")
            
            var strType = ""
            
                strType = "Yearly"
                UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE_ANNUAL)
                UserDefaults.standard.removeObject(forKey: PREF_SUBSCRIBE_MONTH)
            
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
                
                let storyboard = UIStoryboard(name: "Enhancement", bundle: nil)

                if(self.fromLogin){
                    let vcHome = storyboard.instantiateViewController(withIdentifier: "MyTabbarVC") as! MyTabbarVC
                    vcHome.selectedIndex = 0
                    vcHome.modalPresentationStyle = .fullScreen
                    vcHome.modalTransitionStyle = .crossDissolve
                    self.navigationController?.pushViewController(vcHome, animated: true)
                }else{
                    let vcHome = storyboard.instantiateViewController(withIdentifier: "MyTabbarVC") as! MyTabbarVC
                    vcHome.selectedIndex = 0
                    vcHome.modalPresentationStyle = .fullScreen
                    vcHome.modalTransitionStyle = .crossDissolve
                    self.present(vcHome, animated: true, completion: nil)
                }
                
             }
        }
    //MARK:- Alert Controller
        func showErrorAlert( title : String,  message : String)
        {
            print("title :\(title) and message :\(message)")
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

    //MARK:- Pofile Data
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
}

