//
//  JournalEntriesVc.swift
//  positifeedy
//
//  Created by iMac on 03/05/21.
//  Copyright © 2021 Evyn Gonzalez . All rights reserved.
//

import UIKit
import Firebase

class JournalEntriesVc: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    var myDocId : String! = ""
    var arrMyJournalEntry = NSMutableArray()
    var IsSubscripted = false

    @IBOutlet weak var clvJournalList: UICollectionView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        
        clvJournalList.delegate = self
        clvJournalList.dataSource = self
        
        getProfileData()
        
    }
    
    
    @IBAction func backhome(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnLoadMoreClick(_ sender: UIButton) {
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(arrMyJournalEntry.count > 0){
            clvJournalList.isHidden = false
        }else{
            clvJournalList.isHidden = true
        }
        return arrMyJournalEntry.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = clvJournalList.dequeueReusableCell(withReuseIdentifier: "JournalListCell", for: indexPath)as! JournalListCell
        
        let dict = arrMyJournalEntry.object(at: indexPath.row) as? NSDictionary
        let imgUrl = dict?.value(forKey: "link") as? String ?? ""
        let dateStr = dict?.value(forKey: "current_date") as? String ?? ""
        
        if(dateStr != ""){
            let dateFormatterr = DateFormatter()
            dateFormatterr.dateFormat = "yyyy-MM-dd"
            let date = dateFormatterr.date(from: dateStr)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd"
            let dateString = dateFormatter.string(from: date!)

//            let dateFormatter1 = DateFormatter()
//            dateFormatter1.dateFormat = "yyyy"
//            let dateString1 = dateFormatter1.string(from: date!)

//            cell.journalDate.text = String.init(format: "%@%@, %@", dateString,self.daySuffix(from: date!), dateString1)
            cell.journalDate.text = String.init(format: "%@%@", dateString,self.daySuffix(from: date!))

        }
        
        if(imgUrl != ""){
            cell.journalImage.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "ReflectionBG"), options: .highPriority, context: nil)
        }else{
            cell.journalImage.image = UIImage(named: "ReflectionBG")
        }
         
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let dict = arrMyJournalEntry.object(at: indexPath.row) as? NSDictionary

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "JournalDetailViewController") as! JournalDetailViewController
        vc.DataJournal = dict?.mutableCopy() as? NSMutableDictionary ?? NSMutableDictionary()
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
                        
                        let arr = d["JournalEntry"] as? NSArray
                        if arr != nil
                        {
                            if arr!.count > 0
                            {
                                self.arrMyJournalEntry = NSMutableArray.init(array: arr!)
                                self.arrMyJournalEntry = (self.arrMyJournalEntry.reversed() as! NSArray).mutableCopy() as! NSMutableArray

                            }
                        }
                        else
                        {
                            print("No JournalEntry Object !")
                        }
                        
                        self.clvJournalList.reloadData()
                        
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
