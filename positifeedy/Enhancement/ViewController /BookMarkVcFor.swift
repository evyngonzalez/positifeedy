
//
//  BookMarkVcFor.swift
//  positifeedy
//
//  Created by iMac on 08/05/21.
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
import LinkPresentation

class BookMarkVcFor: UIViewController {
        
    var IsSubscripted = false
    
    var textField : UITextField!
    var flagType : Int = 2
    var arrListOfJourny : NSMutableArray!
     var refreshControl = UIRefreshControl()
    @IBOutlet weak var SaveedView : UIView!
    @IBOutlet weak var Recentlyview : UIView!
    @IBOutlet weak var tableView : UITableView!
    
    @IBOutlet weak var btnSaved : UIButton!
    @IBOutlet weak var btnRecents : UIButton!
    
    var arrData : [Any] = []
    var arrRecentlyData : [Any] = []
    var arrRecently = NSMutableArray()
    var lblError : UILabel?
    var selectedTab: Int! = 0
    var arrFeeds  : [Feed]?
    var arrPositifeedyRecent = [PositifeedAllSet]()
    var arrBookMarkArrray = NSMutableArray()
    var arrPositifeedy = [PositifeedAllSet]()
    var isRefresh = false
    var myDocId : String?
    
    var isProfileImgLoad = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.dismiss()
        btnSaved.setTitleColor(.black, for: .normal)
        btnRecents.setTitleColor(.gray, for: .normal)
        
        tabBarController?.tabBar.isHidden = false
        Recentlyview.isHidden = true
        //myDocId = Auth.auth().currentUser?.uid
        let appDel =  UIApplication.shared.delegate as! AppDelegate
        myDocId = appDel.myDocID
        self.arrListOfJourny = NSMutableArray.init()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: "FeedCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.register(UINib(nibName: "FeedyCell", bundle: nil), forCellReuseIdentifier: "FeedyCell")
        tableView.register(UINib(nibName: "tblJournalCell", bundle: nil), forCellReuseIdentifier: "tblJournalCell")
        tableView.register(UINib(nibName: "FeedyCellUr", bundle: nil), forCellReuseIdentifier: "FeedyCellUr")
        tableView.register(UINib(nibName: "AdsTableViewNew", bundle: nil), forCellReuseIdentifier: "AdsTableViewNew")


        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        setNavBackground()
        setNavTitle(title : "positifeedy")
        cofigErroLable()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        setupGestures()
        
    }
    
    func setupGestures() {
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
            case .right:
                onclickforBookMark(btnSaved)
                break
            case .left:
                onclickRecentlyView(btnRecents)
                break
            default:
                break
            }
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
          // Code to refresh table view
           print("Refreshing")
           getPositifeedy()
           getRecentlyViews()
//           getBookmarsData()
//           getBookmarsDataFeedy()
           
           //getFeeds()
           //getPositifeedy()


       }
    func getRecentlyViews()
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
                    if (d["uid"] as! String) == Auth.auth().currentUser?.uid
                    {
                       
                      let arr = d["recentlyArray"] as? NSArray
                      if arr != nil
                      {
                          do {
                                            
                            let jsonData = try JSONSerialization.data(withJSONObject: arr as Any, options: .prettyPrinted)
                                let jsonDecoder = JSONDecoder()
                                let obj = try jsonDecoder.decode([PositifeedAllSet].self, from: jsonData)
                                //self.arrPositifeedyArticle = obj
              
                                self.arrPositifeedyRecent = obj.sorted(by: { (feed1, feed2) -> Bool in
                                    let date1 = Date(timeIntervalSince1970: Double(feed1.timestamp ?? "\(Date().timeIntervalSince1970)")!)
                                    let date2 = Date(timeIntervalSince1970: Double(feed2.timestamp ?? "\(Date().timeIntervalSince1970)")!)
                                    return date1 > date2
                                })
                            }
                            catch {
                                
                            }
                      }
                      else
                      {
                        self.arrPositifeedyRecent = [PositifeedAllSet]()
                      }
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        getPositifeedy()
        getRecentlyViews()
        getBookmarsData()
    }
    @IBAction func onclickforBookMark(_ sender: Any)
    {
        if(self.flagType != 2){
            SaveedView.isHidden = false
            Recentlyview.isHidden = true
            self.flagType = 2
            lblError?.text = "No bookmark available"
            
            btnSaved.setTitleColor(.black, for: .normal)
            btnRecents.setTitleColor(.gray, for: .normal)
            
            self.tableView.reloadData()
        }
        
    }
    
    @IBAction func onclickRecentlyView(_ sender: Any)
   {
        if(self.flagType != 1){
            SaveedView.isHidden = true
            Recentlyview.isHidden = false
            self.flagType = 1
         
             btnSaved.setTitleColor(.gray, for: .normal)
             btnRecents.setTitleColor(.black, for: .normal)
         
            self.tableView.reloadData()
         
        }
       
   }

    
    func getFeedsList()  {
        
        if !NetworkState.isConnected()
        {
            let alert = UIAlertController(title: Utilities.appName(), message: "Internet not connected", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        if self.isRefresh == false {
         SVProgressHUD.show()
        }
        
        AF.request(Global.feedURL).responseDecodable(of: FeedResponse.self)  { (response) in
            
            //SVProgressHUD.dismiss()
            print("response :\(response)")
            SVProgressHUD.dismiss()
            self.refreshControl.endRefreshing()
            switch response.result
            {
            case .success(let feedResponse) :

                if (feedResponse.ok ?? false)
                {
                     self.arrFeeds = feedResponse.info.arrFeedData ?? []
                    self.getFeeds()
                }
                
            case .failure(let error) :
                print(error)
            }
            
        }
    }
    func getFeeds() {
        
        arrData.removeAll()
        print(arrBookMarkArrray);
        
        var sortedBookmark = NSArray()
        
        sortedBookmark = arrBookMarkArrray.sorted { (data1, data2) -> Bool in

            var t1 = ""
            var t2 = ""
            
            if let dict1 = data1 as? NSDictionary{
                t1 = dict1.value(forKey: "timestamp") as? String ?? "0"
            }
            if let dict2 = data2 as? NSDictionary{
                t2 = dict2.value(forKey: "timestamp") as? String ?? "0"
            }
            
            let date1 = Date(timeIntervalSince1970: Double(t1)!)
            let date2 = Date(timeIntervalSince1970: Double(t2)!)
            return date1 > date2
        } as! NSArray
        
        
        print(sortedBookmark)
        
        
        
        
        if arrFeeds != nil
        {
            let appDel =  UIApplication.shared.delegate as! AppDelegate
            
            var tempBookMark = [Feed]()
            
            for link in appDel.arrBookMarkLink
            {
                tempBookMark.append(contentsOf:  (arrFeeds?.filter { $0.link == link})! )
            }
            
            arrData.append(contentsOf: tempBookMark)
            
        }
        if arrPositifeedy.count > 0
        {
            let appDel =  UIApplication.shared.delegate as! AppDelegate
            
            var tempBookMark = [PositifeedAllSet]()
            
            for link in appDel.arrBookMarkLinkFeedy
            {
                tempBookMark.append(contentsOf: (arrPositifeedy.filter { $0.documentID == link}) )
            }
            
            arrData.append(contentsOf: tempBookMark)
            
        }
        
        let arr = arrData.sorted { (data1, data2) -> Bool in

            var t1 = ""
            var t2 = ""
            
            if let feed = data1 as? Feed{
//                t1 = "\(feed.timestamp ?? 0)"
                for item in sortedBookmark {
                    let data = item as? NSDictionary ?? NSDictionary()
                    let link = data.value(forKey: "link") as? String ?? ""
//                    let documentId = data.value(forKey: "feed") as? String ?? ""
                    if(link == feed.link){
                        let timestamp = data.value(forKey: "timestamp") as? String ?? "0"
                        t1 = timestamp
                        break
                    }
                }
            }else{
                if let feed = data1 as? PositifeedAllSet{
//                    t1 = feed.timestamp ?? "0"
                    for item in sortedBookmark {
                        let data = item as? NSDictionary ?? NSDictionary()
//                        let link = data.value(forKey: "link") as? String ?? ""
                        let documentId = data.value(forKey: "feed") as? String ?? ""
                        if(documentId == feed.documentID){
                            let timestamp = data.value(forKey: "timestamp") as? String ?? "0"
                            t1 = timestamp
                            break
                        }
                    }
                }
            }
            
            if let feed = data2 as? Feed{
//                t1 = "\(feed.timestamp ?? 0)"
                for item in sortedBookmark {
                    let data = item as? NSDictionary ?? NSDictionary()
                    let link = data.value(forKey: "link") as? String ?? ""
//                    let documentId = data.value(forKey: "feed") as? String ?? ""
                    if(link == feed.link){
                        let timestamp = data.value(forKey: "timestamp") as? String ?? "0"
                        t2 = timestamp
                        break
                    }
                }
            }else{
                if let feed = data2 as? PositifeedAllSet{
//                    t1 = feed.timestamp ?? "0"
                    for item in sortedBookmark {
                        let data = item as? NSDictionary ?? NSDictionary()
//                        let link = data.value(forKey: "link") as? String ?? ""
                        let documentId = data.value(forKey: "feed") as? String ?? ""
                        if(documentId == feed.documentID){
                            let timestamp = data.value(forKey: "timestamp") as? String ?? "0"
                            t2 = timestamp
                            break
                        }
                    }
                }
            }
            
            let date1 = Date(timeIntervalSince1970: Double(t1)!)
            let date2 = Date(timeIntervalSince1970: Double(t2)!)
            return date1 > date2
        }
        
        arrData = arr
//        arrData.reverse()

        self.tableView.reloadData()
     
    }
    
    var arrTempararyArray: NSMutableArray!

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
                      var arrData = arr.map { (snap) -> [String: Any] in
                          var dict = snap.data()
                          dict["documentID"] = snap.documentID
                          return dict
                      }
                      
                      do {
                          
                        self.arrTempararyArray = NSMutableArray.init(array: arrData)
                        print("array :\(self.arrTempararyArray)")
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: self.arrTempararyArray, options: .prettyPrinted)
                        let jsonDecoder = JSONDecoder()
                        let obj = try jsonDecoder.decode([PositifeedAllSet].self, from: jsonData)
                        //self.arrPositifeedyArticle = obj
                        
                        self.arrPositifeedy = obj.sorted(by: { (feed1, feed2) -> Bool in
                            let date1 = Date(timeIntervalSince1970: Double(feed1.timestamp ?? "\(Date().timeIntervalSince1970)")!)
                            let date2 = Date(timeIntervalSince1970: Double(feed2.timestamp ?? "\(Date().timeIntervalSince1970)")!)
                            return date1 > date2
                        })
                        
                        self.getFeedsList()
                        
    //                      let jsonData = try JSONSerialization.data(withJSONObject: arrData, options: .prettyPrinted)
    //                      let jsonDecoder = JSONDecoder()
    //                      let obj = try jsonDecoder.decode([PositifeedAllSet].self, from: jsonData)
    //                      self.arrPositifeedy = obj.sorted(by: { (feed1, feed2) -> Bool in
    //                          let date1 = Date(timeIntervalSince1970: Double(feed1.timestamp ?? "\(Date().timeIntervalSince1970)")!)
    //                          let date2 = Date(timeIntervalSince1970: Double(feed2.timestamp ?? "\(Date().timeIntervalSince1970)")!)
    //                          return date1 > date2
    //                      })
                          
                      }
                      catch {
                          
                      }
                      //self.tableView.reloadData()
                  }
              }
          }
    
    func cofigErroLable()  {
        lblError = UILabel(frame: .zero)
        //lblError?.text = "Not bookmark available"
        lblError?.text = "Not bookmark available"
        tableView.backgroundView = UIView()
        tableView.backgroundView?.addSubview(lblError!)
        
        
        lblError?.textColor = .gray
        lblError?.font = UIFont(name: Global.Font.regular, size: 16)
        lblError?.translatesAutoresizingMaskIntoConstraints = false
        lblError?.isHidden = true
        
        let centerX =  NSLayoutConstraint(item: lblError as Any, attribute: .centerX, relatedBy: .equal, toItem: tableView.backgroundView, attribute: .centerX, multiplier: 1, constant: 0)
        
        
        let centerY =  NSLayoutConstraint(item: lblError as Any, attribute: .centerY, relatedBy: .equal, toItem: tableView.backgroundView, attribute: .centerY, multiplier: 1, constant: 0)
        
        
        tableView.backgroundView?.addConstraints([centerX, centerY])
    }
    
    
    @objc func btnUnsaveClick(sender : UIButton)
//    {
//            let appDel = UIApplication.shared.delegate as! AppDelegate
//        var db: Firestore!
//            db = Firestore.firestore()
//              let feed = self.arrPositifeedyRecent[sender.tag]
//
//              if feed.description_d != nil {
//
//
//                                          let link = feed.link
//
//                                    if let index = appDel.arrBookMarkLink.firstIndex(of: link!) {
//                                        appDel.arrBookMarkLink.remove(at: index)
//                                    }
//
//                                    let d = ["links" : appDel.arrBookMarkLink]
//                                    db.collection("users").document(myDocId!).updateData(d) { (error) in
//                                        if error != nil
//                                        {
//                                            print(error!.localizedDescription)
//                                        }
//                                    }
//
//                                  let timestamp = Date().currentTimeMillis()
//                                 let searchPredicate = NSPredicate(format: "link beginswith[C] %@",feed.link!)
//                                  let  arrrDict = self.arrRecently.filter { searchPredicate.evaluate(with: $0) };
//                                  let filterArray = NSMutableArray.init(array: arrrDict)
//                                  if(filterArray.count > 0)
//                                  {
//                                          // alerady exitst
//                                      let dict = filterArray.object(at: 0) as? NSDictionary
//                                      // alerady exitst
//                                      self.arrRecently.remove(dict)
//
//                                      let d2 = ["recentlyArray" : self.arrRecently]
//                                      db.collection("users").document(myDocId!).updateData(d2) { (error) in
//                                          if error != nil
//                                          {
//                                              print(error!.localizedDescription)
//                                          }
//                                      }
//
//                                  }
//                                  else
//                                  {
//                                      // not exist
//                  //                    let mutabledict = NSMutableDictionary.init()
//                  //                    mutabledict.setValue(arrPositifeedy[sender.tag].documentID!, forKey: "link")
//                  //                    mutabledict.setValue("\(timestamp)", forKey: "timestamp")
//                  //                    self.arrBookMarkArrray.add(mutabledict)
//                  //
//                  //                    let d2 = ["bookmarkarray" : "\(self.arrBookMarkArrray)"]
//                  //                     db.collection("users").document(myDocID!).updateData(d2) { (error) in
//                  //                         if error != nil
//                  //                         {
//                  //                             print(error!.localizedDescription)
//                  //                         }
//                  //                     }
//                                  }
//
//
//              }else
//              {
//                    let link = arrPositifeedyRecent[sender.tag].documentID
//
//                                    if let index = appDel.arrBookMarkLinkFeedy.firstIndex(of: link!) {
//                                        appDel.arrBookMarkLinkFeedy.remove(at: index)
//                                    }
//
//                                    let d = ["linksFeedy" : appDel.arrBookMarkLinkFeedy]
//                                    db.collection("users").document(myDocId!).updateData(d) { (error) in
//                                        if error != nil
//                                        {
//                                            print(error!.localizedDescription)
//                                        }
//                                    }
//
//
//                                          let timestamp = Date().currentTimeMillis()
//                                          let searchPredicate = NSPredicate(format: "feed beginswith[C] %@",arrPositifeedy[sender.tag].documentID!)
//                                          let  arrrDict = self.arrRecently.filter { searchPredicate.evaluate(with: $0) };
//                                          let filterArray = NSMutableArray.init(array: arrrDict)
//                                          if(filterArray.count > 0)
//                                          {
//                                              let dict = filterArray.object(at: 0) as? NSDictionary
//                                              // alerady exitst
//                                              self.arrRecently.remove(dict)
//
//                                              let d2 = ["recentlyArray" : self.arrRecently]
//                                              db.collection("users").document(myDocId!).updateData(d2) { (error) in
//                                                  if error != nil
//                                                  {
//                                                      print(error!.localizedDescription)
//                                                  }
//                                              }
//                                          }
//                                          else
//                                          {
//                  //                            // not exist
//                  //                            let mutabledict = NSMutableDictionary.init()
//                  //                            mutabledict.setValue(arrPositifeedy[sender.tag].documentID!, forKey: "feed")
//                  //                            mutabledict.setValue("\(timestamp)", forKey: "timestamp")
//                  //                            self.arrBookMarkArrray.add(mutabledict)
//                  //
//                  //                            let d2 = ["bookmarkarray" : "\(self.arrBookMarkArrray)"]
//                  //                             db.collection("users").document(myDocID!).updateData(d2) { (error) in
//                  //                                 if error != nil
//                  //                                 {
//                  //                                     print(error!.localizedDescription)
//                  //                                 }
//                  //                             }
//                                          }
//
//              }
//
//
//    }
    {
        
           // let appDel = UIApplication.shared.delegate as! AppDelegate
            //      let context = appDel.persistentContainer.viewContext
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let index = sender.tag
        self.arrPositifeedyRecent.remove(at: index)
        let arr = NSMutableArray()
        
        for item in arrPositifeedyRecent {
            let mutabledict = NSMutableDictionary.init()
            mutabledict.addEntries(from: item.toDictionary())
            arr.add(mutabledict)
        }
        
        let data = ["recentlyArray": arr]
        var db: Firestore!
        db = Firestore.firestore()
        db.collection("users").document(myDocId!).updateData(data) { (error) in
            if error != nil
            {
                print(error!.localizedDescription)
            }
        }
                
            tableView.reloadData()
        
    }
    
    
    @objc func btnBookMarkRemoveClick(sender : UIButton)  {
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
        if let obj = arrData[sender.tag] as? Feed {
            let feed = obj.link
            
            arrData.remove(at: sender.tag)
            
            let timestamp = Date().currentTimeMillis()
            let searchPredicate = NSPredicate(format: "link beginswith[C] %@",obj.link!)
            let  arrrDict = self.arrBookMarkArrray.filter { searchPredicate.evaluate(with: $0) };
            let filterArray = NSMutableArray.init(array: arrrDict)
            if(filterArray.count > 0)
            {
                // alerady exitst
                let dict = filterArray.object(at: 0) as? NSDictionary
                // alerady exitst
                self.arrBookMarkArrray.remove(dict)
                
                let d2 = ["bookmarkarray" : self.arrBookMarkArrray]
                
                var db: Firestore!
                db = Firestore.firestore()
                db.collection("users").document(myDocId!).updateData(d2) { (error) in
                    if error != nil
                    {
                        print(error!.localizedDescription)
                    }
                }
                
            }
            
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
                                
            }
        } else {
            let feed = (arrData[sender.tag] as! PositifeedAllSet).documentID
            
            arrData.remove(at: sender.tag)
            
            if let index = appDel.arrBookMarkLinkFeedy.firstIndex(of: feed!)
            {

                let timestamp = Date().currentTimeMillis()
                let searchPredicate = NSPredicate(format: "feed beginswith[C] %@",feed!)
                let  arrrDict = self.arrBookMarkArrray.filter { searchPredicate.evaluate(with: $0) };
                let filterArray = NSMutableArray.init(array: arrrDict)
                if(filterArray.count > 0)
                {
                    let dict = filterArray.object(at: 0) as? NSDictionary
                    // alerady exitst
                    self.arrBookMarkArrray.remove(dict)
                    
                    let d2 = ["bookmarkarray" : self.arrBookMarkArrray]
                    var db: Firestore!
                    db = Firestore.firestore()
                    db.collection("users").document(myDocId!).updateData(d2) { (error) in
                        if error != nil
                        {
                            print(error!.localizedDescription)
                        }
                    }
                }
                
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
            }
        }
        
        tableView.reloadData()
    }

    func getBookmarsData()
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
                    if (d["uid"] as! String) == Auth.auth().currentUser?.uid
                    {
                        let appDel = UIApplication.shared.delegate as! AppDelegate
                        
                        if let links = (d["links"] as? [String])
                        {
                            appDel.arrBookMarkLink = links
                        }

                      let arr = d["bookmarkarray"] as? NSArray
                      if arr != nil
                      {
                          self.arrBookMarkArrray = NSMutableArray.init(array: arr!)
                        
                      }
                      else
                      {
                          self.arrBookMarkArrray = NSMutableArray.init()
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
                      self.tableView.reloadData()
                      
                    }
                }
            }
        }
    }
}

//DataSource
extension BookMarkVcFor : UITableViewDataSource
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.flagType == 1
        {
            if(arrPositifeedyRecent.count > 0 ){
                lblError?.text = ""
            }else{
                lblError?.text = "No Items in Recent"
            }
            var adsNumber = (arrPositifeedyRecent.count / 5)
            if(IsSubscripted){
                adsNumber = 0
            }
            return arrPositifeedyRecent.count + adsNumber
            
        }else
        {
            
            lblError?.isHidden = arrData.count == 0  ? false : true
            var adsNumber = (arrData.count / 5)
            if(IsSubscripted){
                adsNumber = 0
            }
            return arrData.count + adsNumber
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if flagType == 1 {
            
            var shownAds = (indexPath.row / 5)
            if(IsSubscripted){
                shownAds = 0
            }
            let newIndexPath = IndexPath(row: indexPath.row - shownAds, section: 0)
            if(indexPath.row != 0 && indexPath.row % 5 == 0 && !IsSubscripted){
                let cell = tableView.dequeueReusableCell(withIdentifier: "AdsTableViewNew", for: indexPath) as! AdsTableViewNew
                cell.controller = self
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "FeedyCellUr", for: newIndexPath) as! FeedyCellUr
                cell.btnBookmark.removeTarget(nil, action: nil, for: .touchUpInside)
                
                let feed = arrPositifeedyRecent[newIndexPath.row]
                
                if feed.description_d != nil
                {
                    
                    cell.viewlink.isHidden = true
                    if let date =  feed.time?.toDate() {
                        cell.lblreadtime.text  = date.getElapsedInterval((feed.time?.getTimeZone())!)
                    } else {
                        cell.lblreadtime.text  = ""
                    }
                    //cell.btnShare.tag = indexPath.row
                    //cell.btnShare.addTarget(self, action: #selector(btnShareClickFeed), for: .touchUpInside)
                    
                    cell.btnplay.isHidden = true
                    cell.lblTitle.text = feed.title
                    cell.lblminidiscription.text = feed.description_d
                    
                    cell.btnShare.tag = newIndexPath.row
                    cell.btnShare.addTarget(self, action: #selector(btnShareClickFeed), for: .touchUpInside)
                    
                    //                   cell.btnBookmark.setImage(UIImage(named: "book_mark_ic"), for: .normal)
                    //                   cell.btnBookmark.setImage(UIImage(named: "bookmarkSelected"), for: .selected)
                    cell.btnBookmark.tag = newIndexPath.row
                    cell.btnBookmark.isSelected = isBookMark(link: feed.link!,desc: feed.description_d!)
                    
                    if(isBookMark(link: feed.link!,desc: feed.description_d!)){
                        cell.imgBookmark.image = UIImage(named: "unsave_ic")
                    }else{
                        cell.imgBookmark.image = UIImage(named: "unsave_ic")
                    }
                    
                    cell.btnBookmark.addTarget(self, action: #selector(btnUnsaveClick), for: .touchUpInside)
                    cell.img.cornerRadius(10)
                    
                    cell.img.image = nil
                    cell.img.sd_imageIndicator = SDWebImageActivityIndicator.gray
                    cell.img.sd_imageIndicator?.startAnimatingIndicator()
                    
                    DispatchQueue.main.async {[weak self] in
                        
                        if #available(iOS 13.0, *) {
                            
                            if feed.link != nil
                            {
                                if let link = URL(string: feed.link!)
                                {
                                    var provider = LPMetadataProvider()
                                    
                                    provider = LPMetadataProvider()
                                    provider.timeout =  100
                                    
                                    if let existingMetadata = MetadataCache.retrieve(urlString: link.absoluteString) {
                                        let metadata = existingMetadata
                                        if let imageProvider = metadata.imageProvider {
                                            metadata.iconProvider = imageProvider
                                            
                                            imageProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                                                guard error == nil else {
                                                    // handle error
                                                    return
                                                }
                                                
                                                DispatchQueue.main.async { [weak self] in
                                                    if let image = image as? UIImage {
                                                        cell.img.image = image
                                                    } else {
                                                        cell.img.image = nil
                                                    }
                                                    cell.img.sd_imageIndicator = nil
                                                    //                                                    cell.img.sd_imageIndicator?.startAnimatingIndicator()
                                                }
                                            }
                                        }
                                    } else {
                                        provider.startFetchingMetadata(for: link) { [weak self] metadata, error in
                                            guard let self = self else { return }
                                            
                                            guard let metadata = metadata, error == nil else {
                                                return
                                            }
                                            
                                            // 3. And cache the new metadata once you have it
                                            if let imageProvider = metadata.imageProvider {
                                                metadata.iconProvider = imageProvider
                                                imageProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                                                    guard error == nil else {
                                                        // handle error
                                                        return
                                                    }
                                                    
                                                    DispatchQueue.main.async { [weak self] in
                                                        if let image = image as? UIImage {
                                                            cell.img.image = image
                                                        } else {
                                                            cell.img.image = nil
                                                        }
                                                        cell.img.sd_imageIndicator = nil
                                                    }
                                                }
                                            }
                                            MetadataCache.cache(metadata: metadata)
                                        }
                                    }
                                }
                            }
                        }else{
                            cell.img.sd_imageIndicator = nil
                            cell.img.image = UIImage(named: "vlogo")
                        }
                    }
                    
                }else
                {
                    cell.bindData(feed: feed)
                    
                    cell.btnBookmark.tag = newIndexPath.row
    //                cell.btnBookmark.isSelected = isBookMark(link: feed.feed_url!,desc: "")
                    
    //                if(isBookMark(link: feed.feed_url!,desc: "")){
    //                    cell.imgBookmark.image = UIImage(named: "cancel")
    //                }else{
    //                    cell.imgBookmark.image = UIImage(named: "cancel")
    //                }
                    cell.imgBookmark.image = UIImage(named: "unsave_ic")
                    cell.btnBookmark.setImage( UIImage(named: "share"), for: .selected)
                    cell.btnBookmark.isSelected = true
                    cell.btnBookmark.addTarget(self, action: #selector(btnUnsaveClick), for: .touchUpInside)
                    
                    cell.btnShare.tag = newIndexPath.row
                    cell.btnShare.addTarget(self, action: #selector(btnShareClick), for: .touchUpInside)
                    
                    cell.btnplay.tag = newIndexPath.row
                    cell.btnplay.addTarget(self, action: #selector(btnPlayTapped(_:)), for: .touchUpInside)
                }
                if(feed.link != nil){
                    if let link = URL(string: feed.link!){
                        cell.lblminidiscription.text = link.domain ?? "Positifeedy"
                        
                        if Images(rawValue: (link.domain)!)!.image != nil
                        {
                            if let img = Images(rawValue: (link.domain)!)!.image
                            {
                                print("img :\(img)")
                                cell.imgminilogo.image = UIImage(named: img)
                            }
                            else
                            {
                                cell.imgminilogo.image = UIImage(named: "vlogo")
                            }
                        }
                    }
                    
                }
                cell.selectionStyle = .none
                return cell
            }
            
        }
        else
        {
            
            var shownAds = (indexPath.row / 5)
            if(IsSubscripted){
                shownAds = 0
            }
            let newIndexPath = IndexPath(row: indexPath.row - shownAds, section: 0)
            
            if(indexPath.row != 0 && indexPath.row % 5 == 0 && !IsSubscripted){
                let cell = tableView.dequeueReusableCell(withIdentifier: "AdsTableViewNew", for: indexPath) as! AdsTableViewNew
                cell.controller = self
                return cell
            }else{
                
                if let feed = arrData[newIndexPath.row] as? Feed {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: newIndexPath) as! FeedCell
                    cell.btnBookMark.removeTarget(nil, action: nil, for: .touchUpInside)
                    
                    let date = feed.time?.toDate()
                    
                    cell.btnPlay.isHidden = true
                    
                    cell.lblTitle.text = feed.title ?? "Positifeedy"
                    cell.lblDesc.text = feed.desc ?? "PositiFeedy"
                    cell.lblTime.text  = date!.getElapsedInterval((feed.time?.getTimeZone())!)
                    
    //                cell.btnBookMark.setImage(UIImage(named: "unsave_ic"), for: .normal)
                    cell.imgBookmark.image = UIImage(named: "unsave_ic")
                    
                    cell.btnBookMark.tag = newIndexPath.row
    //                cell.btnShare.addTarget(self, action: #selector(btnShareClickFeed(_:)), for: .touchUpInside)
                    cell.btnBookMark.addTarget(self, action: #selector(btnBookMarkRemoveClick), for: .touchUpInside)
                    cell.btnShare.tag = newIndexPath.row
                    cell.btnShare.addTarget(self, action: #selector(btnShareClickFeed(_:)), for: .touchUpInside)
                    cell.imgView.cornerRadius(10)
                    
                    DispatchQueue.main.async {[weak self] in
                        
                        if #available(iOS 13.0, *) {
                            
                            if feed.link != nil
                            {
                                if let link = URL(string: feed.link!)
                                {
                                    var provider = LPMetadataProvider()
                                    
                                    provider = LPMetadataProvider()
                                    provider.timeout =  100
                                    
                                    if let existingMetadata = MetadataCache.retrieve(urlString: link.absoluteString) {
                                        let metadata = existingMetadata
                                        if let imageProvider = metadata.imageProvider {
                                            metadata.iconProvider = imageProvider
                                            
                                            imageProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                                                guard error == nil else {
                                                    // handle error
                                                    return
                                                }
                                                
                                                DispatchQueue.main.async { [weak self] in
                                                    if let image = image as? UIImage {
                                                        cell.imgView.image = image
                                                    } else {
                                                        cell.imgView.image = nil
                                                    }
                                                    cell.imgView.sd_imageIndicator = nil
                                                    //                                                    cell.img.sd_imageIndicator?.startAnimatingIndicator()
                                                }
                                            }
                                        }
                                    } else {
                                        provider.startFetchingMetadata(for: link) { [weak self] metadata, error in
                                            guard let self = self else { return }
                                            
                                            guard let metadata = metadata, error == nil else {
                                                return
                                            }
                                            
                                            // 3. And cache the new metadata once you have it
                                            if let imageProvider = metadata.imageProvider {
                                                metadata.iconProvider = imageProvider
                                                imageProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                                                    guard error == nil else {
                                                        // handle error
                                                        return
                                                    }
                                                    
                                                    DispatchQueue.main.async { [weak self] in
                                                        if let image = image as? UIImage {
                                                            cell.imgView.image = image
                                                        } else {
                                                            cell.imgView.image = nil
                                                        }
                                                        cell.imgView.sd_imageIndicator = nil
                                                        //                                                    cell.img.sd_imageIndicator?.startAnimatingIndicator()
                                                    }
                                                }
                                            }
                                            MetadataCache.cache(metadata: metadata)
                                        }
                                    }
                                }
                            }
                        }else{
                            cell.imgView.sd_imageIndicator = nil
                            cell.imgView.image = UIImage(named: "vlogo")
                        }
                    }
                    if(feed.link != nil){
                        if let link = URL(string: feed.link!){
                            cell.lblDesc.text = link.domain ?? "NA"
                            
                            if Images(rawValue: (link.domain)!)!.image != nil
                            {
                                 if let img = Images(rawValue: (link.domain)!)!.image
                                {
                                    print("img :\(img)")
                                    cell.imgminilogo.image = UIImage(named: img)
                                }
                                else
                                 {
                                    cell.imgminilogo.image = UIImage(named: "vlogo")
                                }
                            }
                        }
                        
                    }
                    
                    if let link = URL(string: feed.link!)
                    {
                        if let img = Images(rawValue: (link.domain)!)?.image
                        {
                            cell.imgminilogo.image = UIImage(named: img )
                        }
                    }
                    
                    //                cell.btnShare.isHidden = false
                    //                cell.btnShare.tag = indexPath.row
                    //                cell.btnShare.addTarget(self, action: #selector(btnShareFeed), for: .touchUpInside)
                    cell.selectionStyle = .none
                    return cell
                    
                }
            else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FeedyCellUr", for: newIndexPath) as! FeedyCellUr
                    cell.btnBookmark.removeTarget(nil, action: nil, for: .touchUpInside)
                
                    let feed = arrData[newIndexPath.row] as! PositifeedAllSet
                    
                    if feed.description_d != nil
                    {

                        cell.viewlink.isHidden = true
                        let date =  feed.time?.toDate()
                        //cell.btnShare.tag = indexPath.row
                        //cell.btnShare.addTarget(self, action: #selector(btnShareClickFeed), for: .touchUpInside)
                        
                        cell.btnplay.isHidden = true
                        cell.lblTitle.text = feed.title
                        cell.lblminidiscription.text = feed.description_d
                        cell.lblreadtime.text  = date!.getElapsedInterval((feed.time?.getTimeZone())!)
    //                    cell.btnBookmark.setImage(UIImage(named: "unsave_ic"), for: .normal)
                        cell.btnShare.tag = newIndexPath.row
                        cell.btnBookmark.addTarget(self, action: #selector(btnBookMarkRemoveClick), for: .touchUpInside)
                      
    //                   cell.btnBookmark.setImage(UIImage(named: "book_mark_ic"), for: .normal)
    //                   cell.btnBookmark.setImage(UIImage(named: "bookmarkSelected"), for: .selected)
                       cell.btnBookmark.tag = newIndexPath.row
                       cell.btnBookmark.isSelected = isBookMark(link: feed.link!,desc: feed.description_d!)
                    
                        cell.imgBookmark.image = UIImage(named: "unsave_ic")

                        
    //                   cell.btnBookmark.addTarget(self, action: #selector(btnBookMarkRemoveClick), for: .touchUpInside)
                       cell.img.cornerRadius(10)
                      
                        cell.img.image = nil
                        cell.img.sd_imageIndicator = SDWebImageActivityIndicator.gray
                        cell.img.sd_imageIndicator?.startAnimatingIndicator()
                        
                        DispatchQueue.main.async {[weak self] in
                            
                            if #available(iOS 13.0, *) {
                                
                                if feed.link != nil
                                {
                                    if let link = URL(string: feed.link!)
                                    {
                                        var provider = LPMetadataProvider()
                                        
                                        provider = LPMetadataProvider()
                                        provider.timeout =  100
                                        
                                        if let existingMetadata = MetadataCache.retrieve(urlString: link.absoluteString) {
                                            let metadata = existingMetadata
                                            if let imageProvider = metadata.imageProvider {
                                                metadata.iconProvider = imageProvider
                                                
                                                imageProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                                                    guard error == nil else {
                                                        // handle error
                                                        return
                                                    }
                                                    
                                                    DispatchQueue.main.async { [weak self] in
                                                        if let image = image as? UIImage {
                                                            cell.img.image = image
                                                        } else {
                                                            cell.img.image = nil
                                                        }
                                                        cell.img.sd_imageIndicator = nil
                                                        //                                                    cell.img.sd_imageIndicator?.startAnimatingIndicator()
                                                    }
                                                }
                                            }
                                        } else {
                                            provider.startFetchingMetadata(for: link) { [weak self] metadata, error in
                                                guard let self = self else { return }
                                                
                                                guard let metadata = metadata, error == nil else {
                                                    return
                                                }
                                                
                                                // 3. And cache the new metadata once you have it
                                                if let imageProvider = metadata.imageProvider {
                                                    metadata.iconProvider = imageProvider
                                                    imageProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                                                        guard error == nil else {
                                                            // handle error
                                                            return
                                                        }
                                                        
                                                        DispatchQueue.main.async { [weak self] in
                                                            if let image = image as? UIImage {
                                                                cell.img.image = image
                                                            } else {
                                                                cell.img.image = nil
                                                            }
                                                            cell.img.sd_imageIndicator = nil
                                                            //                                                    cell.img.sd_imageIndicator?.startAnimatingIndicator()
                                                        }
                                                    }
                                                }
                                                MetadataCache.cache(metadata: metadata)
                                            }
                                        }
                                    }
                                }
                            }else{
                                cell.img.sd_imageIndicator = nil
                                cell.img.image = UIImage(named: "vlogo")
                            }
                        }
     
                    }else
                    {
                        cell.bindData(feed: feed)
                        
                        cell.btnBookmark.tag = newIndexPath.row
                        cell.btnBookmark.isSelected = isBookMark(link: feed.documentID!,desc: "")

                        cell.imgBookmark.image = UIImage(named: "unsave_ic")
    //                    cell.btnBookmark.tag = indexPath.row
    //                    cell.btnBookmark.isSelected = isBookMark(link: feed.documentID!,desc: "")
                        
                        cell.btnBookmark.addTarget(self, action: #selector(btnBookMarkRemoveClick), for: .touchUpInside)
                        
                        cell.btnShare.tag = newIndexPath.row
                        cell.btnShare.addTarget(self, action: #selector(btnShareClick), for: .touchUpInside)
                        
                        cell.btnplay.tag = newIndexPath.row
                        cell.btnplay.addTarget(self, action: #selector(btnPlayTapped(_:)), for: .touchUpInside)
                    }
                    
                    if(feed.link != nil){
                        if let link = URL(string: feed.link!){
                            cell.lblminidiscription.text = link.domain ?? "NA"
                            
                            if Images(rawValue: (link.domain)!)!.image != nil
                            {
                                 if let img = Images(rawValue: (link.domain)!)!.image
                                {
                                    print("img :\(img)")
                                    cell.imgminilogo.image = UIImage(named: img)
                                }
                                else
                                 {
                                    cell.imgminilogo.image = UIImage(named: "vlogo")
                                }
                            }
                        }
                        
                    }
                    cell.selectionStyle = .none
                    return cell

                }
            }
            
        }
    }
    
    @objc func btnShareClick(_ sender : UIButton) {
        
        SVProgressHUD.show()

        let positifeedy = arrPositifeedy[sender.tag]
        
      if positifeedy.documentID != nil
      {
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

    }
//    @objc func btnBookMarkClick(_ sender : UIButton) {
//
//         let appDel = UIApplication.shared.delegate as! AppDelegate
//         //      let context = appDel.persistentContainer.viewContext
//
//         var db: Firestore!
//         db = Firestore.firestore()
//
//         if sender.isSelected == false
//         {
//             sender.isSelected = true
//
//             if selectedTab == 0 {
//
//               let feed = arrPositifeedy[sender.tag]
//               if feed.description_d != nil
//               {
//                   appDel.arrBookMarkLink.append(feed.link!)
//                     let d = ["links" : appDel.arrBookMarkLink]
//                     db.collection("users").document(myDocId!).updateData(d) { (error) in
//                         if error != nil
//                         {
//                             print(error!.localizedDescription)
//                         }
//                     }
//
//                       let timestamp = Date().currentTimeMillis()
//                       let searchPredicate = NSPredicate(format: "link beginswith[C] %@",feed.link!)
//                       let  arrrDict = self.arrBookMarkArrray.filter { searchPredicate.evaluate(with: $0) };
//                       let filterArray = NSMutableArray.init(array: arrrDict)
//                       if(filterArray.count > 0)
//                       {
//                               // alerady exitst
//                       }
//                       else
//                       {
//                           // not exist
//                           let mutabledict = NSMutableDictionary.init()
//                           mutabledict.setValue(feed.link, forKey: "link")
//                           mutabledict.setValue("\(timestamp)", forKey: "timestamp")
//                           self.arrBookMarkArrray.add(mutabledict)
//
//                           let d2 = ["bookmarkarray" : self.arrBookMarkArrray]
//                            db.collection("users").document(myDocId!).updateData(d2) { (error) in
//                                if error != nil
//                                {
//                                    print(error!.localizedDescription)
//                                }
//                            }
//                       }
//
//               }else
//               {
//                   appDel.arrBookMarkLinkFeedy.append(arrPositifeedy[sender.tag].documentID!)
//                                   let d = ["linksFeedy" : appDel.arrBookMarkLinkFeedy]
//                                   db.collection("users").document(myDocId!).updateData(d) { (error) in
//                                       if error != nil
//                                       {
//                                           print(error!.localizedDescription)
//                                       }
//                                   }
//
//
//                                 let timestamp = Date().currentTimeMillis()
//                                 let searchPredicate = NSPredicate(format: "feed beginswith[C] %@",arrPositifeedy[sender.tag].documentID!)
//                                 let  arrrDict = self.arrBookMarkArrray.filter { searchPredicate.evaluate(with: $0) };
//                                 let filterArray = NSMutableArray.init(array: arrrDict)
//                                 if(filterArray.count > 0)
//                                 {
//                                         // alerady exitst
//                                 }
//                                 else
//                                 {
//                                     // not exist
//                                     let mutabledict = NSMutableDictionary.init()
//                                     mutabledict.setValue(arrPositifeedy[sender.tag].documentID!, forKey: "feed")
//                                     mutabledict.setValue("\(timestamp)", forKey: "timestamp")
//                                     self.arrBookMarkArrray.add(mutabledict)
//
//                                     let d2 = ["bookmarkarray" : self.arrBookMarkArrray]
//                                      db.collection("users").document(myDocId!).updateData(d2) { (error) in
//                                          if error != nil
//                                          {
//                                              print(error!.localizedDescription)
//                                          }
//                                      }
//                                 }
//
//               }
//
//
//
//
//             } else {
//
//
//             }
//
//         }
//         else
//         {
//             sender.isSelected = false
//
//             if selectedTab == 0 {
//
//               let feed = self.arrPositifeedy[sender.tag]
//
//               if feed.description_d != nil {
//
//
//                                           let link = feed.link
//
//                                     if let index = appDel.arrBookMarkLink.firstIndex(of: link!) {
//                                         appDel.arrBookMarkLink.remove(at: index)
//                                     }
//
//                                     let d = ["links" : appDel.arrBookMarkLink]
//                                     db.collection("users").document(myDocId!).updateData(d) { (error) in
//                                         if error != nil
//                                         {
//                                             print(error!.localizedDescription)
//                                         }
//                                     }
//
//                                   let timestamp = Date().currentTimeMillis()
//                                  let searchPredicate = NSPredicate(format: "link beginswith[C] %@",feed.link!)
//                                   let  arrrDict = self.arrBookMarkArrray.filter { searchPredicate.evaluate(with: $0) };
//                                   let filterArray = NSMutableArray.init(array: arrrDict)
//                                   if(filterArray.count > 0)
//                                   {
//                                           // alerady exitst
//                                       let dict = filterArray.object(at: 0) as? NSDictionary
//                                       // alerady exitst
//                                       self.arrBookMarkArrray.remove(dict)
//
//                                       let d2 = ["bookmarkarray" : self.arrBookMarkArrray]
//                                       db.collection("users").document(myDocId!).updateData(d2) { (error) in
//                                           if error != nil
//                                           {
//                                               print(error!.localizedDescription)
//                                           }
//                                       }
//
//                                   }
//                                   else
//                                   {
//                                       // not exist
//                   //                    let mutabledict = NSMutableDictionary.init()
//                   //                    mutabledict.setValue(arrPositifeedy[sender.tag].documentID!, forKey: "link")
//                   //                    mutabledict.setValue("\(timestamp)", forKey: "timestamp")
//                   //                    self.arrBookMarkArrray.add(mutabledict)
//                   //
//                   //                    let d2 = ["bookmarkarray" : "\(self.arrBookMarkArrray)"]
//                   //                     db.collection("users").document(myDocID!).updateData(d2) { (error) in
//                   //                         if error != nil
//                   //                         {
//                   //                             print(error!.localizedDescription)
//                   //                         }
//                   //                     }
//                                   }
//
//
//               }else
//               {
//                     let link = arrPositifeedy[sender.tag].documentID
//
//                                     if let index = appDel.arrBookMarkLinkFeedy.firstIndex(of: link!) {
//                                         appDel.arrBookMarkLinkFeedy.remove(at: index)
//                                     }
//
//                                     let d = ["linksFeedy" : appDel.arrBookMarkLinkFeedy]
//                                     db.collection("users").document(myDocId!).updateData(d) { (error) in
//                                         if error != nil
//                                         {
//                                             print(error!.localizedDescription)
//                                         }
//                                     }
//
//
//                                           let timestamp = Date().currentTimeMillis()
//                                           let searchPredicate = NSPredicate(format: "feed beginswith[C] %@",arrPositifeedy[sender.tag].documentID!)
//                                           let  arrrDict = self.arrBookMarkArrray.filter { searchPredicate.evaluate(with: $0) };
//                                           let filterArray = NSMutableArray.init(array: arrrDict)
//                                           if(filterArray.count > 0)
//                                           {
//                                               let dict = filterArray.object(at: 0) as? NSDictionary
//                                               // alerady exitst
//                                               self.arrBookMarkArrray.remove(dict)
//
//                                               let d2 = ["bookmarkarray" : self.arrBookMarkArrray]
//                                               db.collection("users").document(myDocId!).updateData(d2) { (error) in
//                                                   if error != nil
//                                                   {
//                                                       print(error!.localizedDescription)
//                                                   }
//                                               }
//                                           }
//                                           else
//                                           {
//                   //                            // not exist
//                   //                            let mutabledict = NSMutableDictionary.init()
//                   //                            mutabledict.setValue(arrPositifeedy[sender.tag].documentID!, forKey: "feed")
//                   //                            mutabledict.setValue("\(timestamp)", forKey: "timestamp")
//                   //                            self.arrBookMarkArrray.add(mutabledict)
//                   //
//                   //                            let d2 = ["bookmarkarray" : "\(self.arrBookMarkArrray)"]
//                   //                             db.collection("users").document(myDocID!).updateData(d2) { (error) in
//                   //                                 if error != nil
//                   //                                 {
//                   //                                     print(error!.localizedDescription)
//                   //                                 }
//                   //                             }
//                                           }
//
//               }
//
//
//             } else {
//
//
//
//             }
//
//         }
//         tableView.reloadData()
//    }
    @objc func btnBookMarkClick(_ sender : UIButton) {

        if flagType == 1 {
            let appDel = UIApplication.shared.delegate as! AppDelegate
            //      let context = appDel.persistentContainer.viewContext

            var db: Firestore!
            db = Firestore.firestore()

            if sender.isSelected == false
            {
               sender.isSelected = true

                   let feed = arrPositifeedyRecent[sender.tag]
                   if feed.description_d != nil
                   {
                       appDel.arrBookMarkLink.append(feed.link!)
                       let d = ["links" : appDel.arrBookMarkLink]
                       db.collection("users").document(self.myDocId!).updateData(d) { (error) in
                           if error != nil
                           {
                               print(error!.localizedDescription)
                           }
                       }

                       let timestamp = Date().currentTimeMillis()
                       let searchPredicate = NSPredicate(format: "link beginswith[C] %@",feed.link!)
                       let  arrrDict = self.arrBookMarkArrray.filter { searchPredicate.evaluate(with: $0) };
                    let filterArray = NSMutableArray.init(array: arrrDict ?? [])
                       if(filterArray.count > 0)
                       {
                           // alerady exitst
                       }
                       else
                       {
                           // not exist
                           let mutabledict = NSMutableDictionary.init()
                           mutabledict.setValue(feed.link, forKey: "link")
                           mutabledict.setValue("\(timestamp)", forKey: "timestamp")
                           self.arrBookMarkArrray.add(mutabledict)

                           let d2 = ["bookmarkarray" : self.arrBookMarkArrray]
                           db.collection("users").document(myDocId!).updateData(d2) { (error) in
                               if error != nil
                               {
                                   print(error!.localizedDescription)
                               }
                           }
                       }

                   }else
                   {
                       appDel.arrBookMarkLinkFeedy.append(arrPositifeedy[sender.tag].documentID!)
                       let d = ["linksFeedy" : appDel.arrBookMarkLinkFeedy]
                       db.collection("users").document(myDocId!).updateData(d) { (error) in
                           if error != nil
                           {
                               print(error!.localizedDescription)
                           }
                       }


                       let timestamp = Date().currentTimeMillis()
                       let searchPredicate = NSPredicate(format: "feed beginswith[C] %@",arrPositifeedy[sender.tag].documentID!)
                       let  arrrDict = self.arrBookMarkArrray.filter { searchPredicate.evaluate(with: $0) };
                       let filterArray = NSMutableArray.init(array: arrrDict)
                       if(filterArray.count > 0)
                       {
                           // alerady exitst
                       }
                       else
                       {
                           // not exist
                           let mutabledict = NSMutableDictionary.init()
                           mutabledict.setValue(arrPositifeedy[sender.tag].documentID!, forKey: "feed")
                           mutabledict.setValue("\(timestamp)", forKey: "timestamp")
                           self.arrBookMarkArrray.add(mutabledict)

                           let d2 = ["bookmarkarray" : self.arrBookMarkArrray]
                           db.collection("users").document(myDocId!).updateData(d2) { (error) in
                               if error != nil
                               {
                                   print(error!.localizedDescription)
                               }
                           }
                       }

                   }




            }
            else
            {
                sender.isSelected = false
                    
                  let feed = self.arrPositifeedyRecent[sender.tag]

                   if feed.description_d != nil {


                       let link = feed.link

                       if let index = appDel.arrBookMarkLink.firstIndex(of: link!) {
                           appDel.arrBookMarkLink.remove(at: index)
                       }

                       let d = ["links" : appDel.arrBookMarkLink]
                       db.collection("users").document(myDocId!).updateData(d) { (error) in
                           if error != nil
                           {
                               print(error!.localizedDescription)
                           }
                       }

                       let timestamp = Date().currentTimeMillis()
                       let searchPredicate = NSPredicate(format: "link beginswith[C] %@",feed.link!)
                       let  arrrDict = self.arrBookMarkArrray.filter { searchPredicate.evaluate(with: $0) };
                       let filterArray = NSMutableArray.init(array: arrrDict)
                       if(filterArray.count > 0)
                       {
                           // alerady exitst
                           let dict = filterArray.object(at: 0) as? NSDictionary
                           // alerady exitst
                           self.arrBookMarkArrray.remove(dict)

                           let d2 = ["bookmarkarray" : self.arrBookMarkArrray]
                           db.collection("users").document(myDocId!).updateData(d2) { (error) in
                               if error != nil
                               {
                                   print(error!.localizedDescription)
                               }
                           }

                       }


                   }else
                  {
                        let link = arrPositifeedy[sender.tag].documentID

                                        if let index = appDel.arrBookMarkLinkFeedy.firstIndex(of: link!) {
                                            appDel.arrBookMarkLinkFeedy.remove(at: index)
                                        }

                                        let d = ["linksFeedy" : appDel.arrBookMarkLinkFeedy]
                                        db.collection("users").document(myDocId!).updateData(d) { (error) in
                                            if error != nil
                                            {
                                                print(error!.localizedDescription)
                                            }
                                        }


                                              let timestamp = Date().currentTimeMillis()
                                              let searchPredicate = NSPredicate(format: "feed beginswith[C] %@",arrPositifeedy[sender.tag].documentID!)
                                              let  arrrDict = self.arrBookMarkArrray.filter { searchPredicate.evaluate(with: $0) };
                                              let filterArray = NSMutableArray.init(array: arrrDict)
                                              if(filterArray.count > 0)
                                              {
                                                  let dict = filterArray.object(at: 0) as? NSDictionary
                                                  // alerady exitst
                                                  self.arrBookMarkArrray.remove(dict)

                                                  let d2 = ["bookmarkarray" : self.arrBookMarkArrray]
                                                  db.collection("users").document(myDocId!).updateData(d2) { (error) in
                                                      if error != nil
                                                      {
                                                          print(error!.localizedDescription)
                                                      }
                                                  }
                                              }

                  }



            }
            tableView.reloadData()
        } else {
                
        }

    }
    func isBookMark(link : String,desc: String) -> Bool
    {
          if desc != ""
          {
              let appDel = UIApplication.shared.delegate as! AppDelegate
               let ind = appDel.arrBookMarkLink.firstIndex(of: link) ?? -1
               if ind > -1
               {
                   return true
               }
              
          }
          else
          {
            let appDel = UIApplication.shared.delegate as! AppDelegate
            
            let ind = appDel.arrBookMarkLinkFeedy.firstIndex(of: link) ?? -1
            if ind > -1
            {
                return true
            }
          }
         
        
        return false
    }
    
    @objc func btnShareClickFeed(_ sender : UIButton) {
        
        if flagType == 1 {
            let feed = self.arrPositifeedyRecent[sender.tag]
            
            if feed.link != nil
            {
                
                var url : String = feed.link!
                
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
                
                
            }else
            {
                
            }
        }
        else
        {
            let ShareApp = [URL(fileURLWithPath:"https://www.apple.com/in/app-store")]
            let objectsToShare = ["Positifeedy \(ShareApp)", ShareApp] as [Any]
            let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                   activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
        
        
        
    }
//    @objc func btnShareClickFeed(_ sender : UIButton) {
//
//       let feed = self.arrPositifeedy[sender.tag]
//
//      if feed.feed_url != nil
//      {
//
//          var url : String = feed.feed_url!
//
//                       var components = URLComponents()
//                       components.scheme = "https"
//                       components.host = "positifeedy.page.link"
//                       components.path = "/share"
//
//                       let feedURL = URLQueryItem(name: "feedURL", value: url ?? "")
//                       components.queryItems = [feedURL]
//
//                       guard let linkParameter = components.url else {
//                           SVProgressHUD.dismiss()
//                           return
//                       }
//
//                       guard let shareLink = DynamicLinkComponents.init(link: linkParameter, domainURIPrefix: "https://positifeedy.page.link") else {
//                           SVProgressHUD.dismiss()
//                           return
//                       }
//
//                       if let myBundleId = Bundle.main.bundleIdentifier {
//                           shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleId)
//                       }
//
//                       shareLink.iOSParameters?.appStoreID = "1484015088"
//
//                       guard let longURL = shareLink.url else {
//                           SVProgressHUD.dismiss()
//                           return
//                       }
//
//                       shareLink.shorten { [weak self] (url, warnings, error) in
//                           SVProgressHUD.dismiss()
//                           if let error = error {
//                               self?.view.makeToast(error.localizedDescription)
//                               return
//                           }
//
//                           guard let url = url else { return }
//
//                           self?.showShareSheet(url: url)
//
//                       }
//
//
//      }
//    }
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
    

    func showShareSheet(url: URL) {
                    
                    let promoText = "Check out this feed"
                    let activityVC = UIActivityViewController(activityItems: [promoText, url], applicationActivities: nil)
                    self.present(activityVC, animated: true, completion: nil)
                }
    
    func playVideo(url: URL) {
        let player = AVPlayer(url: url)
        
        let vc = AVPlayerViewController()
        vc.player = player
        
        self.present(vc, animated: true) { vc.player?.play() }
    }
    
}
//Delegate
extension BookMarkVcFor : UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 5 == 0 && indexPath.row != 0 && !IsSubscripted && indexPath.row != 0
        {
            let pref_ad = UserDefaults.standard.object(forKey: PREF_AD_HEIGHT) as? String
            if pref_ad  != nil
            {
                if pref_ad == "1"
                {
                    return UITableView.automaticDimension
                    
                }else
                {
                    return 0
                }
            }
            else
            {
                return 0
            }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var shownAds = (indexPath.row / 5)
        if(IsSubscripted){
            shownAds = 0
        }
        let newIndexPath = IndexPath(row: indexPath.row - shownAds, section: 0)

        if self.flagType == 1
        {
            if var feed = arrPositifeedyRecent[newIndexPath.row] as? Feed {
                let webVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
                webVC.url = feed.link
                webVC.myDocID = self.myDocId
                webVC.isBookmark = isBookMark(link: feed.link!, desc: feed.desc!)
//                webVC.objPositifeedAllSet = fe?ed
                navigationController?.pushViewController(webVC, animated: true)
                
            } else if let feed = arrPositifeedyRecent[newIndexPath.row] as? PositifeedAllSet {
                
                let feed_type = feed.feed_type ?? ""
                if(feed.description_d != nil){
                    var link = feed.link!
                    let webVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
                    webVC.url = link
                    webVC.myDocID = self.myDocId
                    webVC.isBookmark = isBookMark(link: link,desc: feed.description_d!)
                    webVC.objPositifeedAllSet = feed
                    navigationController?.pushViewController(webVC, animated: true)

                }else{
                    if feed_type == "link" {
                        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewFeedy") as! WebViewFeedy
                        detailVC.myDocID = self.myDocId
                        if(feed.description_d != nil){
                            detailVC.isBookmark = isBookMark(link: feed.link!, desc: feed.description_d!)
                        }else{
                            detailVC.isBookmark = isBookMark(link: feed.documentID ?? "", desc: "")
                        }
                        
                        detailVC.positifeedy = feed
                        navigationController?.pushViewController(detailVC, animated: true)
                    } else {
                        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "PostDetailViewController") as! PostDetailViewController
                        detailVC.myDocID = self.myDocId
                        if(feed.description_d != nil){
                            detailVC.isBookmark = isBookMark(link: feed.link!, desc: feed.description_d!)
                        }else{
                            detailVC.isBookmark = isBookMark(link: feed.documentID!, desc: "")
                        }
                        detailVC.positifeedy = feed
                        navigationController?.pushViewController(detailVC, animated: true)
                    }
                }
                
            }
        }
        else
        {
            if var feed = arrData[newIndexPath.row] as? Feed {
                let webVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
                webVC.url = feed.link
                webVC.myDocID = self.myDocId
                webVC.isBookmark = true
                //webVC.objPositifeedAllSet = feed
                navigationController?.pushViewController(webVC, animated: true)
                
            } else if let feed = arrData[newIndexPath.row] as? PositifeedAllSet {
                
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
