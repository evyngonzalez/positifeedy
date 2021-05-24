//
//  WebViewFeedy.swift
//  positifeedy
//
//  Created by iMac on 28/10/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import UIKit
import WebKit
import Firebase
import SVProgressHUD

class WebViewFeedy: UIViewController,WKNavigationDelegate
{

    @IBOutlet weak var webView : WKWebView!
    var arrBookMarkArrray : NSMutableArray!
    
    var myDocID : String?
    var isBookmark: Bool = false
    var positifeedy : PositifeedAllSet?
    var arrRecentlyView = NSMutableArray()

    //let bookmark = UIButton(type: .custom)
    //let share = UIButton(type: .custom)
    
    @IBOutlet weak var imgBookmark1: UIImageView!
    @IBOutlet weak var imgshare1: UIImageView!
    let imgBookmark = UIImage.init(named: "bm-0")!
    let imgBookmarkSelected = UIImage.init(named: "bm-1")!
    let imgShare = UIImage.init(named: "share_ic")!
    
    @IBOutlet weak var navview: UIView!
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var btnback: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = false
        getRecentlyViews()
        self.arrBookMarkArrray = NSMutableArray.init()
        self.getBookmarsDataOther()
        
        self.navigationController?.navigationBar.isHidden = true
        
//        bookmark.setImage(isBookmark ? imgBookmarkSelected : imgBookmark, for: .normal)
//        bookmark.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//        bookmark.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
//        bookmark.addTarget(self, action: #selector(self.bookmarkTapped), for: .touchUpInside)
//        let bookmarkButton = UIBarButtonItem(customView: bookmark)
        
//        share.setImage(imgShare, for: .normal)
//        share.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//        share.addTarget(self, action: #selector(self.shareTapped), for: .touchUpInside)
//        let shareButton = UIBarButtonItem(customView: share)
//        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
//        self.navigationItem.rightBarButtonItems = [shareButton, bookmarkButton]
        
        self.loader.isHidden = false
        self.loader.startAnimating()
        if let url = positifeedy?.feed_url, let u = URL(string: url)
        {
            webView.navigationDelegate = self
            webView.load(URLRequest(url: u))
        }
        
        self.imgBookmark1.image = isBookmark ? imgBookmarkSelected : imgBookmark
        
        //self.btnbookmark.setImage(isBookmark ? imgBookmarkSelected : imgBookmark, for: .normal)
        //self.btnshare.setImage(imgShare, for: .normal)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadWeb(_:)), name: NSNotification.Name(rawValue: "RELOAD_WEB_FEED"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if(positifeedy == nil){
            return
        }
       // let mutablearray = NSMutableArray.init()
        print("Call recent !")
       var db: Firestore!
       db = Firestore.firestore()
       
       guard let appDel = UIApplication.shared.delegate as? AppDelegate else {
           return
       }
        
//        let searchPredicate = NSPredicate(format: "documentID beginswith[C] %@",positifeedy!.documentID ?? "")
        var searchPredicate = NSPredicate()
        if(positifeedy!.documentID != nil){
            searchPredicate = NSPredicate(format: "documentID beginswith[C] %@",positifeedy!.documentID ?? "")
        }else{
            searchPredicate = NSPredicate(format: "link beginswith[C] %@",positifeedy!.link ?? "")
        }
        
        let  arrrResult = self.arrRecentlyView.filter{ searchPredicate.evaluate(with: $0) };
        if(arrrResult.count > 0){
            return
        }else{
            
            let timestamp = Date().currentTimeMillis()
            let mutabledict = NSMutableDictionary.init()
            mutabledict.setValue(myDocID!, forKey: "feed")
            mutabledict.setValue(positifeedy!.documentID, forKey: "documentID")
            mutabledict.setValue("\(timestamp)", forKey: "timestamp")
            mutabledict.addEntries(from: positifeedy!.toDictionary())
            self.arrRecentlyView.add(mutabledict)

            let d2 = ["recentlyArray" : arrRecentlyView]
             db.collection("users").document(myDocID!).updateData(d2) { (error) in
                 if error != nil
                 {
                     print(error!.localizedDescription)
                 }else {print("ok")}
             }
        }
        //self.arrBookMarkArrray.add(mutabledict)
        print("My Array :\(arrRecentlyView)")
        
    }

    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
       {
           print("calll finish")
           self.loader.stopAnimating()
           self.loader.isHidden = true
       }
    
    
    //MARK:- recently view :
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
                             self.arrRecentlyView = NSMutableArray.init(array: arr!)
                         }
                         else
                         {
                             self.arrRecentlyView = NSMutableArray.init()
                         }
                         
                       }
                   }
               }
           }
       }
    
    @objc func reloadWeb(_ noti: Notification) {
        
        if let dict = noti.object as? NSDictionary {
            
            let isBookmark = dict["isBookmark"] as? Bool ?? false

            positifeedy!.documentID = dict["feedURL"] as? String
            positifeedy!.title = dict["feedTitle"] as? String
            positifeedy!.desc = dict["feedDesc"] as? String
            positifeedy!.feed_video = dict["feedVideo"] as? String
            positifeedy!.feed_image = dict["feedImage"] as? String
            positifeedy!.feed_type = dict["feedType"] as? String
            positifeedy!.timestamp = dict["feedTime"] as? String
            
            self.isBookmark = isBookmark
            self.imgBookmark1.image = isBookmark ? imgBookmarkSelected : imgBookmark
            //self.btnbookmark.setImage(isBookmark ? imgBookmarkSelected : imgBookmark, for: .normal)

            if let url = positifeedy?.feed_url, let u = URL(string: url)
            {
                webView.navigationDelegate = self
                webView.load(URLRequest(url: u))
            }
        }
    }

    @IBAction func onclickforBack(_ sender: Any)
       {
           self.navigationController?.popViewController(animated: true)
       }
       
    @IBAction func onclickforBookmark(_ sender: Any)
    {
        isBookmark = !isBookmark
        self.imgBookmark1.image = isBookmark ? imgBookmarkSelected : imgBookmark
        //self.btnbookmark.setImage(isBookmark ? imgBookmarkSelected : imgBookmark, for: .normal)
        
        var db: Firestore!
        db = Firestore.firestore()
        
        guard let appDel = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        if isBookmark
        {
            appDel.arrBookMarkLinkFeedy.append(positifeedy!.documentID!)
            let d = ["linksFeedy" : appDel.arrBookMarkLinkFeedy]
            db.collection("users").document(myDocID!).updateData(d) { (error) in
                if error != nil
                {
                    print(error!.localizedDescription)
                }
            }
            
            let timestamp = Date().currentTimeMillis()
            let searchPredicate = NSPredicate(format: "feed beginswith[C] %@",positifeedy!.documentID!)
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
                mutabledict.setValue(positifeedy!.documentID!, forKey: "feed")
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
        else
        {
            if let index = appDel.arrBookMarkLinkFeedy.firstIndex(of: positifeedy!.documentID!) {
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
            let searchPredicate = NSPredicate(format: "feed beginswith[C] %@",positifeedy!.documentID!)
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
            {}
            
            
            
        }
    
    }
    
    @IBAction func onclickforshare(_ sender: Any)
    {
            SVProgressHUD.show()

               var components = URLComponents()
               components.scheme = "https"
               components.host = "positifeedy.page.link"
               components.path = "/share"
               
               var arrCompo = [URLQueryItem]()
               
               let feedURL = URLQueryItem(name: "feedURL", value: positifeedy!.documentID!)
               arrCompo.append(feedURL)
               
               if let utf8str = (positifeedy!.title ?? "").data(using: .utf8) {
                   let base64Encoded = utf8str.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
                   
                   let feedTitle = URLQueryItem(name: "feedTitle", value: base64Encoded)
                   arrCompo.append(feedTitle)
               }

               if let utf8str = (positifeedy!.desc ?? "").data(using: .utf8) {
                   let base64Encoded = utf8str.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
                   
                   let feedDesc = URLQueryItem(name: "feedDesc", value: base64Encoded)
                   arrCompo.append(feedDesc)
               }

               let feedVideo = URLQueryItem(name: "feedVideo", value: positifeedy!.feed_video ?? "")
               let feedImage = URLQueryItem(name: "feedImage", value: positifeedy!.feed_image ?? "")
               let feedType = URLQueryItem(name: "feedType", value: positifeedy!.feed_type ?? "")
               let feedTime = URLQueryItem(name: "feedTime", value: positifeedy!.timestamp ?? "")
               let feedLink = URLQueryItem(name: "feedLink", value: positifeedy!.feed_url ?? "")

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
    
    
    @objc func bookmarkTapped() {
        
        isBookmark = !isBookmark
        self.imgBookmark1.image = isBookmark ? imgBookmarkSelected : imgBookmark
        
        //self.btnbookmark.setImage(isBookmark ? imgBookmarkSelected : imgBookmark, for: .normal)
        
        var db: Firestore!
        db = Firestore.firestore()
        
        guard let appDel = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        if isBookmark
        {
            appDel.arrBookMarkLinkFeedy.append(positifeedy!.documentID!)
            let d = ["linksFeedy" : appDel.arrBookMarkLinkFeedy]
            db.collection("users").document(myDocID!).updateData(d) { (error) in
                if error != nil
                {
                    print(error!.localizedDescription)
                }
            }
            
            let timestamp = Date().currentTimeMillis()
            let searchPredicate = NSPredicate(format: "feed beginswith[C] %@",positifeedy!.documentID!)
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
                mutabledict.setValue(positifeedy!.documentID!, forKey: "feed")
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
        else
        {
            if let index = appDel.arrBookMarkLinkFeedy.firstIndex(of: positifeedy!.documentID!) {
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
            let searchPredicate = NSPredicate(format: "feed beginswith[C] %@",positifeedy!.documentID!)
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
            {}
            
            
            
        }
    }
    
    @objc func shareTapped() {
        
        SVProgressHUD.show()

        var components = URLComponents()
        components.scheme = "https"
        components.host = "positifeedy.page.link"
        components.path = "/share"
        
        var arrCompo = [URLQueryItem]()
        
        let feedURL = URLQueryItem(name: "feedURL", value: positifeedy!.documentID!)
        arrCompo.append(feedURL)
        
        if let utf8str = (positifeedy!.title ?? "").data(using: .utf8) {
            let base64Encoded = utf8str.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
            
            let feedTitle = URLQueryItem(name: "feedTitle", value: base64Encoded)
            arrCompo.append(feedTitle)
        }

        if let utf8str = (positifeedy!.desc ?? "").data(using: .utf8) {
            let base64Encoded = utf8str.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
            
            let feedDesc = URLQueryItem(name: "feedDesc", value: base64Encoded)
            arrCompo.append(feedDesc)
        }

        let feedVideo = URLQueryItem(name: "feedVideo", value: positifeedy!.feed_video ?? "")
        let feedImage = URLQueryItem(name: "feedImage", value: positifeedy!.feed_image ?? "")
        let feedType = URLQueryItem(name: "feedType", value: positifeedy!.feed_type ?? "")
        let feedTime = URLQueryItem(name: "feedTime", value: positifeedy!.timestamp ?? "")
        let feedLink = URLQueryItem(name: "feedLink", value: positifeedy!.feed_url ?? "")

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
    
    func showShareSheet(url: URL) {
        
        let promoText = "Check out this feed"
        let activityVC = UIActivityViewController(activityItems: [promoText, url], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
