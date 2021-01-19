//
//  GreetingViewControllerProfile.swift
//  positifeedy
//
//  Created by Hiren Dhamecha on 17/12/20.
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
import Alamofire
import SVProgressHUD

class GreetingViewControllerProfile: UIViewController
{

    var arrBookMarkAll : NSMutableArray!
    var arrListOfJourny = [AnswerFeed]()
    var flagType : Int!
    var arrTempTimeStamp = [OnlyTimeStamp]()
    var pos : Int = 0
    var arrData : [Any] = []
    var arrDataTemp : [Any] = []
    
    var lblError : UILabel?
       
    var arrFeeds  : [Feed]?
    var arrPositifeedy = [Positifeedy]()

    var myDocId : String?
       
   @IBOutlet weak  var activity : UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblmsg: UILabel!
    
    var greeting:String!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.arrBookMarkAll = NSMutableArray.init()
        
        tableView.rowHeight = UITableView.automaticDimension
              
        tableView.register(UINib(nibName: "FeedCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.register(UINib(nibName: "FeedyCell", bundle: nil), forCellReuseIdentifier: "FeedyCell")
              
              
        tableView.register(UINib(nibName: "tblJournalCell", bundle: nil), forCellReuseIdentifier: "tblJournalCell")

        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        //getFeeds()
        getProfileData()
      
        
        if self.greeting == "Journal Entries"
        {
            self.flagType = 1
            //self.tableView.reloadData()
            self.lblmsg.text = "No Journal entries available"
            
        }else
        {
            self.flagType = 2
            //self.tableView.reloadData()
            self.lblmsg.text = "No bookmark available"
        }
        
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
                           let obj = try jsonDecoder.decode([Positifeedy].self, from: jsonData)
                           self.arrPositifeedy = obj.sorted(by: { (feed1, feed2) -> Bool in
                               let date1 = Date(timeIntervalSince1970: Double(feed1.timestamp ?? "\(Date().timeIntervalSince1970)")!)
                               let date2 = Date(timeIntervalSince1970: Double(feed2.timestamp ?? "\(Date().timeIntervalSince1970)")!)
                               return date1 > date2
                           })
                          self.getFeeds()
                           
                       }
                       catch {
                           
                       }
                       
                   }
               }
           }
       
       func getFeeds() {
           
        
           arrData.removeAll()
           arrTempTimeStamp.removeAll()
        
           if arrFeeds != nil
           {
               let appDel =  UIApplication.shared.delegate as! AppDelegate
               
               var tempBookMark = [Feed]()
               
               for link in appDel.arrBookMarkLink
               {
                    tempBookMark.append(contentsOf:  (arrFeeds?.filter { $0.link == link})! )
                    
               }
               print("Arr bookmark link :\(appDel.arrBookMarkLink)")
            
               arrData.append(contentsOf: tempBookMark)
            
            
              // self.tableView.reloadData()
           }
           
           if arrPositifeedy.count > 0
           {
               let appDel =  UIApplication.shared.delegate as! AppDelegate
               
               var tempBookMark = [Positifeedy]()
                
                print("Arr bookmark :\(appDel.arrBookMarkLinkFeedy)")
               for link in appDel.arrBookMarkLinkFeedy
               {
                       tempBookMark.append(contentsOf: (arrPositifeedy.filter { $0.documentID == link}) )
               }
                
                
            
              arrData.append(contentsOf: tempBookMark)
            
               //arrData.append(contentsOf: tempBookMark)
              // self.tableView.reloadData()
           }
        
        
        if arrData.count > 0
        {
            
//            let arr = arrData.sorted { (obj1, obj2) -> Bool in
//
//                if let feed1 = obj1 as? Feed, let feed2 = obj2 as? Feed {
//                    return Double(feed1.timestamp!) > Double(feed2.timestamp!)
//                } else if let feed1 = obj1 as? Feed, let feed2 = obj2 as? Positifeedy {
//                    return Double(feed1.timestamp!) > Double(feed2.timestamp!)!
//                } else if let feed1 = obj1 as? Positifeedy, let feed2 = obj2 as? Feed {
//                    return Double(feed1.timestamp!)! > Double(feed2.timestamp!)
//                } else {
//                    return Double((obj1 as! Positifeedy).timestamp!)! > Double((obj2 as! Positifeedy).timestamp!)!
//                }
//            }
//
//            arrData = arr
//            self.tableView.reloadData()
          
            arrData.removeAll()
            let a = NSArray.init(array: self.arrBookMarkAll)
            let filArray = a.discendingArrayWithKeyValue(key: "timestamp")
            print(filArray)
            self.arrBookMarkAll = NSMutableArray.init(array: filArray)
            let finalArray = NSMutableArray.init(array: filArray)
            
            for i in (0..<finalArray.count)
            {
                let dict = finalArray.object(at: i) as? NSDictionary
                if ((dict?.object(forKey: "link")) != nil)
                {
                    let link = String.init(format: "%@",(dict?.value(forKey: "link") as? CVarArg)!)
                    if arrFeeds != nil
                    {
                        arrData.append(contentsOf: (arrFeeds?.filter { $0.link == link})!)
                    }
                }
                
               if ((dict?.object(forKey: "feed")) != nil)
               {
                   let link = String.init(format: "%@",(dict?.value(forKey: "feed") as? CVarArg)!)
                    if arrPositifeedy != nil
                    {
                        arrData.append(contentsOf: (arrPositifeedy.filter { $0.documentID == link}))
                    }
               }
            }
            
            if arrData.count > 0
            {
               self.tableView.reloadData()
            }
            
            
//            for i in (0..<arrData.count)
//            {
//                if let feed = arrData[i] as? Feed
//                {
//                    arrTempTimeStamp.append(OnlyTimeStamp(timestamp: feed.timestamp))
//
//                }
//                else
//                {
//                    let feed = arrData[i] as! Positifeedy
//                    let timestampInt = Int(feed.timestamp!)
//                    arrTempTimeStamp.append(OnlyTimeStamp(timestamp: timestampInt))
//                }
//            }
//
//            arrTempTimeStamp.sort {
//                $0.timestamp > $1.timestamp
//            }
//
//            print("arrTempTimeStamp :\(arrTempTimeStamp.count) and arrData :\(arrData.count)")
//           // self.recursiveFunction()
//            //self.tableView.reloadData()
//
//            arrDataTemp.removeAll()
//            for i in (0..<arrData.count)
//            {
//                if let feed = arrData[i] as? Feed
//                {
//                    for j in (0..<arrTempTimeStamp.count)
//                    {
//                        let onlytime = arrTempTimeStamp[j]
//                        if feed.timestamp == onlytime.timestamp
//                        {
//                            arrDataTemp.append(feed)
//                        }
//                    }
//                }
//                else
//                {
//                    let feed = arrData[i] as! Positifeedy
//
//                    for j in (0..<arrTempTimeStamp.count)
//                    {
//                        let onlytime = arrTempTimeStamp[j]
//                        if Int(feed.timestamp!) == onlytime.timestamp
//                        {
//                            arrDataTemp.append(feed)
//                        }
//                    }
//                }
//            }
//
//            if arrDataTemp.count > 0
//            {
//
//                print("Arrdata :\(arrDataTemp) :\(arrData)")
//                self.tableView.reloadData()
//            }
            
        }
        
            if self.flagType == 2
            {
                    if self.arrData.count > 0
                    {
                        self.lblmsg.text = ""
                    }
            }
        
        
       }
       
//            func recursiveFunction()
//           {
//               if self.pos > self.arrTempTimeStamp.count - 1
//               {
//                   self.tableView.reloadData()
//                 print("array Sort :\(self.arrTempTimeStamp)")
//
//               }else
//               {
//                   while pos >= 0 {
//
//                       if self.pos >= self.arrTempTimeStamp.count - 1
//                       {
//
//                        }
//                       else
//                       {
//                                let onlytime = arrTempTimeStamp[pos]
//
//                                for i in (0..<arrData.count)
//                                {
//                                    if let feed = arrData[i] as? Feed
//                                    {
//
//                                        if feed.timestamp == onlytime.timestamp
//                                        {
//                                            self.arrDataTemp.append(feed)
//                                            pos = pos + 1
//                                           self.recursiveFunction()
//                                        }
//
//                                    }else
//                                    {
//
//                                        let feed = arrData[i] as! Positifeedy
//                                     if Int(feed.timestamp!) == onlytime.timestamp
//                                        {
//                                            self.arrDataTemp.append(feed)
//                                            pos = pos + 1
//                                         self.recursiveFunction()
//                                        }
//
//                                    }
//                                }
//                        }
//
//                   }
//               }
//           }
           
    
    
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

                        let arr = d["JournalEntry"] as? NSArray
                       if arr != nil
                       {
                           if arr!.count > 0
                           {
                               
                            let finalArray = NSMutableArray.init(array: arr!)
                                            do {
                                                               
                                                               let jsonData = try JSONSerialization.data(withJSONObject: finalArray, options: .prettyPrinted)
                                                               let jsonDecoder = JSONDecoder()
                                                               let obj = try jsonDecoder.decode([AnswerFeed].self, from: jsonData)
                                                               //self.arrListOfJourny = obj
                                                               self.arrListOfJourny = obj.sorted(by: { (feed1, feed2) -> Bool in
                                                                   let date1 = Date(timeIntervalSince1970: Double(feed1.timestamp ?? "\(Date().timeIntervalSince1970)")!)
                                                                   let date2 = Date(timeIntervalSince1970: Double(feed2.timestamp ?? "\(Date().timeIntervalSince1970)")!)
                                                                   return date1 > date2
                                                               })
                                               }
                                               catch {
                                                   
                                               }
                                               print("Question List :\(self.arrListOfJourny)")
                                    if self.arrListOfJourny.count > 0
                                    {
                                        self.tableView.reloadData()
                                    }
                           }
                       }
                       else
                       {
                           print("No JournalEntry Object !")
                       }
                    
                    if self.flagType == 1
                    {
                            if self.arrListOfJourny.count > 0
                            {
                                self.lblmsg.text = ""
                            }
                        
                    }
                    
                       let appDel = UIApplication.shared.delegate as! AppDelegate
                        appDel.myDocID = doc.documentID
                    
                        if let links = (d["links"] as? [String])
                        {
                            appDel.arrBookMarkLink = links
                        }
                        else
                        {
                             appDel.arrBookMarkLink = []
                        }
                        
                    
                        if let links = (d["linksFeedy"] as? [String])
                        {
                            appDel.arrBookMarkLinkFeedy = links
                        }
                        else
                        {
                            appDel.arrBookMarkLinkFeedy = []
                        }
                    
                    
                            let arrB = d["bookmarkarray"] as? NSArray
                            if arrB != nil
                           {
                                self.arrBookMarkAll = NSMutableArray.init(array: arrB!)
                           }
                           else
                           {
                              self.arrBookMarkAll = NSMutableArray.init()
                           }
                    
                          self.getFeedsList()
                          self.getPositifeedy()
                         // self.getFeeds()
                   }
                   }
                   
               }
           }
       }
    
    
//    func getBookmarsData()
//      {
//          var db: Firestore!
//
//          db = Firestore.firestore()
//
//          db.collection("users").getDocuments { (snap, error) in
//              if error != nil
//              {
//                  print("error ", error!.localizedDescription)
//                  return
//              }
//
//              for doc in snap?.documents ?? []
//              {
//                  let  d = doc.data()
//
//                  if d.count > 0
//                  {
//                      if (d["uid"] as! String) == Auth.auth().currentUser?.uid
//                      {
//                          let appDel = UIApplication.shared.delegate as! AppDelegate
//
//                          self.myDocId = doc.documentID
//                          appDel.myDocID = doc.documentID
//
//                          if let links = (d["links"] as? [String])
//                          {
//                              appDel.arrBookMarkLink = links
//                          }
//                          //self.tableView.reloadData()
//                      }
//                  }
//              }
//          }
//      }
    
//    func getBookmarsDataFeedy()
//         {
//             var db: Firestore!
//
//             db = Firestore.firestore()
//
//             db.collection("users").getDocuments { (snap, error) in
//                 if error != nil
//                 {
//                     print("error ", error!.localizedDescription)
//                     return
//                 }
//
//                 for doc in snap?.documents ?? []
//                 {
//                     let  d = doc.data()
//                     if d.count > 0
//                     {
//                     if (d["uid"] as! String) == Auth.auth().currentUser?.uid
//                     {
//                         let appDel = UIApplication.shared.delegate as! AppDelegate
//
//                         self.myDocId = doc.documentID
//                         appDel.myDocID = doc.documentID
//
//                         if let links = (d["linksFeedy"] as? [String])
//                         {
//                             appDel.arrBookMarkLinkFeedy = links
//                         }
//                         //self.tableView.reloadData()
//                         }
//                     }
//                 }
//             }
//         }
//
    
     func getFeedsList()  {
                 
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
                            
                                self.getFeeds()
                            
    //                         if self.isRefresh
    //                         {
    //                             self.refreshControl.endRefreshing()
    //                             self.isRefresh = false
    //                         }
                         }
                         
                     case .failure(let error) :
                         print(error)
                     }
                     
                 }
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
//MARK:- UITableViewDataSource
extension GreetingViewControllerProfile : UITableViewDataSource
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.flagType == 1
        {
            if self.arrListOfJourny != nil
            {
                if self.arrListOfJourny.count > 0
                {
                    return self.arrListOfJourny.count
                }
                else
                {
                    return 0
                }
            }
            else
            {
                return 0
            }
            
        }else
        {
                lblError?.isHidden = arrData.count == 0  ? false : true
                
                    return arrData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.flagType == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tblJournalCell", for: indexPath) as! tblJournalCell
            
            cell.bgview.layer.cornerRadius = 5
            cell.bgview.clipsToBounds  = true
            
            let answerfeed = self.arrListOfJourny[indexPath.row]
            //let dict = self.arrListOfJourny.object(at: indexPath.row) as! NSDictionary
            //cell.lblDate.text = String.init(format: "%@", self.changeFormateDate(strDate: (dict.value(forKey: "current_date") as? String)!))
            //cell.lblQuestion.text = String.init(format: "%@",(dict.value(forKey: "question") as? CVarArg)!)
            
            cell.lblDate.text = String.init(format: "%@",self.changeFormateDate(strDate: answerfeed.current_date!))
            cell.lblQuestion.text = String.init(format: "%@",answerfeed.question!)
            
            let strURL = String.init(format: "%@", answerfeed.link!)
            cell.imgItem.sd_setImage(with: URL.init(string: strURL), placeholderImage: UIImage(named: "place"))
            
            return cell
        }
        else
        {
            
            if let feed = arrData[indexPath.row] as? Feed {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FeedCell

                let date = feed.time?.toDate()
                
                cell.btnPlay.isHidden = true

                cell.lblTitle.text = feed.title
                cell.lblDesc.text = feed.desc
                cell.lblTime.text  = date!.getElapsedInterval((feed.time?.getTimeZone())!)
                
                cell.btnBookMark.setImage(UIImage(named: "cancel"), for: .normal)
                        
                cell.btnBookMark.tag = indexPath.row
                cell.btnBookMark.addTarget(self, action: #selector(btnBookMarkRemoveClick), for: .touchUpInside)
                cell.imgView.cornerRadius(10)
                
                if let link = URL(string: feed.link!)
                {
                    if let img = Images(rawValue: (link.domain)!)?.image
                    {
                        cell.imgView.image = UIImage(named: img )
                    }
                }
                
                cell.btnShare.isHidden = false
                cell.btnShare.tag = indexPath.row
                cell.btnShare.addTarget(self, action: #selector(btnShareClickFeed), for: .touchUpInside)
                
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "FeedyCell", for: indexPath) as! FeedyCell
                
                let feed = arrData[indexPath.row] as! Positifeedy
                
                cell.bindData(feed: feed)

                cell.btnShare.isHidden = true

                cell.btnBookMark.setImage(UIImage(named: "cancel"), for: .normal)
                        
                cell.btnBookMark.tag = indexPath.row
                cell.btnBookMark.addTarget(self, action: #selector(btnBookMarkRemoveClick), for: .touchUpInside)
                
                cell.btnPlay.tag = indexPath.row
                cell.btnPlay.addTarget(self, action: #selector(btnPlayTapped(_:)), for: .touchUpInside)

                cell.btnShare.isHidden = false
                cell.btnShare.tag = indexPath.row
                cell.btnShare.addTarget(self, action: #selector(btnShareClick), for: .touchUpInside)

                return cell
            }
        }
    }
    
    //MARK:- btn share feed
    @objc func btnShareFeed(sender : UIButton)  {
        print("Feed share ")
    }
    
    //MARK:- btn share feed
    @objc func btnShareFeedy(sender : UIButton)  {
        
        print("Feedy share ")
        
        
    }
    
    @objc func btnShareClickFeed(_ sender : UIButton) {
        
        let feed = arrData[sender.tag] as? Feed
        var url : String = feed!.link!
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "positifeedy.page.link"
        components.path = "/share"
        
        let feedURL = URLQueryItem(name: "feedURL", value: url ?? "")
        components.queryItems = [feedURL]
        
        guard let linkParameter = components.url else {
            SVProgressHUD.dismiss()
            return
        }
        
        guard let shareLink = DynamicLinkComponents.init(link: linkParameter, domainURIPrefix: "https://positifeedy.page.link") else {
            SVProgressHUD.dismiss()
            return
        }
        
        if let myBundleId = Bundle.main.bundleIdentifier {
            shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleId)
        }
        
        shareLink.iOSParameters?.appStoreID = "1484015088"
        
        guard let longURL = shareLink.url else {
            SVProgressHUD.dismiss()
            return
        }
        
        shareLink.shorten { [weak self] (url, warnings, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                self?.view.makeToast(error.localizedDescription)
                return
            }
            
            guard let url = url else { return }
            
            self?.showShareSheet(url: url)
            
        }
        
        
    }
    
    func showShareSheet(url: URL) {
        
        let promoText = "Check out this feed"
        let activityVC = UIActivityViewController(activityItems: [promoText, url], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    
    @objc func btnShareClick(_ sender : UIButton) {
        
        SVProgressHUD.show()
        let positifeedy = arrData[sender.tag] as! Positifeedy
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "positifeedy.page.link"
        components.path = "/share"
        
        var arrCompo = [URLQueryItem]()
        
        let feedURL = URLQueryItem(name: "feedURL", value: positifeedy.documentID!)
        arrCompo.append(feedURL)
        
        if let utf8str = (positifeedy.title ?? "").data(using: .utf8) {
            let base64Encoded = utf8str.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
            
            let feedTitle = URLQueryItem(name: "feedTitle", value: base64Encoded)
            arrCompo.append(feedTitle)
        }

        if let utf8str = (positifeedy.desc ?? "").data(using: .utf8) {
            let base64Encoded = utf8str.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
            
            let feedDesc = URLQueryItem(name: "feedDesc", value: base64Encoded)
            arrCompo.append(feedDesc)
        }

        let feedVideo = URLQueryItem(name: "feedVideo", value: positifeedy.feed_video ?? "")
        let feedImage = URLQueryItem(name: "feedImage", value: positifeedy.feed_image ?? "")
        let feedType = URLQueryItem(name: "feedType", value: positifeedy.feed_type ?? "")
        let feedTime = URLQueryItem(name: "feedTime", value: positifeedy.timestamp ?? "")
        let feedLink = URLQueryItem(name: "feedLink", value: positifeedy.feed_url ?? "")

        arrCompo.append(feedVideo)
        arrCompo.append(feedImage)
        arrCompo.append(feedType)
        arrCompo.append(feedTime)
        arrCompo.append(feedLink)

        components.queryItems = arrCompo
        
        guard let linkParameter = components.url else {
            SVProgressHUD.dismiss()
            return
        }
        
        guard let shareLink = DynamicLinkComponents.init(link: linkParameter, domainURIPrefix: "https://positifeedy.page.link") else {
            SVProgressHUD.dismiss()
            return
        }
        
        if let myBundleId = Bundle.main.bundleIdentifier {
            shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleId)
        }
        
        shareLink.iOSParameters?.appStoreID = "1484015088"
        
        guard shareLink.url != nil else {
            
            SVProgressHUD.dismiss()
            return
        }
        
        shareLink.shorten { [weak self] (url, warnings, error) in
            
            SVProgressHUD.dismiss()

            if let error = error {
                self?.view.makeToast(error.localizedDescription)
                return
            }
            
            guard let url = url else { return }
            
            self?.showShareSheet(url: url)
            
        }
    }
    
     @objc func btnBookMarkRemoveClick(sender : UIButton)  {
         
         let appDel = UIApplication.shared.delegate as! AppDelegate
         
         if let obj = arrData[sender.tag] as? Feed {
             let feed = obj.link
             
             arrData.remove(at: sender.tag)
             
             if let index = appDel.arrBookMarkLink.firstIndex(of: feed!)
             {
                 appDel.arrBookMarkLink.remove(at:index)
                 let d = ["links" : appDel.arrBookMarkLink]
                 
                 var db: Firestore!
                 db = Firestore.firestore()
                 
                 db.collection("users").document(myDocId!).updateData(d) { (error) in
                     if error != nil
                     {
                         print(error!.localizedDescription)
                     }
                 }
                
                
                  
                   let searchPredicate = NSPredicate(format: "link beginswith[C] %@",obj.link!)
                           let  arrrDict = self.arrBookMarkAll.filter { searchPredicate.evaluate(with: $0) };
                           let filterArray = NSMutableArray.init(array: arrrDict)
                           if(filterArray.count > 0)
                           {
                                   // alerady exitst
                               let dict = filterArray.object(at: 0) as? NSDictionary
                               // alerady exitst
                               self.arrBookMarkAll.remove(dict)
                               
                               let d2 = ["bookmarkarray" : self.arrBookMarkAll]
                               db.collection("users").document(self.myDocId!).updateData(d2) { (error) in
                                   if error != nil
                                   {
                                       print(error!.localizedDescription)
                                   }
                               }
                               
                           }
                
             }
            
          
            
            
                        
            
            
         } else {
             let feed = (arrData[sender.tag] as! Positifeedy).documentID
             
             arrData.remove(at: sender.tag)
             
             if let index = appDel.arrBookMarkLinkFeedy.firstIndex(of: feed!)
             {
                 
                 appDel.arrBookMarkLinkFeedy.remove(at:index)
                 let d = ["linksFeedy" : appDel.arrBookMarkLinkFeedy]
                 
                 var db: Firestore!
                 db = Firestore.firestore()
                 
                 db.collection("users").document(myDocId!).updateData(d) { (error) in
                     if error != nil
                     {
                         print(error!.localizedDescription)
                     }
                 }
                
                   
                  let searchPredicate = NSPredicate(format: "feed beginswith[C] %@",feed!)
                    let  arrrDict = self.arrBookMarkAll.filter { searchPredicate.evaluate(with: $0) };
                    let filterArray = NSMutableArray.init(array: arrrDict)
                    if(filterArray.count > 0)
                    {
                        let dict = filterArray.object(at: 0) as? NSDictionary
                        // alerady exitst
                        self.arrBookMarkAll.remove(dict)
                        
                        let d2 = ["bookmarkarray" : self.arrBookMarkAll]
                        db.collection("users").document(self.myDocId!).updateData(d2) { (error) in
                            if error != nil
                            {
                                print(error!.localizedDescription)
                            }
                        }
                    }
                
             }
         }
         
         tableView.reloadData()

         
     }

    
    //MARK:- change formate date!
    func changeFormateDate(strDate : String) -> String {
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let showDate = inputFormatter.date(from: strDate)
        inputFormatter.dateFormat = "dd MMM yyyy"
        let resultString = inputFormatter.string(from: showDate!)
        
        return resultString
        
    }
    
    
    @objc func btnPlayTapped(_ sender: UIButton) {
        
        if let feed = arrData[sender.tag] as? Positifeedy {
            if let strUrl = feed.feed_video, let url = URL(string: strUrl) {
                self.playVideo(url: url)
            }
        }
    }
    
    func playVideo(url: URL) {
        let player = AVPlayer(url: url)

        let vc = AVPlayerViewController()
        vc.player = player

        self.present(vc, animated: true) { vc.player?.play() }
    }
}


//MARK: -UITableViewDelegate
extension GreetingViewControllerProfile : UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.flagType == 1
        {
            return 170
            
        }else
        {
            return UITableView.automaticDimension
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.flagType == 1
        {
            
            self.tableView.deselectRow(at: indexPath, animated: true)

            let answerfeed = self.arrListOfJourny[indexPath.row]
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let answ = storyboard.instantiateViewController(withIdentifier: "AnswerDetailsVC") as! AnswerDetailsVC
            answ.modalPresentationStyle = .fullScreen
            answ.modalTransitionStyle = .crossDissolve
            answ.anser_feed = answerfeed
            self.present(answ, animated: true, completion: nil)
            
        }
        else
        {
            if let feed = arrData[indexPath.row] as? Feed {
                
                let webVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
                webVC.url = feed.link
                webVC.myDocID = self.myDocId
                webVC.isBookmark = true
                navigationController?.pushViewController(webVC, animated: true)
                
            } else if let feed = arrData[indexPath.row] as? Positifeedy {
                
                let feed_type = feed.feed_type ?? ""

                if feed_type == "link" {
                    let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewFeedy") as! WebViewFeedy
                    detailVC.myDocID = self.myDocId
                    detailVC.isBookmark = true
                    detailVC.positifeedy = feed
                    navigationController?.pushViewController(detailVC, animated: true)
                } else {
                    let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "PostDetailViewController") as! PostDetailViewController
                    detailVC.myDocID = self.myDocId
                    detailVC.isBookmark = true
                    detailVC.positifeedy = feed
                    navigationController?.pushViewController(detailVC, animated: true)
                }
            }
        }
    }
}


extension NSArray{
 //sorting- ascending
  func ascendingArrayWithKeyValue(key:String) -> NSArray{
    let ns = NSSortDescriptor.init(key: key, ascending: true)
    let aa = NSArray(object: ns)
    let arrResult = self.sortedArray(using: aa as! [NSSortDescriptor])
    return arrResult as NSArray
  }

  //sorting - descending
  func discendingArrayWithKeyValue(key:String) -> NSArray{
    let ns = NSSortDescriptor.init(key: key, ascending: false)
    let aa = NSArray(object: ns)
    let arrResult = self.sortedArray(using: aa as! [NSSortDescriptor])
    return arrResult as NSArray
  }
}

