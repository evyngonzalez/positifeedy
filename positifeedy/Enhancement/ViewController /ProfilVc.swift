//
//  ProfilVc.swift
//  positifeedy
//
//  Created by iMac on 03/05/21.
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
import FTPopOverMenu_Swift
import Alamofire
import EMPageViewController
import SVProgressHUD

class ProfilVc: UIViewController {

    @IBOutlet weak var userProfile: RoundableImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userLevel: UILabel!
    @IBOutlet weak var levelLogo: UIImageView!
    @IBOutlet weak  var activity : UIActivityIndicatorView!
    @IBOutlet weak var backgroundImage: UIImageView!
          
    @IBOutlet weak var boxView: UIView!
    var myDocId : String?
    var arrListOfJourny : NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.boxView.layer.cornerRadius = 20
            self.boxView.dropShadow(color: .lightGray, opacity: 0.4, offSet: CGSize(width: 1, height: 1), radius: 20, scale: true)
        }
        
        
//        boxView.layer.borderWidth = 2
//        boxView.layer.borderColor = UIColor.black.cgColor
        
        SVProgressHUD.dismiss()
        
        setTabBarItems()
        tabBarController?.tabBarItem.title = ""
        activity.isHidden = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        // profileData()
        profileData()

        self.tabBarController?.tabBar.isHidden = false
        
        let data = UserDefaults.standard.data(forKey: "UserProfileImage") ?? Data()
        if(data.count > 0){
            let image = UIImage(data: data)!
//            let resized: UIImage = image.resizedImage().roundedImageWithBorder(width: 2, color: UIColor.green)!.withRenderingMode(.alwaysOriginal)
//            self.tabBarController?.tabBar.items?[3].image = resized
//            self.tabBarController?.tabBar.items?[3].selectedImage = resized
            
            self.tabBarController?.tabBar.items?[3].image = image.resizedImage().roundedImageWithBorder(width: 0)!.withRenderingMode(.alwaysOriginal)
            self.tabBarController?.tabBar.items?[3].selectedImage = image.resizedImage().roundedImageWithBorder(width: 2)!.withRenderingMode(.alwaysOriginal)
            
        }else{
            
            let image = UIImage(named: "profile-placeholder-big")!
            self.tabBarController?.tabBar.items?[3].image = image.resizedImage().roundedImageWithBorder(width: 0)!.withRenderingMode(.alwaysOriginal)
            self.tabBarController?.tabBar.items?[3].selectedImage = image.resizedImage().roundedImageWithBorder(width: 2)!.withRenderingMode(.alwaysOriginal)
            
        }

    }
    func image(with image: UIImage, scaledTo newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
    }
    func setTabBarItems(){

    }
    @IBAction func setting(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let answ = storyboard.instantiateViewController(withIdentifier: "SetttingScreenVC") as! SetttingScreenVC
        answ.modalPresentationStyle = .fullScreen
        answ.modalTransitionStyle = .crossDissolve
        self.present(answ, animated: true, completion: nil)
    }
    
    @IBAction func userProfileEdit(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVc") as! EditProfileVc
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func journalEntries(_ sender: UIButton) {
       let vc = self.storyboard?.instantiateViewController(withIdentifier: "JournalEntriesVc") as! JournalEntriesVc
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func menifeststation(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MenifestsationprofileVc") as! MenifestsationprofileVc
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnStagesClick(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "StaggesOfMindfullnessVc") as! StaggesOfMindfullnessVc
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func profileData()
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
                        self.userName.text = String.init(format: "%@ %@", (d["firstname"] as! String),(d["lastname"] as! String))
                        
                        //    self.lblEmail.text = Auth.auth().currentUser?.email
                        
                        if let strURL = (d["profileImage"] as? String)
                        {
                            let url = URL(string: strURL)!
                            self.activity.startAnimating()
                            self.activity.isHidden = false
//                            DispatchQueue.global(qos: .background).async {
                                do
                                {
                                   // let data = try Data(contentsOf: url!)
                                    DispatchQueue.main.async {
                                        
                                        self.userProfile.sd_setImage(with: url, placeholderImage: UIImage(named: "profile-placeholder-big"), options: .highPriority) { (image, error, type, url) in
                                            
//                                            let resized: UIImage = image!.resizedImage().roundedImageWithBorder(width: 2, color: UIColor.green)!.withRenderingMode(.alwaysOriginal)
                                            
                                            let data = image?.pngData() ?? Data()
                                            if(data.count > 0){
                                                UserDefaults.standard.setValue(data, forKey: "UserProfileImage")
                                                UserDefaults.standard.synchronize()
                                            }else{
                                                let image = UIImage(named: "profile-placeholder-big")!
                                                self.tabBarController?.tabBar.items?[3].image = image.resizedImage().roundedImageWithBorder(width: 0)!.withRenderingMode(.alwaysOriginal)
                                                self.tabBarController?.tabBar.items?[3].selectedImage = image.resizedImage().roundedImageWithBorder(width: 2)!.withRenderingMode(.alwaysOriginal)
                                            }
                                            
//                                            self.tabBarController?.tabBar.items?[3].image = resized
//                                            self.tabBarController?.tabBar.items?[3].selectedImage = resized
                                            self.tabBarController?.tabBar.items?[3].image = image!.resizedImage().roundedImageWithBorder(width: 0)!.withRenderingMode(.alwaysOriginal)
                                            self.tabBarController?.tabBar.items?[3].selectedImage = image!.resizedImage().roundedImageWithBorder(width: 2)!.withRenderingMode(.alwaysOriginal)

                                        }
                
                                        self.activity.stopAnimating()
                                        self.activity.isHidden = true
                                    }
                                    
                                }
                                catch   {
                                    self.view.makeToast("Somthing went to wrong")
                                }
//                            }
                        }
                         if let strURL = (d["backgroundImage"] as? String)
                        {
                            let url = URL(string: strURL)!
                           // DispatchQueue.global(qos: .background).async {
                                do
                                {
                                    self.backgroundImage.sd_setImage(with: url, placeholderImage: UIImage(named: "cover-placeholder"), options: .highPriority)
                                    
                                }
                                catch{
                                    self.view.makeToast("Somthing went to wrong")
                                }
                           // }
                        }
                        
                        
                        let mindstatus = d["mindstatus"] as? String
                        if mindstatus != nil
                        {
                            
                            self.userLevel.text = String.init(format: "%@",mindstatus as! CVarArg)
                            
                            if mindstatus?.lowercased() == "beginner"
                            {
                                self.levelLogo.image = UIImage.init(named: "1")
                            }
                            else if mindstatus?.lowercased() == "intermediate"
                            {
                                self.levelLogo.image = UIImage.init(named: "intermediate")
                                
                            }
                            else if mindstatus?.lowercased() == "advanced"
                            {
                                self.levelLogo.image = UIImage.init(named: "advacnce")
                                
                            }
                            else if mindstatus?.lowercased() == "expert"
                            {
                                self.levelLogo.image = UIImage.init(named: "4")
                                
                            }
                            else if mindstatus?.lowercased() == "master"
                            {
                                self.levelLogo.image = UIImage.init(named: "master")
                                
                            }else
                            {
                                
                            }
                        }
                        else
                        {
                            self.userLevel.text = "Beginner"
                            self.levelLogo.image = UIImage.init(named: "1")
                        }
                        
                        
                        
                        
                        let arr = d["JournalEntry"] as? NSArray
                        if arr != nil
                        {
                            if arr!.count > 0
                            {
                                self.arrListOfJourny = NSMutableArray.init(array: arr!)
                                print("My Journal :\(self.arrListOfJourny)")
                                
                            }
                        }
                        else
                        {
                            print("")
                        }
                        
                    }
                }
                
            }
        }
    }
    
}
