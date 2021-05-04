//
//  welcomeViewController.swift
//  positifeedy
//
//  Created by Evyn Gonzalez  on 9/12/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//


//shidhdharthjoshi.weapplinse@gmail.com
//123456

import UIKit
import Alamofire
import Firebase
import CoreData
import SVProgressHUD
import GoogleMobileAds
import AVKit
import AVFoundation
import SDWebImage
import EMPageViewController
import LinkPresentation

class welcomeViewController: UIViewController
{
    
    @IBOutlet weak var segmentedControl: TTSegmentedControl!

    var arrTempararyArray: NSMutableArray!
    var arrBookMarkArrray : NSMutableArray!
    var greeting:String!
    var arrFeeds : [Feed] = []
    var arrPositifeedy = [PositifeedAllSet]()
    var arrPositifeedyArticle = [PositifeedAllSet]()
    var adsCount : Int = 0
    var refreshControl = UIRefreshControl()
    var isRefresh = false
    var myDocID : String?
    var ac : UIActivityIndicatorView!
    var selectedTab: Int! = 0
    
    @IBOutlet weak var tableView : UITableView!
    
    
    
    
    //var arrFeeds : [Feed] = []
    //var arrPositifeedy = [PositifeedAllSet]()
    
//    @IBOutlet var collectionView: UICollectionView!
//    @IBOutlet weak var heightCol: NSLayoutConstraint!

    //var myDocID : String?
    //var ac : UIActivityIndicatorView!

    
    @IBOutlet weak var pageview: UIView!
    
    //var selectedTab: Int = 0
    
    var pageViewController: EMPageViewController?
       
       var greetings: [String] = ["From us"]
       var greetingColors: [UIColor] = [
           UIColor(red: 108.0/255.0, green: 122.0/255.0, blue: 137.0/255.0, alpha: 1.0),
           UIColor(red: 135.0/255.0, green: 211.0/255.0, blue: 124.0/255.0, alpha: 1.0),
           UIColor(red: 34.0/255.0, green: 167.0/255.0, blue: 240.0/255.0, alpha: 1.0),
           UIColor(red: 245.0/255.0, green: 171.0/255.0, blue: 53.0/255.0, alpha: 1.0),
           UIColor(red: 214.0/255.0, green: 69.0/255.0, blue: 65.0/255.0, alpha: 1.0)
       ]

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
//        //setNavBackground()
//            // segment controller
//            segmentedControl.setDesignedBorder(radius: 20.0, width: 0)
//
//            segmentedControl.selectItemAt(index: 0, animated: false)
//            segmentedControl.itemTitles = ["From Us", "Articles"]
//            segmentedControl.defaultTextFont = UIFont.systemFont(ofSize: 16.0)
//            segmentedControl.selectedTextFont = UIFont.systemFont(ofSize: 16.0)
//            segmentedControl.thumbPadding = 3.0
//            segmentedControl.didSelectItemWith = { (index, title) in
//
//                if index == 0
//                {
//                    //self.viewController(at: 0)
//                    self.pageViewController!.scrollReverse(animated: true, completion: nil)
//                }
//                else
//                {
//                    //self.viewController(at: 1)
//                    self.pageViewController!.scrollForward(animated: true, completion: nil)
//                }
//            }
//        self.initalizePageView()
        
        
          tableView.rowHeight = UITableView.automaticDimension
          tableView.estimatedRowHeight = 200.0
          
          self.arrTempararyArray = NSMutableArray.init()
          self.arrBookMarkArrray = NSMutableArray.init()
          
          tableView.register(UINib(nibName: "FeedCell", bundle: nil), forCellReuseIdentifier: "cell")
          tableView.register(UINib(nibName: "FeedyCell", bundle: nil), forCellReuseIdentifier: "FeedyCell")
<<<<<<< Updated upstream
         tableView.register(UINib(nibName: "TblFeedTextCell", bundle: nil), forCellReuseIdentifier: "TblFeedTextCell")
=======
>>>>>>> Stashed changes

          tableView.register(UINib(nibName: "AdsTableViewCell", bundle: nil), forCellReuseIdentifier: "adsCell")
          
          tableView.tableFooterView = UIView()
          tableView.dataSource = self
          tableView.delegate = self
        
          //         UIApplication.shared.statusBarView?.backgroundColor = UIColor.green
          
          getBookmarsData()
          getBookmarsDataFeedy()
          
          //getFeeds()
<<<<<<< Updated upstream
          //getPositifeedy()
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
    
    }
    
    
    //MARK:- refresh
  @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        print("refresh")
        getPositifeedy()
      refreshControl.endRefreshing()
=======
          getPositifeedy()
        
>>>>>>> Stashed changes
    }
//
    
     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         
     }
    
//    //MARK:- init page :
//    func initalizePageView() -> Void {
//
//    // Instantiate EMPageViewController and set the data source and delegate to 'self'
//           let pageViewController = EMPageViewController()
//
//           // Or, for a vertical orientation
//           // let pageViewController = EMPageViewController(navigationOrientation: .Vertical)
//
//           pageViewController.dataSource = self
//           pageViewController.delegate = self
//
//
//
//           // Set the initially selected view controller
//           // IMPORTANT: If you are using a dataSource, make sure you set it BEFORE calling selectViewController:direction:animated:completion
//           let currentViewController = self.viewController(at: 0)!
//           pageViewController.selectViewController(currentViewController, direction: .forward, animated: false, completion: nil)
//           pageViewController.view.frame = CGRect.init(x: 0, y: 0, width: self.pageview.frame.size.width, height: self.pageview.frame.size.height)
//
//           // Add EMPageViewController to the root view controller
//           self.addChild(pageViewController)
//           self.pageview.addSubview(pageViewController.view)
//
//
//           //self.pageview.insertSubview(pageViewController.view, at: 0) // Insert the page controller view below the navigation buttons
//           pageViewController.didMove(toParent: self)
//
//           self.pageViewController = pageViewController
//    }
    
     
//    override func viewDidAppear(_ animated: Bool) {
//         super.viewDidAppear(animated)
//         tableView.reloadData()
//     }
//
     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         
     }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        setNavTitle(title : "positifeedy")
        self.getBookmarsDataOther()
<<<<<<< Updated upstream
        getPositifeedy()
=======
>>>>>>> Stashed changes
        self.navigationController?.navigationBar.isHidden = true
        

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
                          
                        
                        self.arrTempararyArray = NSMutableArray.init(array: arrData)
                        print("array :\(self.arrTempararyArray)")
                        
                        
                        self.getFeeds()
                        
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
          
       
        func getBookmarsDataOther()
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
                                
                               let arr = d["bookmarkarray"] as? NSArray
                               if arr != nil
                               {
                                   self.arrBookMarkArrray = NSMutableArray.init(array: arr!)
                               }
                               else
                               {
                                   self.arrBookMarkArrray = NSMutableArray.init()
                               }
                               
                             }
                         }
                     }
                 }
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

                              self.myDocID = doc.documentID
                              appDel.myDocID = doc.documentID
                              
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
                            
                            self.tableView.reloadData()
                            
                          }
                      }
                  }
              }
          }
          
          func getBookmarsDataFeedy()
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

                          self.myDocID = doc.documentID
                          appDel.myDocID = doc.documentID
                          
                          if let links = (d["linksFeedy"] as? [String])
                          {
                              appDel.arrBookMarkLinkFeedy = links
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
                        
                          self.tableView.reloadData()
                          }
                      }
                  }
              }
          }
          
        //MARK:- get article method :
        
          func getFeeds()  {
              
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
              
            AF.request(Global.feedURL, method: .get,  parameters: nil, encoding: JSONEncoding.default)
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        if let json = value as? [String: Any] {
                           
                            SVProgressHUD.dismiss()
                            
                            let result = json["result"] as? NSDictionary
                            if result!.count > 0
                            {
                                let entries = result?.value(forKey: "entries") as? NSArray
                                if entries!.count > 0
                                {
                                     
                                    let finalAr1 = NSMutableArray.init()
                                    
                                    let temp =  NSMutableArray.init(array: entries!)
                                    for i in (0..<temp.count)
                                    {
<<<<<<< Updated upstream
                                        
                                        let dict = temp.object(at: i) as? NSDictionary
                                        
=======
                                        let dict = temp.object(at: i) as? NSDictionary
>>>>>>> Stashed changes
                                        let mutable = NSMutableDictionary.init()
                                        mutable.setValue(String.init(format: "%@",(dict?.value(forKey: "description") as? CVarArg)!), forKey: "description_d")
                                        mutable.setValue(String.init(format: "%@",(dict?.value(forKey: "guid") as? CVarArg)!), forKey: "guid")
                                        mutable.setValue(String.init(format: "%@",(dict?.value(forKey: "link") as? CVarArg)!), forKey: "link")
                                        mutable.setValue(String.init(format: "%@",(dict?.value(forKey: "time") as? CVarArg)!), forKey: "time")
                                        mutable.setValue(String.init(format: "%@",(dict?.value(forKey: "timestamp") as? CVarArg)!), forKey: "timestamp")
                                        mutable.setValue(String.init(format: "%@",(dict?.value(forKey: "title") as? CVarArg)!), forKey: "title")
                                        self.arrTempararyArray.add(mutable)
                                        
                                            //                                    finalAr1.add(mutable)
                                    }
                                    
                                    if self.arrTempararyArray.count > 0
                                    {
                                       // self.arrTempararyArray = NSMutableArray.init(array: finalAr1)
                                        
                                        print("entries \(self.arrTempararyArray)")
                                          //  let finalArray = NSMutableArray.init(array: entries!)
                                               do {
                                                                  
                                                let jsonData = try JSONSerialization.data(withJSONObject: self.arrTempararyArray, options: .prettyPrinted)
                                                                  let jsonDecoder = JSONDecoder()
                                                                  let obj = try jsonDecoder.decode([PositifeedAllSet].self, from: jsonData)
                                                                  //self.arrPositifeedyArticle = obj
                                                
                                                                  self.arrPositifeedy = obj.sorted(by: { (feed1, feed2) -> Bool in
                                                                      let date1 = Date(timeIntervalSince1970: Double(feed1.timestamp ?? "\(Date().timeIntervalSince1970)")!)
                                                                      let date2 = Date(timeIntervalSince1970: Double(feed2.timestamp ?? "\(Date().timeIntervalSince1970)")!)
                                                                      return date1 > date2
                                                                  })
                                                  }
                                                  catch {
                                                      
                                                  }
                                                  print("Article  and  from -> both  :\(self.arrPositifeedy)")
                                                   if self.arrPositifeedy.count > 0
                                                   {
                                                       self.tableView.reloadData()
                                                   }
                                    }
                                }
                            }
                            
                        }
                    case .failure(let error):
                        print(error)
                    }
            }
            
            
           
            /*AF.request(Global.feedURL).responseDecodable(of: FeedResponse.self)  { (response) in
                  
                  SVProgressHUD.dismiss()
                   
                print("arr response :\(response)")
                  switch response.result
                  {
                  case .success(let feedResponse) :
                      if (feedResponse.ok ?? false)
                      {
                          self.arrFeeds = feedResponse.info.arrFeedData ?? []
                          print("arr feed :\(self.arrFeeds)")
                        
                          self.tableView.reloadData()
                          if self.isRefresh
                          {
                              self.refreshControl.endRefreshing()
                              self.isRefresh = false
                          }
                      }
                      
                  case .failure(let error) :
                      print(error)
                  }
                  
              } */
            
          }
              
          @objc func btnShareClickFeed(_ sender : UIButton) {
              
             let feed = self.arrPositifeedy[sender.tag]
            
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
<<<<<<< Updated upstream
                }
                
                guard let shareLink = DynamicLinkComponents.init(link: linkParameter, domainURIPrefix: "https://positifeedy.page.link") else {
                    SVProgressHUD.dismiss()
                    return
                }
                
                if let myBundleId = Bundle.main.bundleIdentifier {
                    shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleId)
                }
                
=======
                }
                
                guard let shareLink = DynamicLinkComponents.init(link: linkParameter, domainURIPrefix: "https://positifeedy.page.link") else {
                    SVProgressHUD.dismiss()
                    return
                }
                
                if let myBundleId = Bundle.main.bundleIdentifier {
                    shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleId)
                }
                
>>>>>>> Stashed changes
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
          
          func showShareSheet(url: URL) {
              
              let promoText = "Check out this feed"
              let activityVC = UIActivityViewController(activityItems: [promoText, url], applicationActivities: nil)
              self.present(activityVC, animated: true, completion: nil)
          }
          
          @objc func btnBookMarkClick(_ sender : UIButton) {
              
              let appDel = UIApplication.shared.delegate as! AppDelegate
              //      let context = appDel.persistentContainer.viewContext
              
              var db: Firestore!
              db = Firestore.firestore()
              
              if sender.isSelected == false
              {
                  sender.isSelected = true
                  
                  if selectedTab == 0 {
                    
                    let feed = arrPositifeedy[sender.tag]
                    if feed.description_d != nil
                    {
                        appDel.arrBookMarkLink.append(feed.link!)
                          let d = ["links" : appDel.arrBookMarkLink]
                          db.collection("users").document(myDocID!).updateData(d) { (error) in
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
                            }
                            else
                            {
                                // not exist
                                let mutabledict = NSMutableDictionary.init()
                                mutabledict.setValue(feed.link, forKey: "link")
                                mutabledict.setValue("\(timestamp)", forKey: "timestamp")
                                self.arrBookMarkArrray.add(mutabledict)
                               
                                let d2 = ["bookmarkarray" : self.arrBookMarkArrray]
                                 db.collection("users").document(myDocID!).updateData(d2) { (error) in
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
                                        db.collection("users").document(myDocID!).updateData(d) { (error) in
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
                                           db.collection("users").document(myDocID!).updateData(d2) { (error) in
                                               if error != nil
                                               {
                                                   print(error!.localizedDescription)
                                               }
                                           }
                                      }
                        
                    }
                    
                    
                    
                    
                  } else {
                      
                                   
                  }
                  
              }
              else
              {
                  sender.isSelected = false
                  
                  if selectedTab == 0 {
                    
                    let feed = self.arrPositifeedy[sender.tag]
                    
                    if feed.description_d != nil {
                        

                                                let link = feed.link
                                          
                                          if let index = appDel.arrBookMarkLink.firstIndex(of: link!) {
                                              appDel.arrBookMarkLink.remove(at: index)
                                          }
                                          
                                          let d = ["links" : appDel.arrBookMarkLink]
                                          db.collection("users").document(myDocID!).updateData(d) { (error) in
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
                                            db.collection("users").document(myDocID!).updateData(d2) { (error) in
                                                if error != nil
                                                {
                                                    print(error!.localizedDescription)
                                                }
                                            }
                                            
                                        }
                                        else
                                        {
                                            // not exist
                        //                    let mutabledict = NSMutableDictionary.init()
                        //                    mutabledict.setValue(arrPositifeedy[sender.tag].documentID!, forKey: "link")
                        //                    mutabledict.setValue("\(timestamp)", forKey: "timestamp")
                        //                    self.arrBookMarkArrray.add(mutabledict)
                        //
                        //                    let d2 = ["bookmarkarray" : "\(self.arrBookMarkArrray)"]
                        //                     db.collection("users").document(myDocID!).updateData(d2) { (error) in
                        //                         if error != nil
                        //                         {
                        //                             print(error!.localizedDescription)
                        //                         }
                        //                     }
                                        }
                                        
                        
                    }else
                    {
                          let link = arrPositifeedy[sender.tag].documentID
                                          
                                          if let index = appDel.arrBookMarkLinkFeedy.firstIndex(of: link!) {
                                              appDel.arrBookMarkLinkFeedy.remove(at: index)
                                          }
                                          
                                          let d = ["linksFeedy" : appDel.arrBookMarkLinkFeedy]
                                          db.collection("users").document(myDocID!).updateData(d) { (error) in
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
                                                    db.collection("users").document(myDocID!).updateData(d2) { (error) in
                                                        if error != nil
                                                        {
                                                            print(error!.localizedDescription)
                                                        }
                                                    }
                                                }
                                                else
                                                {
                        //                            // not exist
                        //                            let mutabledict = NSMutableDictionary.init()
                        //                            mutabledict.setValue(arrPositifeedy[sender.tag].documentID!, forKey: "feed")
                        //                            mutabledict.setValue("\(timestamp)", forKey: "timestamp")
                        //                            self.arrBookMarkArrray.add(mutabledict)
                        //
                        //                            let d2 = ["bookmarkarray" : "\(self.arrBookMarkArrray)"]
                        //                             db.collection("users").document(myDocID!).updateData(d2) { (error) in
                        //                                 if error != nil
                        //                                 {
                        //                                     print(error!.localizedDescription)
                        //                                 }
                        //                             }
                                                }
                        
                    }
                   
                    
                  } else {
                    
                    
                    
                  }
                  
              }
              tableView.reloadData()
          }
          
        func isBookMark(link : String,desc: String) -> Bool
          {
              if selectedTab == 0 {
                
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
              } else {
                  let appDel = UIApplication.shared.delegate as! AppDelegate
                  
                  let ind = appDel.arrBookMarkLink.firstIndex(of: link) ?? -1
                  if ind > -1
                  {
                      return true
                  }
              }
              
              return false
          }
          
          func playVideo(url: URL) {
              let player = AVPlayer(url: url)

              let vc = AVPlayerViewController()
              vc.player = player

              self.present(vc, animated: true) { vc.player?.play() }
          }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            
            
<<<<<<< Updated upstream
        }
        deinit {
          //  print("deinit: \(self.greeting!)")
        }
=======
        }
        deinit {
          //  print("deinit: \(self.greeting!)")
        }
>>>>>>> Stashed changes

    
    // MARK: - EMPageViewController Data Source
//     
//     func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
//         if let viewControllerIndex = self.index(of: viewController as! GreetingViewController) {
//             let beforeViewController = self.viewController(at: viewControllerIndex - 1)
//             return beforeViewController
//         } else {
//             return nil
//         }
//     }
//     
//     func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
//         if let viewControllerIndex = self.index(of: viewController as! GreetingViewController) {
//             let afterViewController = self.viewController(at: viewControllerIndex + 1)
//             return afterViewController
//         } else {
//             return nil
//         }
//     }
//     
//     func viewController(at index: Int) -> GreetingViewController? {
//         if (self.greetings.count == 0) || (index < 0) || (index >= self.greetings.count) {
//             return nil
//         }
//         
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewController = storyboard.instantiateViewController(withIdentifier: "GreetingViewController") as! GreetingViewController
//        
//        
//         viewController.greeting = self.greetings[index]
//         //viewController.color = self.greetingColors[index]
//         return viewController
//     }
//     
//     func index(of viewController: GreetingViewController) -> Int? {
//         if let greeting: String = viewController.greeting {
//             return self.greetings.firstIndex(of: greeting)
//         } else {
//             return nil
//         }
//     }
    
    
    
    
     
     // MARK: - EMPageViewController Delegate
    
    /*
     func em_pageViewController(_ pageViewController: EMPageViewController, willStartScrollingFrom startViewController: UIViewController, destinationViewController: UIViewController) {
         
         let startGreetingViewController = startViewController as! GreetingViewController
         let destinationGreetingViewController = destinationViewController as! GreetingViewController
         
         print("Will start scrolling from \(startGreetingViewController.greeting!) to \(destinationGreetingViewController.greeting!).")
     }
     
     func em_pageViewController(_ pageViewController: EMPageViewController, isScrollingFrom startViewController: UIViewController, destinationViewController: UIViewController, progress: CGFloat) {
         let startGreetingViewController = startViewController as! GreetingViewController
         let destinationGreetingViewController = destinationViewController as! GreetingViewController
         
         // Ease the labels' alphas in and out
         let absoluteProgress = abs(progress)
         //startGreetingViewController.label.alpha = pow(1 - absoluteProgress, 2)
         //destinationGreetingViewController.label.alpha = pow(absoluteProgress, 2)
         
        print("Is scrolling from \(startGreetingViewController.greeting!) to \(destinationGreetingViewController.greeting!) with progress '\(progress)'.")
     }
     
     func em_pageViewController(_ pageViewController: EMPageViewController, didFinishScrollingFrom startViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
         let startViewController = startViewController as! GreetingViewController?
         let destinationViewController = destinationViewController as! GreetingViewController
         
         // If the transition is successful, the new selected view controller is the destination view controller.
         // If it wasn't successful, the selected view controller is the start view controller
         if transitionSuccessful {
             
            if startViewController != nil
                       {
                           if startViewController!.greeting == "Articles"
                           {
                               self.segmentedControl.selectItemAt(index: 0, animated: true)
                           }
                           else
                           {
                               self.segmentedControl.selectItemAt(index: 1, animated: true)
                           }
                   }
            
            
//             if (self.index(of: destinationViewController) == 0) {
//                 self.reverseButton.isEnabled = false
//             } else {
//                 self.reverseButton.isEnabled = true
//             }
//             
//             if (self.index(of: destinationViewController) == self.greetings.count - 1) {
//                 self.forwardButton.isEnabled = false
//             } else {
//                 self.forwardButton.isEnabled = true
//             }
         }
       
        
           
        
         print("Finished scrolling from \(startViewController != nil ? startViewController!.greeting! : "nil") to \(destinationViewController.greeting!). Transition successful? \(transitionSuccessful)")
     }
    */
    
}



//MARK:- UITableViewDataSource
extension welcomeViewController : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        self.tableView.isHidden = selectedTab == 0 ? (arrPositifeedy.count == 0) : (arrFeeds.count == 0)
        return selectedTab == 0 ? arrPositifeedy.count : arrFeeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row % 5 == 0 && indexPath.row != 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "adsCell", for: indexPath) as! AdsTableViewCell
            cell.controller = self
            
            return cell
        }
        
        if selectedTab == 0 {
<<<<<<< Updated upstream

=======
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedyCell", for: indexPath) as! FeedyCell
            
>>>>>>> Stashed changes
            let feed = arrPositifeedy[indexPath.row]

            if feed.description_d != nil
            {

<<<<<<< Updated upstream
                if #available(iOS 13.0, *) {
                    
                    var provider = LPMetadataProvider()
                    provider = LPMetadataProvider()
                    provider.timeout = 50
                    
                    var linkView = LPLinkView()

                    if let url = URL(string: feed.link!) {
                               
                               linkView = LPLinkView(url: url)

                               // 1. Check if the metadata exists
                               if let existingMetadata = MetadataCache.retrieve(urlString: url.absoluteString) {

                                   linkView = LPLinkView(metadata: existingMetadata)
                                   //self.lblTitle.text = existingMetadata.title ?? ""
                               
                                // images :
                                let imageProvider1 = existingMetadata.imageProvider
                                if imageProvider1 != nil
                                {
                                    
                                    let cell = tableView.dequeueReusableCell(withIdentifier: "FeedyCell", for: indexPath) as! FeedyCell
                                      cell.viewLink.isHidden = true
                                      
                                    
                                      cell.lblTitle.text = existingMetadata.title
                                    
                                    
                                      let date =  feed.time?.toDate()
                                      //cell.btnShare.tag = indexPath.row
                                      //cell.btnShare.addTarget(self, action: #selector(btnShareClickFeed), for: .touchUpInside)
                                      
                                      cell.btnPlay.isHidden = true
                                      //cell.lblTitle.text = feed.title
                                      cell.lblDesc.text = feed.description_d
                                      cell.lblTime.text  = date!.getElapsedInterval((feed.time?.getTimeZone())!)
                                      
                                      cell.btnShare.tag = indexPath.row
                                     cell.btnShare.addTarget(self, action: #selector(btnShareClickFeed), for: .touchUpInside)
                                    
                                     cell.btnBookMark.setImage(UIImage(named: "book_mark_ic"), for: .normal)
                                     cell.btnBookMark.setImage(UIImage(named: "bookmarkSelected"), for: .selected)
                                     cell.btnBookMark.tag = indexPath.row
                                     cell.btnBookMark.isSelected = isBookMark(link: feed.link!,desc: feed.description_d!)
                                     cell.btnBookMark.addTarget(self, action: #selector(btnBookMarkClick), for: .touchUpInside)
                                      cell.imgView.cornerRadius(10)
                                     cell.img.image = UIImage(named: "vlogo")
                                    
                                      if feed.link != nil
                                      {
                                          if let link = URL(string: feed.link!)
                                          {
                                              if Images(rawValue: (link.domain)!)!.image != nil
                                              {
                                                   if let img = Images(rawValue: (link.domain)!)!.image
                                                  {
                                                      print("img :\(img)")
                                                      cell.img.image = UIImage(named: img)
                                                  }
                                                  else
                                                   {
                                                      cell.img.image = UIImage(named: "vlogo")
                                                  }
                                              }
                                          }
                                      }
                                   
                                    imageProvider1!.loadObject(ofClass: UIImage.self) { (image, error) in
                                        guard error == nil else {
                                            // handle error
                                            return
                                        }

                                        if let image = image as? UIImage {
                                            // do something with image
                                            DispatchQueue.main.async {
                                                cell.imgView.isHidden = false
                                                cell.imgView.image = image
                                                
                                            }
                                        } else {
                                            print("no image available")
                                            cell.imgView.image = UIImage.init(named: "vlogo")
                                        }
                                    }
                                    
                                    return cell
                                    
                                    
                                }else
                                {
                                    print("data blank 2")
                                    
                                    let cell = tableView.dequeueReusableCell(withIdentifier: "TblFeedTextCell", for: indexPath) as! TblFeedTextCell

                                      cell.lblTitle.text = existingMetadata.title
                                    
                                    cell.img.layer.cornerRadius = cell.img.frame.size.width / 2
                                    cell.img.layer.cornerRadius = cell.img.frame.size.height / 2
                                    cell.img.clipsToBounds = true
                                    cell.img.image = UIImage(named: "vlogo")
                                    
                                      let date =  feed.time?.toDate()
                                      //cell.btnShare.tag = indexPath.row
                                      //cell.btnShare.addTarget(self, action: #selector(btnShareClickFeed), for: .touchUpInside)
                                      
                                      
                                      //cell.lblTitle.text = feed.title
                                      cell.lblDesc.text = feed.description_d
                                      cell.lblTime.text  = date!.getElapsedInterval((feed.time?.getTimeZone())!)
                                      
                                      cell.btnShare.tag = indexPath.row
                                     cell.btnShare.addTarget(self, action: #selector(btnShareClickFeed), for: .touchUpInside)
                                    
                                     cell.btnBookMark.setImage(UIImage(named: "book_mark_ic"), for: .normal)
                                     cell.btnBookMark.setImage(UIImage(named: "bookmarkSelected"), for: .selected)
                                     cell.btnBookMark.tag = indexPath.row
                                     cell.btnBookMark.isSelected = isBookMark(link: feed.link!,desc: feed.description_d!)
                                     cell.btnBookMark.addTarget(self, action: #selector(btnBookMarkClick), for: .touchUpInside)
                                    
                                      if feed.link != nil
                                      {
                                          if let link = URL(string: feed.link!)
                                          {
                                              if Images(rawValue: (link.domain)!)!.image != nil
                                              {
                                                   if let img = Images(rawValue: (link.domain)!)!.image
                                                  {
                                                      print("img :\(img)")
                                                      cell.img.image = UIImage(named: img)
                                                  }
                                                  else
                                                   {
                                                      cell.img.image = UIImage(named: "vlogo")
                                                  }
                                              }
                                          }
                                      }
                                    
                                    return cell
                                    
                                }
                                
                           }
                            else
                            {
                                let url = URL(string: feed.link!)
                                
                                provider.startFetchingMetadata(for: url!) { [weak self] metadata, error in
                                                               guard let self = self else { return }
                                   guard let metadata = metadata, error == nil else {
                                       return
                                   }
                                        MetadataCache.cache(metadata: metadata)
                                }
                                
                                let cell = tableView.dequeueReusableCell(withIdentifier: "TblFeedTextCell", for: indexPath) as! TblFeedTextCell

                                
                                cell.img.layer.cornerRadius = cell.img.frame.size.width / 2
                                cell.img.layer.cornerRadius = cell.img.frame.size.height / 2
                                cell.img.clipsToBounds = true
                                
                                cell.img.image = UIImage(named: "vlogo")
                                
                                  let date =  feed.time?.toDate()
                                  //cell.btnShare.tag = indexPath.row
                                  //cell.btnShare.addTarget(self, action: #selector(btnShareClickFeed), for: .touchUpInside)
                                  
                                  
                                  cell.lblTitle.text = feed.title
                                  cell.lblDesc.text = feed.description_d
                                  cell.lblTime.text  = date!.getElapsedInterval((feed.time?.getTimeZone())!)
                                  
                                  cell.btnShare.tag = indexPath.row
                                 cell.btnShare.addTarget(self, action: #selector(btnShareClickFeed), for: .touchUpInside)
                                
                                 cell.btnBookMark.setImage(UIImage(named: "book_mark_ic"), for: .normal)
                                 cell.btnBookMark.setImage(UIImage(named: "bookmarkSelected"), for: .selected)
                                 cell.btnBookMark.tag = indexPath.row
                                 cell.btnBookMark.isSelected = isBookMark(link: feed.link!,desc: feed.description_d!)
                                 cell.btnBookMark.addTarget(self, action: #selector(btnBookMarkClick), for: .touchUpInside)
                                                                
                                  if feed.link != nil
                                  {
                                      if let link = URL(string: feed.link!)
                                      {
                                          if Images(rawValue: (link.domain)!)!.image != nil
                                          {
                                               if let img = Images(rawValue: (link.domain)!)!.image
                                              {
                                                  print("img :\(img)")
                                                  cell.img.image = UIImage(named: img)
                                              }
                                              else
                                               {
                                                  cell.img.image = UIImage(named: "vlogo")
                                              }
                                          }
                                      }
                                  }
                                
                                return cell

                           }
                    }else {
                        
                        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedyCell", for: indexPath) as! FeedyCell
                        cell.viewLink.isHidden = true
                          
                          let date =  feed.time?.toDate()
                          //cell.btnShare.tag = indexPath.row
                          //cell.btnShare.addTarget(self, action: #selector(btnShareClickFeed), for: .touchUpInside)
                          
                          cell.btnPlay.isHidden = true
                          //cell.lblTitle.text = feed.title
                          cell.lblDesc.text = feed.description_d
                          cell.lblTime.text  = date!.getElapsedInterval((feed.time?.getTimeZone())!)
                          
                          cell.btnShare.tag = indexPath.row
                         cell.btnShare.addTarget(self, action: #selector(btnShareClickFeed), for: .touchUpInside)
                        
                         cell.btnBookMark.setImage(UIImage(named: "book_mark_ic"), for: .normal)
                         cell.btnBookMark.setImage(UIImage(named: "bookmarkSelected"), for: .selected)
                         cell.btnBookMark.tag = indexPath.row
                         cell.btnBookMark.isSelected = isBookMark(link: feed.link!,desc: feed.description_d!)
                         cell.btnBookMark.addTarget(self, action: #selector(btnBookMarkClick), for: .touchUpInside)
                          cell.imgView.cornerRadius(10)
                         cell.img.image = UIImage(named: "vlogo")
                        
                          if feed.link != nil
                          {
                              if let link = URL(string: feed.link!)
                              {
                                  if Images(rawValue: (link.domain)!)!.image != nil
                                  {
                                       if let img = Images(rawValue: (link.domain)!)!.image
                                      {
                                          print("img :\(img)")
                                          cell.img.image = UIImage(named: img)
                                      }
                                      else
                                       {
                                          cell.img.image = UIImage(named: "vlogo")
                                      }
                                  }
                              }
                          }
                        
                        return cell
                        
                    }
                    
                    
                }
                
                else{
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FeedyCell", for: indexPath) as! FeedyCell
                    cell.viewLink.isHidden = true
                      
                      let date =  feed.time?.toDate()
                      //cell.btnShare.tag = indexPath.row
                      //cell.btnShare.addTarget(self, action: #selector(btnShareClickFeed), for: .touchUpInside)
                      
                      cell.btnPlay.isHidden = true
                      //cell.lblTitle.text = feed.title
                      cell.lblDesc.text = feed.description_d
                      cell.lblTime.text  = date!.getElapsedInterval((feed.time?.getTimeZone())!)
                      
                      cell.btnShare.tag = indexPath.row
                     cell.btnShare.addTarget(self, action: #selector(btnShareClickFeed), for: .touchUpInside)
                    
                     cell.btnBookMark.setImage(UIImage(named: "book_mark_ic"), for: .normal)
                     cell.btnBookMark.setImage(UIImage(named: "bookmarkSelected"), for: .selected)
                     cell.btnBookMark.tag = indexPath.row
                     cell.btnBookMark.isSelected = isBookMark(link: feed.link!,desc: feed.description_d!)
                     cell.btnBookMark.addTarget(self, action: #selector(btnBookMarkClick), for: .touchUpInside)
                      cell.imgView.cornerRadius(10)
                    cell.img.image = UIImage(named: "vlogo")
                      if feed.link != nil
                      {
                          if let link = URL(string: feed.link!)
                          {
                              if Images(rawValue: (link.domain)!)!.image != nil
                              {
                                   if let img = Images(rawValue: (link.domain)!)!.image
                                  {
                                      print("img :\(img)")
                                      cell.img.image = UIImage(named: img)
                                  }
                                  else
                                   {
                                      cell.img.image = UIImage(named: "vlogo")
                                  }
                              }
                          }
                      }
                    
                    return cell
=======
                cell.viewLink.isHidden = true
                let date =  feed.time?.toDate()
                //cell.btnShare.tag = indexPath.row
                //cell.btnShare.addTarget(self, action: #selector(btnShareClickFeed), for: .touchUpInside)
                
                cell.btnPlay.isHidden = true
                cell.lblTitle.text = feed.title
                cell.lblDesc.text = feed.description_d
                cell.lblTime.text  = date!.getElapsedInterval((feed.time?.getTimeZone())!)
                
                cell.btnShare.tag = indexPath.row
               cell.btnShare.addTarget(self, action: #selector(btnShareClickFeed), for: .touchUpInside)
              
               cell.btnBookMark.setImage(UIImage(named: "book_mark_ic"), for: .normal)
               cell.btnBookMark.setImage(UIImage(named: "bookmarkSelected"), for: .selected)
               cell.btnBookMark.tag = indexPath.row
               cell.btnBookMark.isSelected = isBookMark(link: feed.link!,desc: feed.description_d!)
               cell.btnBookMark.addTarget(self, action: #selector(btnBookMarkClick), for: .touchUpInside)
               cell.imgView.cornerRadius(10)
              
                
                
                if feed.link != nil
                {
                    if let link = URL(string: feed.link!)
                    {
                        if Images(rawValue: (link.domain)!)!.image != nil
                        {
                             if let img = Images(rawValue: (link.domain)!)!.image
                            {
                                print("img :\(img)")
                                cell.imgView.image = UIImage(named: img)
                            }
                            else
                             {
                                cell.imgView.image = UIImage(named: "vlogo")
                            }
                        }
                    }
>>>>>>> Stashed changes
                }
                
            }else
            {
<<<<<<< Updated upstream
                
                if feed.feed_type == "text"
                {
                       let cell = tableView.dequeueReusableCell(withIdentifier: "TblFeedTextCell", for: indexPath) as! TblFeedTextCell
                        cell.lblTitle.text = feed.title
                        cell.lblDesc.text = feed.desc

                       cell.btnBookMark.tag = indexPath.row
                       cell.btnBookMark.isSelected = isBookMark(link: feed.documentID!,desc: "")
                       cell.btnBookMark.addTarget(self, action: #selector(btnBookMarkClick), for: .touchUpInside)
                       
                       cell.btnShare.tag = indexPath.row
                       cell.btnShare.addTarget(self, action: #selector(btnShareClick), for: .touchUpInside)
                       cell.img.image = UIImage(named: "vlogo")
                    
                       return cell
                    
                }else
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FeedyCell", for: indexPath) as! FeedyCell
                    cell.bindData(feed: feed)
                    cell.imgView.cornerRadius(10)
                    cell.btnBookMark.tag = indexPath.row
                    cell.btnBookMark.isSelected = isBookMark(link: feed.documentID!,desc: "")
                    cell.btnBookMark.addTarget(self, action: #selector(btnBookMarkClick), for: .touchUpInside)
                    
                    cell.btnShare.tag = indexPath.row
                    cell.btnShare.addTarget(self, action: #selector(btnShareClick), for: .touchUpInside)
                    
                    cell.btnPlay.tag = indexPath.row
                    cell.btnPlay.addTarget(self, action: #selector(btnPlayTapped(_:)), for: .touchUpInside)
                    cell.img.image = UIImage(named: "vlogo")
                    return cell
                }
            }
            
            
=======
                cell.bindData(feed: feed)

                cell.btnBookMark.tag = indexPath.row
                cell.btnBookMark.isSelected = isBookMark(link: feed.documentID!,desc: "")
                cell.btnBookMark.addTarget(self, action: #selector(btnBookMarkClick), for: .touchUpInside)
                
                cell.btnShare.tag = indexPath.row
                cell.btnShare.addTarget(self, action: #selector(btnShareClick), for: .touchUpInside)
                
                cell.btnPlay.tag = indexPath.row
                cell.btnPlay.addTarget(self, action: #selector(btnPlayTapped(_:)), for: .touchUpInside)
            }
            
            
            return cell
>>>>>>> Stashed changes

            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FeedCell

            let feed = arrFeeds[indexPath.row]
            
            let date =  feed.time?.toDate()
            
            
            cell.btnShare.tag = indexPath.row
            cell.btnShare.addTarget(self, action: #selector(btnShareClickFeed), for: .touchUpInside)
            
            cell.btnPlay.isHidden = true
            cell.lblTitle.text = feed.title
            cell.lblDesc.text = feed.desc
            cell.lblTime.text  = date!.getElapsedInterval((feed.time?.getTimeZone())!)
            
            cell.btnBookMark.setImage(UIImage(named: "book_mark_ic"), for: .normal)
            cell.btnBookMark.setImage(UIImage(named: "bookmarkSelected"), for: .selected)
            cell.btnBookMark.tag = indexPath.row
            cell.btnBookMark.isSelected = isBookMark(link: feed.link!,desc: feed.desc!)
            cell.btnBookMark.addTarget(self, action: #selector(btnBookMarkClick), for: .touchUpInside)
            cell.imgView.cornerRadius(10)
            
            if feed.link != nil
            {
                if let link = URL(string: feed.link!)
                {
                    if Images(rawValue: (link.domain)!)!.image != nil
                    {
                         if let img = Images(rawValue: (link.domain)!)!.image
                        {
                            print("img :\(img)")
                            cell.imgView.image = UIImage(named: img)
                        }
                        else
                         {
                            cell.imgView.image = UIImage(named: "vlogo")
                        }
                    }
                }
            }
            return cell
        }
        
    }
<<<<<<< Updated upstream
    
    func pickImageFromURL(url:URL) -> UIImage {
        
        var image1 : UIImage! = UIImage.init(named: "vlogo")
        if #available(iOS 13.0, *) {
            LPMetadataProvider().startFetchingMetadata(for: url) { (linkMetadata, error) in
                guard let linkMetadata = linkMetadata, let imageProvider = linkMetadata.iconProvider else { return }
                
                print(linkMetadata.title ?? "Untitled")
                
                imageProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    guard error == nil else {
                        // handle error
                        return
                    }
                    
                    if let image = image as? UIImage {
                        // do something with image
                        DispatchQueue.main.async {
                            
                            image1 = image

                        }
                    } else {
                        print("no image available")
                       // return
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
        return image1
        
    }
    
=======
>>>>>>> Stashed changes
    
    @objc func btnPlayTapped(_ sender: UIButton) {
        
        let feed = arrPositifeedy[sender.tag]
        if let strUrl = feed.feed_video, let url = URL(string: strUrl) {
            self.playVideo(url: url)
        }
    }
}


//MARK: -UITableViewDelegate
extension welcomeViewController : UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row % 5 == 0 && indexPath.row != 0
        {
            let pref_ad = UserDefaults.standard.object(forKey: PREF_AD_HEIGHT) as? String
            if pref_ad  != nil
            {
                if pref_ad == "1"
                {
                    return 155
                    
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
<<<<<<< Updated upstream
             return UITableView.automaticDimension
        
        
=======
        return UITableView.automaticDimension
>>>>>>> Stashed changes
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        var link: String = ""
        var feed_type: String = ""

        if selectedTab == 0 {
            
            let feed = arrPositifeedy[indexPath.row]
            
            if feed.description_d != nil
            {
                link = feed.link ?? ""
                
            }
            else
            {
                link = feed.documentID ?? ""
                feed_type = feed.feed_type ?? ""
            }
            
            
        } else {
            let feed = arrFeeds[indexPath.row]
            link = feed.link ?? ""
            
        }
        
        if selectedTab == 0 {
            
            let feed = arrPositifeedy[indexPath.row]
            
            if feed.description_d != nil
            {
                let webVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
                webVC.url = link
                webVC.myDocID = self.myDocID
                webVC.isBookmark = isBookMark(link: link,desc: feed.description_d!)
                navigationController?.pushViewController(webVC, animated: true)
                
            }else
            {
                if feed_type == "link" {
                    let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewFeedy") as! WebViewFeedy
                    detailVC.myDocID = self.myDocID
                    detailVC.isBookmark = isBookMark(link: link,desc: "")
                    detailVC.positifeedy = arrPositifeedy[indexPath.row]
                    navigationController?.pushViewController(detailVC, animated: true)
                } else {
                    let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "PostDetailViewController") as! PostDetailViewController
                    detailVC.myDocID = self.myDocID
                    detailVC.isBookmark = isBookMark(link: link,desc: "")
                    detailVC.positifeedy = arrPositifeedy[indexPath.row]
                    navigationController?.pushViewController(detailVC, animated: true)
                }
                
            }
            
        } else {
            
        }
        
        
    }
    
}

