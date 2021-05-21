//
//  ReflectionViewController.swift
//  positifeedy
//
//  Created by iMac on 07/05/21.
//  Copyright © 2021 Evyn Gonzalez . All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ReflectionViewController: UIViewController {

    @IBOutlet weak var lblQuote: UILabel!
    @IBOutlet weak var lblAuthor: UILabel!
    
    @IBOutlet weak var viewJournal: UIView!
    @IBOutlet weak var viewManifest: UIView!
    
    @IBOutlet weak var viewLockManifest: UIView!
    
    @IBOutlet weak var btnJournal: UIView!
    @IBOutlet weak var btnManifest: UIView!
    
    @IBOutlet weak var imgJournal: UIImageView!
    @IBOutlet weak var imgManifest: UIImageView!
    
    var arrNotification = [NotificationQuote]()

    
    var IsSubscription = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.dismiss()
        // Do any additional setup after loading the view.
        
        setupUI()
    }
    
    func setupUI(){
        let radius : CGFloat = 10
        btnJournal.layer.cornerRadius = radius
        btnManifest.layer.cornerRadius = radius
        
        viewJournal.layer.cornerRadius = radius
        viewManifest.layer.cornerRadius = radius
        
        updateLockView()
        setQuestionDetails()
        getNotificationQuote()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        getProfileData()
    }
    
    func updateLockView() {
        if(IsSubscription){
            viewLockManifest.isHidden = true
        }else{
            viewLockManifest.isHidden = false
        }
    }
    
    var arrQuestionList = [QuestionListItem]()

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
                            let newQuestionItem = self.arrQuestionList[1]

                            
                            //self.lblQuestion.text = questionItem.question
                            
                            // current date with suffix :
                            let date = Date()
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MMM dd"
                            let dateString = dateFormatter.string(from: date)
                            //self.lbldate.text = String.init(format: "%@%@", dateString,self.daySuffix(from: date))
                            
                            
                            // image :
                            if let strURL = (questionItem.link)
                               {
                                
                                   let url = URL(string: strURL)
                                    self.imgJournal.sd_setImage(with: url, placeholderImage: UIImage(named: "ReflectionBG"), options: .highPriority)
                                
                                if let strURL1 = (newQuestionItem.link)
                               {
                                    let url = URL(string: strURL1)
                                    self.imgManifest.sd_setImage(with: url, placeholderImage: UIImage(named: "ReflectionBG"), options: .highPriority)
                                }
                                
//                                   DispatchQueue.global(qos: .background).async {
//                                       do
//                                       {
//                                           let data = try Data(contentsOf: url!)
//                                           DispatchQueue.main.async {
//                                               self.imgItem.image = UIImage(data: data)
//                                           }
//                                       }
//                                       catch{
//                                           self.view.makeToast("Somthing went to wrong")
//                                       }
//                                   }
                                
                               }
                        }
                        else
                        {
                             // question
                            let questionItem = self.arrQuestionList[currentInx!]
                            //self.lblQuestion.text = questionItem.question
                            
                            // current date with suffix :
                            let date = Date()
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MMM dd"
                            let dateString = dateFormatter.string(from: date)
                            //self.lbldate.text = String.init(format: "%@%@", dateString,self.daySuffix(from: date))
                            
                            var newIndex = currentInx!
                            repeat{
                                newIndex -= 1
                                if(newIndex < 0){
                                    newIndex = currentInx! + 1
                                }
                                if(newIndex > self.arrQuestionList.count){
                                    newIndex = 0
                                }
                            }while(newIndex == currentInx && newIndex < self.arrQuestionList.count)
                            let newQuestionItem = self.arrQuestionList[newIndex]

                            // image :
                            if let strURL = (questionItem.link)
                               {
                                
                                    //self.imgURL = strURL
                                   let url = URL(string: strURL)
                                    self.imgJournal.sd_setImage(with: url, placeholderImage: UIImage(named: "ReflectionBG"), options: .highPriority)
                                
                                if let strURL1 = (newQuestionItem.link)
                               {
                                    let url = URL(string: strURL1)
                                    self.imgManifest.sd_setImage(with: url, placeholderImage: UIImage(named: "ReflectionBG"), options: .highPriority)

                                }
                                

//                                   DispatchQueue.global(qos: .background).async {
//                                       do
//                                       {
//                                           let data = try Data(contentsOf: url!)
//                                           DispatchQueue.main.async {
//                                               self.imgItem.image = UIImage(data: data)
//                                           }
//                                       }
//                                       catch{
//                                           self.view.makeToast("Somthing went to wrong")
//                                       }
//                                   }
                               }
                        }
                        
                        
                    }
                }
            }
        }
    }
    
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
                            self.lblQuote.text = String.init(format: "%@", notificationQuoteItem.quote_title!)
                        }
                        else
                        {
                            self.lblQuote.text = ""
                        }
                        
                        if notificationQuoteItem.author != nil
                        {
                            self.lblAuthor.text = String.init(format: "- %@", notificationQuoteItem.author!)
                        }
                        else
                        {
                            self.lblAuthor.text = ""
                        }
                    }
                    
                 }
             }
       }
    
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
                        let subscription = d["Subscription"] as? String
                        if subscription != nil
                        {
                            if subscription == "0"
                            {
                                self.IsSubscription = false
                            }else
                            {
                                self.IsSubscription = true
                                
                            }
                            self.updateLockView()
                        }
                        
                    }
                }
                
            }
        }
    }

    @IBAction func btnSubscribeClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Enhancement", bundle: nil)
        let vcSubscri = storyboard.instantiateViewController(withIdentifier: "SubsciptionVc") as! SubsciptionVc
        vcSubscri.modalPresentationStyle = .fullScreen
        vcSubscri.modalTransitionStyle = .crossDissolve
        
        vcSubscri.fromEnhancement = true

        self.present(vcSubscri, animated: true, completion: nil)

    }
    
    @IBAction func btnDailyJornalClicked(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddJournalViewController") as! AddJournalViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnManifestationClicked(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddManifestViewController") as! AddManifestViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
