//
//  JournalViewController.swift
//  positifeedy
//
//  Created by iMac on 14/10/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage
import Toast_Swift
import AVKit
import AVFoundation
import SDWebImage
import SwiftyStoreKit
import Alamofire

class JournalViewController: UIViewController
{
    var myDocId : String!
    var currentPoint : Int! = 0
    var arrListOfJourny : NSMutableArray!
    var arrNotification = [NotificationQuote]()
    var arrQuestionList = [QuestionListItem]()
    var arrFeeds : [Feed] = []
    var arrPositifeedy = [PositifeedAllSet]()
    
    @IBOutlet weak var lblday: UILabel!
    
    @IBOutlet weak var llbNamed: UILabel!
    @IBOutlet weak var suscriptionView: UIView!
    @IBOutlet weak var lblSpecker: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var stausview: UIView!
    @IBOutlet weak var lblsun: UIImageView!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var lbl2: UILabel!
    
    @IBOutlet weak var imgone: UIImageView!
    @IBOutlet weak var imgtwo: UIImageView!
    @IBOutlet weak var imgFive: UIImageView!
    @IBOutlet weak var imgthree: UIImageView!
    @IBOutlet weak var imgFour: UIImageView!
    
    @IBOutlet weak var stagesview: UIView!
    
    @IBOutlet weak var imgquestion: UIImageView!
    @IBOutlet weak var lblquestion: UILabel!
    @IBOutlet weak var questionview: UIView!
    @IBOutlet weak var lbl4: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lbl1: UILabel!
    
    @IBOutlet weak var lblDate: UILabel!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.design()
        
        getFeeds()
        getPositifeedy()
        
        
//        var db: Firestore!
//        db = Firestore.firestore()
//
//        db.collection("users").document(myDocId!).updateData(d) { (error) in
//            if error != nil
//            {
//                print(error!.localizedDescription)
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        if KeychainItem.store_start_date != nil
        {
            
           if KeychainItem.store_start_date !=  ""
           {
                //KeychainItem.store_start_date = ""
                let dateString = KeychainItem.store_start_date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let start_date = dateFormatter.date(from: dateString!)
                
                let final_date = Date().localDate()
            //let final_date = Date()
                let diff = final_date.interval(ofComponent: .day, fromDate: start_date!)
                print("diffrent day :\(diff)")
                //self.view.makeToast("diffrent day 1 :\(diff) :  store date: \(dateString) and final date :\(final_date)")
                // here in future set 100
                if diff > 100
                {
                    UserDefaults.standard.setValue(0, forKey: PREF_DAILY_QUESTION_COUNT)
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
                    let final_date = Date().localDate()
                    let diff = final_date.interval(ofComponent: .day, fromDate: start_date!)
                    print("diffrent day :\(diff)")
                    //self.view.makeToast("diffrent day 1- :\(diff) :  store date: \(dateString) and final date :\(final_date)")
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
        
        
        
        self.getNotificationQuote()
        self.setQuestionDetails()
        
        self.currentPoint = 0
        self.arrListOfJourny = NSMutableArray.init()
        self.getProfileData()
        
        
    }
    
    //MARK:- design
    func design() -> Void {
        
        self.navigationController?.isNavigationBarHidden = true
        self.stausview.layer.cornerRadius = 10
        self.stausview.clipsToBounds = true
        
//        self.questionview.layer.cornerRadius = 5
//        self.questionview.clipsToBounds = true
        
        self.stagesview.layer.cornerRadius = 20
        self.stagesview.clipsToBounds = true
        
        self.scrollview.contentSize = CGSize.init(width: self.view.frame.size.width, height: self.questionview.frame.origin.y + self.questionview.frame.size.height + 10)
        
        
//        self.lbl1.isHidden = true
//        self.imgone.isHidden = true
//
//        self.lbl2.isHidden = true
//        self.imgtwo.isHidden = true
//
//        self.lbl3.isHidden = true
//        self.imgthree.isHidden = true
//
//        self.lbl4.isHidden = true
//        self.imgFour.isHidden = true
//
//        //self.lbl.isHidden = true
//        self.imgFive.isHidden = true
//
        
//          self.lbl1.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
//           self.imgone.image = UIImage.init(named: "circle_s")
//
//           self.lbl2.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
//           self.imgtwo.image = UIImage.init(named: "circle_s")
//
//           self.lbl3.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
//           self.imgthree.image = UIImage.init(named: "circle_s")
//
//           self.lbl4.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
//           self.imgFour.image = UIImage.init(named: "circle_s")
//
//           self.imgFive.image = UIImage.init(named: "circle_s")
        
        
        self.suscriptionView.isHidden = false
        
    }

    
    func getPositifeedy() {
        var db: Firestore!
        
        db = Firestore.firestore()
        
        db.collection("Positifeedy").getDocuments { (snap, error) in
            if error != nil
            {
                print("error ", error!.localizedDescription)
                return
            }
            
            if let arr = snap?.documents {
                let arrData = arr.map { (snap) -> [String: Any] in
                    var dict = snap.data()
                    dict["documentID"] = snap.documentID
                    return dict
                }
                
                do {
                    
                    let jsonData = try JSONSerialization.data(withJSONObject: arrData, options: .prettyPrinted)
                    let jsonDecoder = JSONDecoder()
                    let obj = try jsonDecoder.decode([PositifeedAllSet].self, from: jsonData)
                    self.arrPositifeedy = obj.sorted(by: { (feed1, feed2) -> Bool in
                        let date1 = Date(timeIntervalSince1970: Double(feed1.timestamp ?? "\(Date().timeIntervalSince1970)")!)
                        let date2 = Date(timeIntervalSince1970: Double(feed2.timestamp ?? "\(Date().timeIntervalSince1970)")!)
                        return date1 > date2
                    })
                    
                }
                catch {
                    
                }
                
            }
        }
    }
    
    func getFeeds()  {
             
             if !NetworkState.isConnected()
             {
                 let alert = UIAlertController(title: Utilities.appName(), message: "Internet not connected", preferredStyle: .alert)
                 alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                 present(alert, animated: true, completion: nil)
                 return
             }
             
//             if self.isRefresh == false {
//                 SVProgressHUD.show()
//             }
             
             AF.request(Global.feedURL).responseDecodable(of: FeedResponse.self)  { (response) in
                 
                 //SVProgressHUD.dismiss()
                 
                 switch response.result
                 {
                 case .success(let feedResponse) :
                     if (feedResponse.ok ?? false)
                     {
                         self.arrFeeds = feedResponse.info.arrFeedData ?? []
                     }
                     
                 case .failure(let error) :
                     print(error)
                 }
                 
             }
         }
    
    //MARK:- question List:
    func setQuestionDetails() -> Void {
        
        var db: Firestore!
        
        db = Firestore.firestore()
        
        db.collection("QuestionList").getDocuments { (snap, error) in
            if error != nil
            {
                print("error ", error!.localizedDescription)
                return
            }
            
            if let arr = snap?.documents {
                let arrData = arr.map { (snap) -> [String: Any] in
                    var dict = snap.data()
                    dict["documentID"] = snap.documentID
                    return dict
                }
                
                do {
                    
                    let jsonData = try JSONSerialization.data(withJSONObject: arrData, options: .prettyPrinted)
                    let jsonDecoder = JSONDecoder()
                    let obj = try jsonDecoder.decode([QuestionListItem].self, from: jsonData)
                    self.arrQuestionList = obj
                    
                    
//                    self.arrQuestionList = obj.sorted(by: { (feed1, feed2) -> Bool in
//                        let date1 = Date(timeIntervalSince1970: Double(feed1.timestamp ?? "\(Date().timeIntervalSince1970)")!)
//                        let date2 = Date(timeIntervalSince1970: Double(feed2.timestamp ?? "\(Date().timeIntervalSince1970)")!)
//                        return date1 > date2
//                    })
                    
                }
                catch {
                    
                }
                print("Question List :\(self.arrQuestionList)")
               if self.arrQuestionList.count > 0
               {
                    let currentInx = UserDefaults.standard.object(forKey: PREF_DAILY_QUESTION_COUNT) as? Int
                    if currentInx != nil
                    {
                        if currentInx == 0
                        {
                            // question
                                                    let questionItem = self.arrQuestionList[0]
                                                    self.lblquestion.text = questionItem.question
                                                    
                                                    // current date with suffix :
                                                    let date = Date()
                                                    let dateFormatter = DateFormatter()
                                                    dateFormatter.dateFormat = "MMM dd"
                                                    let dateString = dateFormatter.string(from: date)
                                                    self.lblDate.text = String.init(format: "%@%@", dateString,self.daySuffix(from: date))
                                                    
                                                    
                                                    // image :
                                                    if let strURL = (questionItem.link)
                                                       {
                                                        
                                                        let url = URL(string: strURL)
                                                        //let storageRef = Storage.storage().reference(forURL: strURL)
                                                        self.imgquestion.sd_setImage(with: url, placeholderImage: UIImage(named: "place"))
                                                        
                                                        //self.imgquestion.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "placeholder.png"))
                                                        
                            //                               let url = URL(string: strURL)
                            //                               DispatchQueue.global(qos: .background).async {
                            //                                   do
                            //                                   {
                            //                                       let data = try Data(contentsOf: url!)
                            //                                       DispatchQueue.main.async {
                            //                                           self.imgquestion.image = UIImage(data: data)
                            //                                       }
                            //                                   }
                            //                                   catch{
                            //                                       self.view.makeToast("Somthing went to wrong")
                            //                                   }
                            //                               }
                                                       }
                            
                        }else
                        {
                            // question
                                                    let questionItem = self.arrQuestionList[currentInx!]
                                                    self.lblquestion.text = questionItem.question
                                                    
                                                    // current date with suffix :
                                                    let date = Date()
                                                    let dateFormatter = DateFormatter()
                                                    dateFormatter.dateFormat = "MMM dd"
                                                    let dateString = dateFormatter.string(from: date)
                                                    self.lblDate.text = String.init(format: "%@%@", dateString,self.daySuffix(from: date))
                                                    
                                                    
                                                    // image :
                                                    if let strURL = (questionItem.link)
                                                       {
                                                        
                                                        let url = URL(string: strURL)
                                                        //let storageRef = Storage.storage().reference(forURL: strURL)
                                                        self.imgquestion.sd_setImage(with: url, placeholderImage: UIImage(named: "place"))
                                                        
                                                        //self.imgquestion.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "placeholder.png"))
                                                        
                            //                               let url = URL(string: strURL)
                            //                               DispatchQueue.global(qos: .background).async {
                            //                                   do
                            //                                   {
                            //                                       let data = try Data(contentsOf: url!)
                            //                                       DispatchQueue.main.async {
                            //                                           self.imgquestion.image = UIImage(data: data)
                            //                                       }
                            //                                   }
                            //                                   catch{
                            //                                       self.view.makeToast("Somthing went to wrong")
                            //                                   }
                            //                               }
                                                       }
                        }
                        
                        
                        
                    }else {
                            
                                   if KeychainItem.store_start_date != nil
                                   {
                                       let dateString = KeychainItem.store_start_date
                                       let dateFormatter = DateFormatter()
                                       dateFormatter.dateFormat = "yyyy-MM-dd"
                                       let start_date = dateFormatter.date(from: dateString!)
                                       let final_date = Date().localDate()
                                       let diff = final_date.interval(ofComponent: .day, fromDate: start_date!)
                                       print("diffrent day :\(diff)")
                                      //  self.view.makeToast("diffrent day 2:\(diff) :  store date: \(dateString) and final date :\(final_date)")
                                       
                                       // here in future set 100
                                       if diff > 10
                                       {
                                           UserDefaults.standard.setValue(0, forKey: PREF_DAILY_QUESTION_COUNT)
                                       }
                                       else
                                       {
                                           UserDefaults.standard.setValue(diff, forKey: PREF_DAILY_QUESTION_COUNT)
                                       }
                                    
                                        let currentInx = UserDefaults.standard.object(forKey: PREF_DAILY_QUESTION_COUNT) as? Int
                                        let questionItem = self.arrQuestionList[currentInx!]
                                           self.lblquestion.text = questionItem.question
                                           
                                           // current date with suffix :
                                           let date1 = Date()
                                           let dateFormatter1 = DateFormatter()
                                           dateFormatter1.dateFormat = "MMM dd"
                                           let dateString1 = dateFormatter1.string(from: date1)
                                           self.lblDate.text = String.init(format: "%@%@", dateString1,self.daySuffix(from: date1))
                                           
                                           
                                           // image :
                                           if let strURL = (questionItem.link)
                                              {
                                               
                                               let url = URL(string: strURL)
                                               //let storageRef = Storage.storage().reference(forURL: strURL)
                                               self.imgquestion.sd_setImage(with: url, placeholderImage: UIImage(named: "place"))
                   
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
                                        let final_date = Date().localDate()
                                       let diff = final_date.interval(ofComponent: .day, fromDate: start_date!)
                                       print("diffrent day :\(diff)")
                                      // self.view.makeToast("diffrent day 3:\(diff) :  store date: \(dateString) and final date :\(final_date)")
                                       UserDefaults.standard.setValue(0, forKey: PREF_DAILY_QUESTION_COUNT)
                                    
                                        let questionItem = self.arrQuestionList[0]
                                        self.lblquestion.text = questionItem.question
                                        
                                        // current date with suffix :
                                        let date2 = Date()
                                        let dateFormatter3 = DateFormatter()
                                        dateFormatter3.dateFormat = "MMM dd"
                                        let dateString12 = dateFormatter3.string(from: date2)
                                        self.lblDate.text = String.init(format: "%@%@", dateString12,self.daySuffix(from: date2))
                                        
                                         // image :
                                         if let strURL = (questionItem.link)
                                           {
                                            
                                            let url = URL(string: strURL)
                                            //let storageRef = Storage.storage().reference(forURL: strURL)
                                            self.imgquestion.sd_setImage(with: url, placeholderImage: UIImage(named: "place"))
                                          }
                                   }
                    }
                }
            }
        }
    }
    
    func daySuffix(from date: Date) -> String {
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: date)
        switch dayOfMonth {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }

    //MARK:- check purchased :
    
    func checkIfPurchaed () {
              
              // monthly plan :
              let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "eb8e064a837a42c5b7f9e7910f517911")
              SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                  switch result {
                  case .success(let receipt):
                      let productId = IN_APP_PURCHASE.BUY_MONTHLY_PLAN
                      // Verify the purchase of a Subscription
                      let purchaseResult = SwiftyStoreKit.verifySubscription(
                          ofType: .autoRenewable, //or .nonRenewing
                          productId: productId,
                          inReceipt: receipt)
                      
                      switch purchaseResult {
                      case .purchased(let expiryDate, let items):
                          
                          //self.view.makeToast("purchased 1 month :\(expiryDate)")
                          let currentdate = Date()
                          if currentdate.isGreaterThan(expiryDate)
                          {
                              //alerady expired !
                              UserDefaults.standard.removeObject(forKey: PREF_SUBSCRIBE_MONTH)
                          }
                          else
                          {
                              UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE_MONTH)
                          }
                          
                          print("\(productId) is valid until \(expiryDate)\n\(items)\n")
                          
                          //UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE)
                      case .expired(let expiryDate, let items):
                          print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                          
                         // self.view.makeToast("expired 1 month :\(expiryDate)")
                          
                          let currentdate = Date()
                          if currentdate.isGreaterThan(expiryDate)
                          {
                              //alerady expired !
                              UserDefaults.standard.removeObject(forKey: PREF_SUBSCRIBE_MONTH)
                          }
                          else
                          {
                              UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE_MONTH)
                          }
                         //  UserDefaults.standard.removeObject(forKey: PREF_SUBSCRIBE)
                      case .notPurchased:
                        
                       // self.view.makeToast("not purchase  month :")
                          print("The user has never purchased \(productId)")
                      }

                  case .error(let error):
                      print("Receipt verification failed: \(error)")
                  }
              }
              
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

                      switch purchaseResult {
                      case .purchased(let expiryDate, let items):

                        //self.view.makeToast("purchased 1 year :\(expiryDate)")
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
                          
                          print("\(productId) is valid until \(expiryDate)\n\(items)\n")
                          //UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE_ANNUAL)
                          
                          //UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE)
                      case .expired(let expiryDate, let items):
                          print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                          //self.view.makeToast("expired 1 year :\(expiryDate)")
                          
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
                          print("The user has never purchased \(productId)")
                        
                        //self.view.makeToast("not purchase  year :")
                      }

                  case .error(let error):
                      print("Receipt verification failed: \(error)")
                  }
              }
              
              
              let annual = UserDefaults.standard.object(forKey: PREF_SUBSCRIBE_ANNUAL) as? String
              let monthly = UserDefaults.standard.object(forKey: PREF_SUBSCRIBE_MONTH) as? String
              
              if annual != nil || monthly != nil
              {
                 //self.view.makeToast("Purchased somthing !")
                  UserDefaults.standard.setValue("1", forKey: PREF_SUBSCRIBE)
                  //self.suscriptionView.isHidden = false
                 self.suscriptionView.isHidden = true
              }
              else
              {
                //self.view.makeToast("No any Purchase!")
                  //No any item subscribe!
                  UserDefaults.standard.removeObject(forKey: PREF_SUBSCRIBE)
                
                    let d = ["Subscription" : "0"]
                    var db: Firestore!
                    db = Firestore.firestore()
                    db.collection("users").document(self.myDocId!).updateData(d) { (error) in
                        if error != nil
                        {
                            print(error!.localizedDescription)
                        }
                      self.suscriptionView.isHidden = false
                    }
              }
         

          }
    
    
    
    @IBAction func onclickforQuestion(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vcSubscri = storyboard.instantiateViewController(withIdentifier: "AnswerOfQuestionVC") as! AnswerOfQuestionVC
        vcSubscri.modalPresentationStyle = .fullScreen
        vcSubscri.modalTransitionStyle = .crossDissolve
        self.present(vcSubscri, animated: true, completion: nil)
    }
    
    @IBAction func onclickforSubscribeNow(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vcSubscri = storyboard.instantiateViewController(withIdentifier: "SubscriptionViewController") as! SubscriptionViewController
        vcSubscri.modalPresentationStyle = .fullScreen
        vcSubscri.modalTransitionStyle = .crossDissolve
        self.present(vcSubscri, animated: true, completion: nil)
        
    }
    
    
    //MARK:- get quote :
    func getNotificationQuote()
    {
          var db: Firestore!
                 
                 db = Firestore.firestore()
                 
                 db.collection("NotificationQuote").getDocuments { (snap, error) in
                     if error != nil
                     {
                         print("error ", error!.localizedDescription)
                         return
                     }
                     
                     if let arr = snap?.documents {
                         let arrData = arr.map { (snap) -> [String: Any] in
                             var dict = snap.data()
                             dict["documentID"] = snap.documentID
                             return dict
                         }
                         
                         do {
                             
                             let jsonData = try JSONSerialization.data(withJSONObject: arrData, options: .prettyPrinted)
                             let jsonDecoder = JSONDecoder()
                             let obj = try jsonDecoder.decode([NotificationQuote].self, from: jsonData)
                             self.arrNotification = obj.sorted(by: { (feed1, feed2) -> Bool in
                                 let date1 = Date(timeIntervalSince1970: Double(feed1.timestamp ?? "\(Date().timeIntervalSince1970)")!)
                                 let date2 = Date(timeIntervalSince1970: Double(feed2.timestamp ?? "\(Date().timeIntervalSince1970)")!)
                                 return date1 < date2
                             })
                             
                         }
                         catch {
                             
                         }
                         
                        if self.arrNotification.count > 0
                        {
                            print("arrnotification :\n\(self.arrNotification)")
                            let notificationQuoteItem = self.arrNotification[self.arrNotification.count - 1]
                            if notificationQuoteItem.quote_title != nil
                            {
                                self.lblStatus.text = String.init(format: "%@", notificationQuoteItem.quote_title!)
                            }
                            else
                            {
                                self.lblStatus.text = ""
                            }
                            
                            if notificationQuoteItem.author != nil
                            {
                                self.lblSpecker.text = String.init(format: "- %@", notificationQuoteItem.author!)
                            }
                            else
                            {
                                self.lblSpecker.text = ""
                            }
                        }
                        
                     }
                 }
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
                         let fname = (d["firstname"] as! String)
                        
                        self.llbNamed.text = fname
                        
                        // let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate()) Swift 2 legacy
                        let hour = Calendar.current.component(.hour, from: Date())
                        switch hour {
                        case 6..<12 :
                            self.lblday.text = String.init(format: "Good Morning %@","")
                            self.lblsun.image =  UIImage.init(named: "sun")
                        case 12 :
                            self.lblday.text = String.init(format: "Good Noon %@","")
                            self.lblsun.image =  UIImage.init(named: "sun")
                        case 13..<17 :
                            self.lblday.text = String.init(format: "Good Afternoon %@","")
                            self.lblsun.image =  UIImage.init(named: "sun")
                        case 17..<22 :
                            self.lblday.text = String.init(format: "Good Evening %@","")
                            self.lblsun.image =  UIImage.init(named: "moon")
                        default:
                            self.lblday.text = String.init(format: "Good Night %@","")
                            self.lblsun.image =  UIImage.init(named: "moon")
                        }
                        
                        // subscription :
                        let subscription = d["Subscription"] as? String
                        if subscription != nil
                        {
                            if subscription == "0"
                            {
                                // Not subscribe !
                                self.suscriptionView.isHidden = false
                                
                            }else
                            {
                                // subscribed :
                                self.suscriptionView.isHidden = true
                            }
                            
                        }else
                        {
                            
                              self.suscriptionView.isHidden = false
                               let d = ["Subscription" : "0"]
                               var db: Firestore!
                               db = Firestore.firestore()
                               db.collection("users").document(self.myDocId!).updateData(d) { (error) in
                                   if error != nil
                                   {
                                       print(error!.localizedDescription)
                                   }
                               }
                               print("point added :")
                        }
                        
                        //---------------- START -------------------//
                              // list of added journal :
//                               let arr = d["JournalEntry"] as? NSArray
//                              if arr != nil
//                              {
//                                  if arr!.count > 0
//                                  {
//                                      self.arrListOfJourny = NSMutableArray.init(array: arr!)
//                                      print("My Journal :\(self.arrListOfJourny)")
//
//                                       for i in (0..<self.arrListOfJourny.count)
//                                       {
//                                           let dict = self.arrListOfJourny.object(at: i) as? NSDictionary
//                                           let point = Int((dict?.value(forKey: "point") as? String)!) ?? 0
//                                           self.currentPoint = self.currentPoint + point
//                                       }
//                                  }
//                                   print("Self current :\(self.currentPoint)")
//
//                              }
//                              else
//                              {
//                                  print("No JournalEntry Object !")
//                              }
                               //---------------- END -----------------------//
                               
                               
                               //my point
                               //---------------- START -------------------//
                                    let mypoint = d["myPoint"] as? String
                                   if mypoint != nil
                                   {
                                         //if mypoint == "0"
                                        //{
                                            // first time set point :
//                                            let str = String.init(format: "%d", self.currentPoint)
//                                            let d = ["myPoint" : str]
//                                            var db: Firestore!
//                                            db = Firestore.firestore()
//                                            db.collection("users").document(self.myDocId!).updateData(d) { (error) in
//                                                if error != nil
//                                                {
//                                                    print(error!.localizedDescription)
//                                                }
//                                            }
                                        //}
                                        print("================point added :==================")
                                    
                                    
                                    let mypoint = d["myPoint"] as? String
                                    print("My point :\(mypoint)")
                                    var point = Int(mypoint!)
                                   
                                      if point! > 0
                                       {
                                           
                                           let booked_date = UserDefaults.standard.object(forKey: PREF_BOOKED_DATE) as? String
                                           if booked_date != nil
                                           {
                                               let dateFormatter = DateFormatter()
                                               dateFormatter.dateFormat = "yyyy-MM-dd"
                                               let start_date = dateFormatter.date(from: booked_date!)
                                               let final_date = Date().localDate()
                                               let diff = final_date.interval(ofComponent: .day, fromDate: start_date!)
                                               print("diffrent day :\(diff)")
                                              //self.view.makeToast("diffrent day 4:\(diff) :  store date: \(start_date) and final date :\(final_date)")
                                               if diff >= 3
                                               {
                                                   let set_new_point = point! - 5
                                                   let str = String.init(format: "%d",set_new_point)
                                                   let d = ["myPoint" : str]
                                                   var db: Firestore!
                                                   db = Firestore.firestore()
                                                   db.collection("users").document(self.myDocId!).updateData(d) { (error) in
                                                       if error != nil
                                                       {
                                                           print(error!.localizedDescription)
                                                       }
                                                   }
                                                   let date1 = Date()
                                                   let dateFormatter1 = DateFormatter()
                                                   dateFormatter1.dateFormat = "yyyy-MM-dd"
                                                   let dateString = dateFormatter1.string(from: date1)
                                                   UserDefaults.standard.setValue(dateString, forKey: PREF_BOOKED_DATE)
                                               }
                                           }
                                        
                                       }
                                       else
                                       {
                                          // let set_new_point = point! - 5
                                           let d = ["myPoint" : "0"]
                                           var db: Firestore!
                                           db = Firestore.firestore()
                                           db.collection("users").document(self.myDocId!).updateData(d) { (error) in
                                               if error != nil
                                               {
                                                   print(error!.localizedDescription)
                                               }
                                           }
                                       }
                                       
                                       print("Goal :\(point)")
                                       
                                       if point == 0
                                       {
                                        // beginer
                                            let d1 = ["mindstatus" : "beginner".capitalized]
                                                var db1: Firestore!
                                                db1 = Firestore.firestore()
                                                db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
                                                    if error != nil
                                                    {
                                                        print(error!.localizedDescription)
                                                    }
                                                }
                                        
                                           // Beginner
//                                           self.lbl1.isHidden = true
//                                           self.imgone.isHidden = true
//
//                                           self.lbl2.isHidden = true
//                                           self.imgtwo.isHidden = true
//
//                                           self.lbl3.isHidden = true
//                                           self.imgthree.isHidden = true
//
//                                           self.lbl4.isHidden = true
//                                           self.imgFour.isHidden = true
//
//                                           //self.lbl.isHidden = true
//                                           self.imgFive.isHidden = true
                                        
//                                        self.lbl1.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                        self.imgone.image = UIImage.init(named: "circle")
//
//                                        self.lbl2.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                        self.imgtwo.image = UIImage.init(named: "circle_s")
//
//                                        self.lbl3.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                       self.imgthree.image = UIImage.init(named: "circle_s")
//
//                                        self.lbl4.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                        self.imgFour.image = UIImage.init(named: "circle_s")
//
                                        self.imgFive.image = UIImage.init(named: "circle_s")
                                        
                                        
                                           
                                           
                                       }
                                       else if point! > 0 && point! < 25
                                       {
                                            let d1 = ["mindstatus" : "beginner".capitalized]
                                            var db1: Firestore!
                                            db1 = Firestore.firestore()
                                            db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
                                                if error != nil
                                                {
                                                    print(error!.localizedDescription)
                                                }
                                            }
                                          
//                                           // beginer
//                                           self.lbl1.isHidden = true
//                                           self.imgone.isHidden = false
//
//                                           self.lbl2.isHidden = true
//                                           self.imgtwo.isHidden = true
//
//                                           self.lbl3.isHidden = true
//                                           self.imgthree.isHidden = true
//
//                                           self.lbl4.isHidden = true
//                                           self.imgFour.isHidden = true
//
//                                           //self.lbl.isHidden = true
//                                           self.imgFive.isHidden = true
                                        
                                        
                                        //self.lbl1.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                        self.imgone.image = UIImage.init(named: "circle")
                                        
//                                        self.lbl2.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                        self.imgtwo.image = UIImage.init(named: "circle_s")
//
//                                        self.lbl3.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                        self.imgthree.image = UIImage.init(named: "circle_s")
//
//                                        self.lbl4.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                        self.imgFour.image = UIImage.init(named: "circle_s")
//
                                        self.imgFive.image = UIImage.init(named: "circle_s")
                                        
                                           
                                       }
                                       else if point! >= 25 && point! < 50
                                       {
                                         //Intermediate
                                           
                                           let d1 = ["mindstatus" : "intermediate".capitalized]
                                             var db1: Firestore!
                                             db1 = Firestore.firestore()
                                             db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
                                                 if error != nil
                                                 {
                                                     print(error!.localizedDescription)
                                                 }
                                             }
                                           
                                        
//                                           self.lbl1.isHidden = false
//                                           self.imgone.isHidden = false
//
//                                           self.lbl2.isHidden = true
//                                           self.imgtwo.isHidden = false
//
//                                           self.lbl3.isHidden = true
//                                           self.imgthree.isHidden = true
//
//                                           self.lbl4.isHidden = true
//                                           self.imgFour.isHidden = true
//
//                                           //self.lbl.isHidden = true
//                                           self.imgFive.isHidden = true
                                        
                                            //self.lbl1.backgroundColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
                                            self.imgone.image = UIImage.init(named: "circle_s")
                                            
                                            //self.lbl2.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                            self.imgtwo.image = UIImage.init(named: "circle")
                                            
//                                            self.lbl3.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                            self.imgthree.image = UIImage.init(named: "circle_s")
//
//                                            self.lbl4.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                            self.imgFour.image = UIImage.init(named: "circle_s")
//
                                            self.imgFive.image = UIImage.init(named: "circle_s")
                                        
                                        
                                           
                                       }
                                       else if point! >= 50 && point! < 75
                                       {
                                        //Advanced
                                        let d1 = ["mindstatus" : "advanced".capitalized]
                                        var db1: Firestore!
                                        db1 = Firestore.firestore()
                                        db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
                                            if error != nil
                                            {
                                                print(error!.localizedDescription)
                                            }
                                        }
                                               
//                                           self.lbl1.isHidden = false
//                                           self.imgone.isHidden = false
//
//                                           self.lbl2.isHidden = false
//                                           self.imgtwo.isHidden = false
//
//                                           self.lbl3.isHidden = true
//                                           self.imgthree.isHidden = false
//
//                                           self.lbl4.isHidden = true
//                                           self.imgFour.isHidden = true
//
//                                           //self.lbl.isHidden = true
//                                           self.imgFive.isHidden = true
                                        
//                                                self.lbl1.backgroundColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
                                                self.imgone.image = UIImage.init(named: "circle_s")
//
//                                                self.lbl2.backgroundColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
                                                self.imgtwo.image = UIImage.init(named: "circle_s")
//
                                                //self.lbl3.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                                self.imgthree.image = UIImage.init(named: "circle")
//
//                                                self.lbl4.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                                self.imgFour.image = UIImage.init(named: "circle_s")

                                                self.imgFive.image = UIImage.init(named: "circle_s")
                                        
                                        
                                       }
                                       else if point! >= 75 && point! < 100
                                       {
                                        //Expert
    
                                          let d1 = ["mindstatus" : "expert".capitalized]
                                          var db1: Firestore!
                                          db1 = Firestore.firestore()
                                          db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
                                              if error != nil
                                              {
                                                  print(error!.localizedDescription)
                                              }
                                          }
                                           
//                                           self.lbl1.isHidden = false
//                                           self.imgone.isHidden = false
//
//                                           self.lbl2.isHidden = false
//                                           self.imgtwo.isHidden = false
//
//                                           self.lbl3.isHidden = false
//                                           self.imgthree.isHidden = false
//
//                                           self.lbl4.isHidden = true
//                                           self.imgFour.isHidden = false
//
//                                           //self.lbl.isHidden = true
//                                           self.imgFive.isHidden = true
                                        
                                        
//                                            self.lbl1.backgroundColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
                                            self.imgone.image = UIImage.init(named: "circle_s")
//
//                                            self.lbl2.backgroundColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
                                            self.imgtwo.image = UIImage.init(named: "circle_s")
//
//                                            self.lbl3.backgroundColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
                                            self.imgthree.image = UIImage.init(named: "circle_s")
//
//                                            self.lbl4.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                            self.imgFour.image = UIImage.init(named: "circle")
                                            
                                            self.imgFive.image = UIImage.init(named: "circle_s")
                                        
                                        
                                       }
                                       else
                                       {
                                                let d1 = ["mindstatus" : "master".capitalized]
                                                 var db1: Firestore!
                                                 db1 = Firestore.firestore()
                                                 db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
                                                     if error != nil
                                                     {
                                                         print(error!.localizedDescription)
                                                     }
                                                 }
                                        //Master
//                                              self.lbl1.isHidden = false
//                                             self.imgone.isHidden = false
//
//                                             self.lbl2.isHidden = false
//                                             self.imgtwo.isHidden = false
//
//                                             self.lbl3.isHidden = false
//                                             self.imgthree.isHidden = false
//
//                                             self.lbl4.isHidden = false
//                                             self.imgFour.isHidden = false
//
//                                             //self.lbl.isHidden = true
//                                             self.imgFive.isHidden = false
                                        
//                                                self.lbl1.backgroundColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
                                                self.imgone.image = UIImage.init(named: "circle_s")
//
//                                                self.lbl2.backgroundColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
                                                self.imgtwo.image = UIImage.init(named: "circle_s")
//
//                                                self.lbl3.backgroundColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
                                                self.imgthree.image = UIImage.init(named: "circle_s")
//
//                                                self.lbl4.backgroundColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
                                                self.imgFour.image = UIImage.init(named: "circle_s")
                                                
                                                self.imgFive.image = UIImage.init(named: "circle")
                                        
                                        
                                       }
                                       
                                   }
                                   else
                                   {
                                    
                                       let d1 = ["mindstatus" : "beginner".capitalized]
                                       var db1: Firestore!
                                       db1 = Firestore.firestore()
                                       db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
                                           if error != nil
                                           {
                                               print(error!.localizedDescription)
                                           }
                                       }
                                    
                                    
                                       let str = String.init(format: "%d", self.currentPoint)
                                       let d = ["myPoint" : str]
                                       var db: Firestore!
                                       db = Firestore.firestore()
                                       db.collection("users").document(self.myDocId!).updateData(d) { (error) in
                                           if error != nil
                                           {
                                               print(error!.localizedDescription)
                                           }
                                       }
                                       print("point added :")
                                   }
                               
                               //---------------- END -------------------//
                             self.checkIfPurchaed()
                     }
                 }
             }
         }
     }
    
}
extension Date {
    func localDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}

        return localDate
    }
}
