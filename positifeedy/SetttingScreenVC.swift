//
//  SetttingScreenVC.swift
//  positifeedy
//
//  Created by Hiren Dhamecha on 12/12/20.
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
import FTPopOverMenu_Swift
import DLLocalNotifications

class SetttingScreenVC: UIViewController,UITableViewDelegate,UITableViewDataSource
{

    var arrList : [String] = ["Cancel subscription","Terms and Conditions","Privacy Policy","Delete Account","Sign out"]
    
    @IBOutlet weak var tblList: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tblList.register(UINib(nibName: "TblSettingCell", bundle: nil), forCellReuseIdentifier: "TblSettingCell")
        
    }

    
    //MARK:- table view :
        func numberOfSections(in tableView: UITableView) -> Int {
               return 1
        }
           
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           
            return self.arrList.count
       }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TblSettingCell", for: indexPath) as! TblSettingCell
        
        cell.lblName.text = self.arrList[indexPath.row]
        
        return cell
    
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tblList.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0
        {
            let alert = UIAlertController(title: "Cancel Subscription", message: "If you want to cancel subscription please goto Setting > Your Name > Tap Subscriptions > Cancel Subscription", preferredStyle: .alert)
           
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
                
            }))
            
            alert.addAction(UIAlertAction(title: "Open Setting", style: .default, handler: { action in
                       
                           UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)

                       }))
                       
            self.present(alert, animated: true, completion: nil)
            
        }
        else if indexPath.row == 1
        {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let answ = storyboard.instantiateViewController(withIdentifier: "TermsNConditionVC") as! TermsNConditionVC
                answ.modalPresentationStyle = .fullScreen
                answ.modalTransitionStyle = .crossDissolve
                self.present(answ, animated: true, completion: nil)
        }
        else if indexPath.row == 2
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let answ = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyScreenVC") as! PrivacyPolicyScreenVC
            answ.modalPresentationStyle = .fullScreen
            answ.modalTransitionStyle = .crossDissolve
            self.present(answ, animated: true, completion: nil)
        }
        else if indexPath.row == 3
        {
                let alertVC = UIAlertController(title: "Postifeedy", message: "Are you sure want to Delete Account?", preferredStyle: UIAlertController.Style.alert)
                alertVC.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                alertVC.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                    do
                    {
                        
                        var mydocument_ID : String = ""
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
                                        
                                        DispatchQueue.main.async {
                                            let user = Auth.auth().currentUser
                                            
                                            user?.delete { error in
                                              if let error = error {
                                                // An error happened.
                                                print("Delete user :: " + error.localizedDescription)
                                                if(error.localizedDescription.contains("requires recent authentication")){
                                                    self.view.makeToast("Please re-login to delete your account!")
                                                    DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                                                        let appDel =  UIApplication.shared.delegate as! AppDelegate
                                                        appDel.arrBookMarkLink = []
                                                        
                                                        let scheduler = DLNotificationScheduler()
                                                        scheduler.getScheduledNotifications { (request) in
                                                            request?.forEach({ (item) in
                                                                if(item.identifier.contains("manifest")){
                                                                    scheduler.cancelNotification(identifier: item.identifier)
                                                                }
                                                            })
                                                        }
                                                        UserDefaults.standard.set(false, forKey: "isLogin")
                                                        
                                                        UserDefaults.standard.removeObject(forKey: PREF_DAILY_QUESTION_COUNT)
                                                        UserDefaults.standard.removeObject(forKey: PREF_CURRENT_DATE)
                                                        UserDefaults.standard.removeObject(forKey: PREF_BOOKED_DATE)
                                                        
                                                        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "logInViewController") as! logInViewController
                                                        
                                                        let nav = UINavigationController(rootViewController: loginVC )
                                                        nav.setNavigationBarHidden(true, animated: false)
                                                        
                                                        appDel.window?.rootViewController = nav
                                                        appDel.window?.makeKeyAndVisible()
                                                    }
                                                    
                                                }

                                              } else {
                                                // Account deleted.
                                                print("Delete user :: Document successfully removed! finally !")
                                                mydocument_ID = doc.documentID
                                                if mydocument_ID != ""
                                                {
                                                    print("my doc :\(mydocument_ID)")
                                                    db.collection("users").document(mydocument_ID).delete() { err in
                                                        if let err = err {
                                                            print("Error removing document: \(err)")
                                                        } else {
                                                            print("Document successfully removed!")
                                                            
                                                            let appDel =  UIApplication.shared.delegate as! AppDelegate
                                                            appDel.arrBookMarkLink = []
                                                            
                                                            let scheduler = DLNotificationScheduler()
                                                            scheduler.getScheduledNotifications { (request) in
                                                                request?.forEach({ (item) in
                                                                    if(item.identifier.contains("manifest")){
                                                                        scheduler.cancelNotification(identifier: item.identifier)
                                                                    }
                                                                })
                                                            }
                                                            UserDefaults.standard.set(false, forKey: "isLogin")
                                                            
                                                            UserDefaults.standard.removeObject(forKey: PREF_DAILY_QUESTION_COUNT)
                                                            UserDefaults.standard.removeObject(forKey: PREF_CURRENT_DATE)
                                                            UserDefaults.standard.removeObject(forKey: PREF_BOOKED_DATE)
                                                            
//                                                            DispatchQueue.main.async {
//                                                                Auth.auth().currentUser?.delete(completion: { (error) in
//                                                                    print("Delete user :: " + error.debugDescription)
//                                                                })
//                                                            }
                                                            
                                                            
                                                            
                                                            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "logInViewController") as! logInViewController
                                                            
                                                            let nav = UINavigationController(rootViewController: loginVC )
                                                            nav.setNavigationBarHidden(true, animated: false)
                                                            
                                                            appDel.window?.rootViewController = nav
                                                            appDel.window?.makeKeyAndVisible()
                                                        }
                                                    }
                                                }
                                              }
                                            }
                                           
                                        }
                                        
                                        
                                            
                                    }
                                }
                            }
                        }
                        
                        
                        
                    }
                    catch
                    {
                        self.view.makeToast(error.localizedDescription)
                    }
                }))
                present(alertVC, animated: true, completion: nil)
        }
        else
        {
            let alertVC = UIAlertController(title: "Postifeedy", message: "Are you sure want to Sign out?", preferredStyle: UIAlertController.Style.alert)
            alertVC.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alertVC.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                do
                {
                    try   Auth.auth().signOut()
                    
                    let appDel =  UIApplication.shared.delegate as! AppDelegate
                    appDel.arrBookMarkLink = []
                    
                    UserDefaults.standard.set(false, forKey: "isLogin")
                    
                    UserDefaults.standard.removeObject(forKey: PREF_DAILY_QUESTION_COUNT)
                    UserDefaults.standard.removeObject(forKey: PREF_CURRENT_DATE)
                    UserDefaults.standard.removeObject(forKey: PREF_BOOKED_DATE)
                    
                    let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "logInViewController") as! logInViewController
                    
                    
                    let nav = UINavigationController(rootViewController: loginVC )
                    nav.setNavigationBarHidden(true, animated: false)
                    
                    appDel.window?.rootViewController = nav
                    appDel.window?.makeKeyAndVisible()
                }
                catch
                {
                    self.view.makeToast(error.localizedDescription)
                }
            }))
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
        
    }
    
    
    @IBAction func onclicfkorBack(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
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
