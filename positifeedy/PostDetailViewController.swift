//
//  PostDetailViewController.swift
//  positifeedy
//
//  Created by iMac on 24/10/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import UIKit
import Firebase
import AVKit
import AVFoundation
import SVProgressHUD

class PostDetailViewController: UIViewController {

    var arrBookMarkArrray : NSMutableArray!
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnPlay: UIButton!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var naviview: UIView!
    
    @IBOutlet weak var imgbookmark1: UIImageView!
    @IBOutlet weak var imgshare1: UIImageView!
    
    var arrRecentlyView = NSMutableArray()

    @IBOutlet weak var heightViewImg: NSLayoutConstraint!
    
    
    var myDocID : String?
    var isBookmark: Bool = false
    var positifeedy : PositifeedAllSet!
    
    //let bookmark = UIButton(type: .custom)
    //let share = UIButton(type: .custom)
    
    let imgBookmark = UIImage.init(named: "bookmark-gray")!
    let imgBookmarkSelected = UIImage.init(named: "bookmark-black-fill")!
    let imgShare = UIImage.init(named: "share_ic")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.arrBookMarkArrray = NSMutableArray.init()
        getRecentlyViews()
        self.getBookmarsDataOther()
        
        tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = true
//        bookmark.setImage(isBookmark ? imgBookmarkSelected : imgBookmark, for: .normal)
//        bookmark.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//        bookmark.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
//        bookmark.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
//        let bookmarkButton = UIBarButtonItem(customView: bookmark)
        
//        share.setImage(imgShare, for: .normal)
//        share.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//        share.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
//        let shareButton = UIBarButtonItem(customView: share)
        
        //self.navigationItem.rightBarButtonItems = [shareButton, bookmarkButton]
         //self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDetail(_:)), name: NSNotification.Name(rawValue: "RELOAD_DETAIL"), object: nil)
        
        imgView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.imageTapped(_:)))
        imgView.addGestureRecognizer(tap)
        
        self.imgbookmark1.image = isBookmark ? imgBookmarkSelected : imgBookmark
        
        //self.btnbookmark.setImage(isBookmark ? imgBookmarkSelected : imgBookmark, for: .normal)
        //self.btnshare.setImage(imgShare, for: .normal)
        
        reloadView()
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
//        let timestamp = Date().currentTimeMillis()
//        let mutabledict = NSMutableDictionary.init()
//        mutabledict.setValue(myDocID!, forKey: "feed")
//        mutabledict.setValue("\(timestamp)", forKey: "timestamp")
//        mutabledict.addEntries(from: positifeedy!.toDictionary())
//        self.arrRecentlyView.add(mutabledict)
//
//        //self.arrBookMarkArrray.add(mutabledict)
//        print("My Array :\(arrRecentlyView)")
//
//          let d2 = ["recentlyArray" : arrRecentlyView]
//           db.collection("users").document(myDocID!).updateData(d2) { (error) in
//               if error != nil
//               {
//                   print(error!.localizedDescription)
//               }else {print("ok")}
//           }

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
    
    @objc func imageTapped(_ gesture: UIGestureRecognizer) {
        if let strUrl = positifeedy!.feed_image, let url = URL.init(string: strUrl) {
            let photoVC = SYPhotoBrowser(imageSourceArray: [url], caption: "")
            photoVC?.pageControlStyle = .system
            photoVC?.modalPresentationStyle = .fullScreen
            self.present(photoVC!, animated: true, completion: nil)
        }
    }
    
    @IBAction func onclickforBack(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onclickforBookmark(_ sender: Any)
    {
        isBookmark = !isBookmark
        self.imgbookmark1.image = isBookmark ? imgBookmarkSelected : imgBookmark
        
        //self.btnbookmark.setImage(isBookmark ? imgBookmarkSelected : imgBookmark, for: .normal)
               
               var db: Firestore!
               db = Firestore.firestore()
               
               guard let appDel = UIApplication.shared.delegate as? AppDelegate else {
                   return
               }
               
               if isBookmark
               {
                    if positifeedy.description_d != nil
                    {
                        appDel.arrBookMarkLinkFeedy.append(positifeedy!.link!)
                    }else{
                        appDel.arrBookMarkLinkFeedy.append(positifeedy!.documentID!)
                    }
                                
                    var d = ["" : appDel.arrBookMarkLinkFeedy]
                    if positifeedy.description_d != nil
                    {
                        d = ["links" : appDel.arrBookMarkLinkFeedy]
                    }else{
                        d = ["linksFeedy" : appDel.arrBookMarkLinkFeedy]
                    }
                   db.collection("users").document(myDocID!).updateData(d) { (error) in
                       if error != nil
                       {
                           print(error!.localizedDescription)
                       }
                   }
                   
                   let timestamp = Date().currentTimeMillis()
                
//                   let searchPredicate = NSPredicate(format: "feed beginswith[C] %@",positifeedy!.documentID!)
                    var searchPredicate = NSPredicate()
                    if(positifeedy!.documentID != nil){
                        searchPredicate = NSPredicate(format: "feed beginswith[C] %@",positifeedy!.documentID ?? "")
                    }else{
                        searchPredicate = NSPredicate(format: "link beginswith[C] %@",positifeedy!.link ?? "")
                    }
                
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
                       mutabledict.setValue(positifeedy!.documentID ?? "", forKey: "feed")
                       mutabledict.setValue(positifeedy!.link ?? "", forKey: "link")
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
                    
                   
                    if positifeedy.description_d != nil
                    {
                        if let index = appDel.arrBookMarkLinkFeedy.firstIndex(of: positifeedy!.link!) {
                            appDel.arrBookMarkLinkFeedy.remove(at: index)
                        }
                    }else{
                        if let index = appDel.arrBookMarkLinkFeedy.firstIndex(of: positifeedy!.documentID!) {
                            appDel.arrBookMarkLinkFeedy.remove(at: index)
                        }
                    }
                   
                    var d = ["" : appDel.arrBookMarkLinkFeedy]
                    if positifeedy.description_d != nil
                    {
                        d = ["links" : appDel.arrBookMarkLinkFeedy]
                    }else{
                        d = ["linksFeedy" : appDel.arrBookMarkLinkFeedy]
                    }
                
                   db.collection("users").document(myDocID!).updateData(d) { (error) in
                       if error != nil
                       {
                           print(error!.localizedDescription)
                       }
                   }
                   
                   
                   let timestamp = Date().currentTimeMillis()
                   
                //let searchPredicate = NSPredicate(format: "feed beginswith[C] %@",positifeedy!.documentID!)
                
                    var searchPredicate = NSPredicate()
                    if(positifeedy!.documentID != nil){
                        searchPredicate = NSPredicate(format: "feed beginswith[C] %@",positifeedy!.documentID ?? "")
                    }else{
                        searchPredicate = NSPredicate(format: "link beginswith[C] %@",positifeedy!.link ?? "")
                    }
                
                
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
    
    @objc func reloadDetail(_ noti: Notification) {
        
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
            self.imgbookmark1.image = isBookmark ? imgBookmarkSelected : imgBookmark
            //self.btnbookmark.setImage(isBookmark ? imgBookmarkSelected : imgBookmark, for: .normal)

            reloadView()
        }
    }
    
    func reloadView() {
        
        if positifeedy!.timestamp != nil {
            let f = DateFormatter()
            let date = Date(timeIntervalSince1970: Double(positifeedy!.timestamp!)!)
            lblTime.text = date.getElapsedInterval(f.timeZone)
        } else {
            lblTime.text = ""
        }
        
        if positifeedy!.feed_image != nil {
            if let link = URL(string: positifeedy!.feed_image!)
            {
                imgView.sd_setImage(with: link, placeholderImage: UIImage.init(named: "album_placeholder"), options: .highPriority, completed: nil)
            } else {
                imgView.image = nil
            }
        } else {
            imgView.image = nil
        }

        let feed_type = positifeedy!.feed_type ?? "image"
        if feed_type == "video" {
            btnPlay.isHidden = false
        } else {
            btnPlay.isHidden = true
        }
        
        lblTitle.text = positifeedy!.title ?? ""
        lblDesc.text = positifeedy!.desc ?? ""
        
        if feed_type == "text" {
            self.heightViewImg.constant = 0.0
        } else {
            DispatchQueue.main.async {
                self.heightViewImg.constant = UIScreen.main.bounds.width / 1.6
            }
        }
    }
    
    @IBAction func btnPlayTapped(_ sender: Any) {
        if let strUrl = positifeedy!.feed_video, let url = URL(string: strUrl) {
            self.playVideo(url: url)
        }
    }
    
    func playVideo(url: URL) {
        let player = AVPlayer(url: url)

        let vc = AVPlayerViewController()
        vc.player = player

        self.present(vc, animated: true) { vc.player?.play() }
    }
    
    @objc func bookmarkTapped() {
        
        
        isBookmark = !isBookmark
        self.imgbookmark1.image = isBookmark ? imgBookmarkSelected : imgBookmark
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
    

}
