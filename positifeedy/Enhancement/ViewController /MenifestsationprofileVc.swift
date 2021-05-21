//
//  MenifestsationprofileVc.swift
//  positifeedy
//
//  Created by iMac on 03/05/21.
//  Copyright © 2021 Evyn Gonzalez . All rights reserved.
//

import UIKit
import Firebase

class MenifestsationprofileVc: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var myDocId : String! = ""
    var arrMyManifestEntry = NSMutableArray()
    var IsSubscripted = false

    @IBOutlet weak var clvManifestList: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        
        clvManifestList.delegate = self
        clvManifestList.dataSource = self
        
        getProfileData()
        
    }
    
    
    @IBAction func backhome(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnLoadMoreClick(_ sender: UIButton) {
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(arrMyManifestEntry.count > 0){
            clvManifestList.isHidden = false
        }else{
            clvManifestList.isHidden = true
        }
        return arrMyManifestEntry.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = clvManifestList.dequeueReusableCell(withReuseIdentifier: "JournalListCell", for: indexPath)as! JournalListCell
        
        let dict = arrMyManifestEntry.object(at: indexPath.row) as? NSDictionary
        let imgUrl = dict?.value(forKey: "link") as? String ?? ""
        let answer = dict?.value(forKey: "answer") as? String ?? ""
        
        cell.journalDate.text = answer
        
        if(imgUrl != ""){
            cell.journalImage.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "ReflectionBG"), options: .highPriority, context: nil)
        }else{
            cell.journalImage.image = UIImage(named: "ReflectionBG")
        }
         
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let dict = arrMyManifestEntry.object(at: indexPath.row) as? NSDictionary
        let imgUrl = dict?.value(forKey: "link") as? String ?? ""
        let answer = dict?.value(forKey: "answer") as? String ?? ""
        let audio_url = dict?.value(forKey: "audio_url") as? String ?? ""
        let manifestDay = dict?.value(forKey: "manifestDay") as? String ?? ""
        let manifestTime = dict?.value(forKey: "manifestTime") as? String ?? ""
        let play_time = dict?.value(forKey: "play_time") as? String ?? "0"
        let isActive = dict?.value(forKey: "isActive") as? Bool ?? false
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ManifestDetailViewController") as! ManifestDetailViewController
        vc.DataTime = manifestTime
        vc.DataDay = manifestDay
        vc.DataAudio = audio_url
        vc.DataMessage = answer
        vc.DataImageUrl = imgUrl
        vc.DataAllManifest = arrMyManifestEntry
        vc.DataAudioTime = play_time
        vc.DataIsActive = isActive
        vc.myDocId = myDocId
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height

        return CGSize(width: screenWidth/2, height: (screenWidth/2.8))
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
                        self.myDocId = doc.documentID
                       if let strURL = (d["pic"] as? String)
                       {
                           let url = URL(string: strURL)
                          
                       }
                        
                        let subscription = d["Subscription"] as? String
                        if subscription != nil
                        {
                            if subscription == "0"
                            {
                                self.IsSubscripted = false
                            }else
                            {
                                self.IsSubscripted = true
                                
                            }
                        }
                        
                        var arr = d["ManifestEntry"] as? NSArray
                        if arr != nil
                        {
                            if arr!.count > 0
                            {
                                arr = (arr?.reversed() as! NSArray)
                                self.arrMyManifestEntry = NSMutableArray.init(array: arr!)
                            }
                        }
                        else
                        {
                            print("No ManifestEntry Object !")
                        }
                        self.clvManifestList.reloadData()
                        
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
}
