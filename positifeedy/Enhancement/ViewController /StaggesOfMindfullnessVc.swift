
//
//  StaggesOfMindfullnessVc.swift
//  positifeedy
//
//  Created by iMac on 14/05/21.
//  Copyright © 2021 Evyn Gonzalez . All rights reserved.
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


class StaggesOfMindfullnessVc: UIViewController {

    var myDocId : String!
    var currentPoint : Int! = 0
    var arrListOfJourny : NSMutableArray!
    var arrFeeds : [Feed] = []
    var arrPositifeedy = [PositifeedAllSet]()
    @IBOutlet weak var imgone: UIImageView!
    @IBOutlet weak var imgtwo: UIImageView!
    @IBOutlet weak var imgthree: UIImageView!
    @IBOutlet weak var imgFour: UIImageView!

    @IBOutlet weak var stagesview: UIView!

    @IBOutlet weak var viewProgressTotal: UIView!
    @IBOutlet weak var constLblProgressHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        self.currentPoint = 0
        self.arrListOfJourny = NSMutableArray.init()
        self.getProfileData()
        
    }
    
    //MARK:- Buttons
    @IBAction func stagesOfmindfullness(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
     //MARK:- GetProfile
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
                                             if mypoint == "0"
                                            {
                                                 //first time set point :
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
                                            }
                                            print("================point added :==================")
                                        
                                       // self.imgone.image = UIImage.init(named: "complete_ic_")
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
                                           
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                                            UIView.animate(withDuration: 1.0) {
                                                let total = self.viewProgressTotal.frame.height
                                                
                                                let progress = (CGFloat(point!) * total) / 100
                                                
                                                self.constLblProgressHeight.constant = progress
                                                self.view.layoutIfNeeded()
                                            }
                                        }
                                        
                                        
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
//                                               self.lbl1.isHidden = false
                                               self.imgone.isHidden = false
    
//                                               self.lbl2.isHidden = false
                                               self.imgtwo.isHidden = false
    
//                                               self.lbl3.isHidden = false
                                               self.imgthree.isHidden = false
                                            
                                               self.imgFour.isHidden = false
                                            
                                //            self.lbl1.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                            self.imgone.image = UIImage.init(named: "complete_ic_")
    //
    //                                        self.lbl2.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                            self.imgtwo.image = UIImage.init(named: "circle_s")
    //
    //                                        self.lbl3.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                           self.imgthree.image = UIImage.init(named: "circle_s")
    //
    //                                        self.lbl4.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                            self.imgFour.image = UIImage.init(named: "circle_s")
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
//                                               self.lbl1.isHidden = false
                                               self.imgone.isHidden = false
    
//                                               self.lbl2.isHidden = false
                                               self.imgtwo.isHidden = false
    
//                                               self.lbl3.isHidden = false
                                               self.imgthree.isHidden = false
                                            
                                               self.imgFour.isHidden = false
    
                                            
                                            
                                            //self.lbl1.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                            self.imgone.image = UIImage.init(named: "complete_ic_")
                                            
    //                                        self.lbl2.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                            self.imgtwo.image = UIImage.init(named: "circle_s")
    //
    //                                        self.lbl3.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                            self.imgthree.image = UIImage.init(named: "circle_s")
    //
    //                                        self.lbl4.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                            self.imgFour.image = UIImage.init(named: "circle_s")
    //
                                            
                                               
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
                                               
                                            
//                                               self.lbl1.isHidden = false
                                               self.imgone.isHidden = false
    
//                                               self.lbl2.isHidden = false
                                               self.imgtwo.isHidden = false
    
//                                               self.lbl3.isHidden = false
                                               self.imgthree.isHidden = false
    
                                               self.imgFour.isHidden =  false
                                               
                                            
//                                                self.lbl1.backgroundColor = UIColor.init(red: 99/255, green: 158/255, blue: 121/255, alpha: 1)
                                                self.imgone.image = UIImage.init(named: "complete_ic_")
                                                
                                                //self.lbl2.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                                self.imgtwo.image = UIImage.init(named: "complete_ic_")
                                                
    //                                            self.lbl3.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                                self.imgthree.image = UIImage.init(named: "circle_s")
    //
    //                                            self.lbl4.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                                self.imgFour.image = UIImage.init(named: "circle_s")
    //
                                              
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
                                                   
//                                               self.lbl1.isHidden = false
                                               self.imgone.isHidden = false
    
//                                               self.lbl2.isHidden = false
                                               self.imgtwo.isHidden = false
    
//                                               self.lbl3.isHidden = false
                                               self.imgthree.isHidden = false
    
                                               self.imgFour.isHidden = false
    
                                            
//                                                    self.lbl1.backgroundColor = UIColor.init(red: 99/255, green: 158/255, blue: 121/255, alpha: 1)
                                                    self.imgone.image = UIImage.init(named: "complete_ic_")
    
//                                                    self.lbl2.backgroundColor = UIColor.init(red: 99/255, green: 158/255, blue: 121/255, alpha: 1)
                                                    self.imgtwo.image = UIImage.init(named: "complete_ic_")
    //
                                                    //self.lbl3.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                                    self.imgthree.image = UIImage.init(named: "complete_ic_")
    //
    //                                                self.lbl4.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                                    self.imgFour.image = UIImage.init(named: "circle_s")
                                            
                                            
                                           }
//                                           else if point! >= 75 && point! < 100
//                                           {
//                                            //Expert
//
//                                              let d1 = ["mindstatus" : "expert".capitalized]
//                                              var db1: Firestore!
//                                              db1 = Firestore.firestore()
//                                              db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
//                                                  if error != nil
//                                                  {
//                                                      print(error!.localizedDescription)
//                                                  }
//                                              }
//
//                                               self.lbl1.isHidden = false
//                                               self.imgone.isHidden = false
//
//                                               self.lbl2.isHidden = false
//                                               self.imgtwo.isHidden = false
//
//                                               self.lbl3.isHidden = false
//                                               self.imgthree.isHidden = false
//
//                                               self.imgFour.isHidden = false
//
//
//
//                                                self.lbl1.backgroundColor = UIColor.init(red: 99/255, green: 158/255, blue: 121/255, alpha: 1)
//                                                self.imgone.image = UIImage.init(named: "complete_ic_")
//
//                                               self.lbl2.backgroundColor = UIColor.init(red: 99/255, green: 158/255, blue: 121/255, alpha: 1)
//                                                self.imgtwo.image = UIImage.init(named: "complete_ic_")
//
//                                                self.lbl3.backgroundColor = UIColor.init(red: 99/255, green: 158/255, blue: 121/255, alpha: 1)
//                                                self.imgthree.image = UIImage.init(named: "complete_ic_")
//    //
//    //                                            self.lbl4.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
//                                                self.imgFour.image = UIImage.init(named: "circle")                                           }
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
//                                                  self.lbl1.isHidden = false
                                                 self.imgone.isHidden = false
    
//                                                 self.lbl2.isHidden = false
                                                 self.imgtwo.isHidden = false
    
//                                                 self.lbl3.isHidden = false
                                                 self.imgthree.isHidden = false

                                                 self.imgFour.isHidden = false
                                            
//                                                   self.lbl1.backgroundColor = UIColor.init(red: 99/255, green: 158/255, blue: 121/255, alpha: 1)
                                                    self.imgone.image = UIImage.init(named: "complete_ic_")
                                            
//                                                   self.lbl2.backgroundColor = UIColor.init(red: 99/255, green: 158/255, blue: 121/255, alpha: 1)
                                                    self.imgtwo.image = UIImage.init(named: "complete_ic_")
    
//                                            self.lbl3.backgroundColor = UIColor.init(red: 99/255, green: 158/255, blue: 121/255, alpha: 1)
                                                    self.imgthree.image = UIImage.init(named: "complete_ic_")
    //
    //                                                self.lbl4.backgroundColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
                                                    self.imgFour.image = UIImage.init(named: "complete_ic_")
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
//                                 self.checkIfPurchaed()
                         }
                     }
                 }
             }
         }
}
