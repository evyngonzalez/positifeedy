//
//  WebViewVC.swift
//  positifeedy
//
//  Created by iMac on 24/09/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import UIKit
import WebKit
import Firebase
import SVProgressHUD

class WebViewVC: UIViewController,WKNavigationDelegate {
    
    @IBOutlet weak var webView : WKWebView!
    var arrBookMarkArrray : NSMutableArray!
    
    var myDocID : String?
    var isBookmark: Bool = false
    var url : String?
    
    //let bookmark = UIButton(type: .custom)
    //let share = UIButton(type: .custom)
    
    let imgBookmark = UIImage.init(named: "book_mark_ic")!
    let imgBookmarkSelected = UIImage.init(named: "selected_bookmark_ic")!
    let imgShare = UIImage.init(named: "share_ic")!
    
    @IBOutlet weak var imgBookmark1: UIImageView!
    @IBOutlet weak var btnbookmark: UIButton!
    @IBOutlet weak var btnshare: UIButton!

    @IBOutlet weak var imgshare1: UIImageView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var navviewd: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.arrBookMarkArrray = NSMutableArray.init()
       
        self.getBookmarsDataOther()
        
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
//        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
//        self.navigationItem.rightBarButtonItems = [shareButton, bookmarkButton]
        
        
        self.loader.isHidden = false
        self.loader.startAnimating()
        if let url = url, let u = URL(string: url)
        {
            webView.navigationDelegate = self
            webView.load(URLRequest(url: u))
        }
        
        self.imgBookmark1.image = isBookmark ? imgBookmarkSelected : imgBookmark
        //self.btnbookmark.setImage(isBookmark ? imgBookmarkSelected : imgBookmark, for: .normal)
        //self.btnshare.setImage(imgShare, for: .normal)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadWeb(_:)), name: NSNotification.Name(rawValue: "RELOAD_WEB"), object: nil)
    }
    
    @objc func reloadWeb(_ noti: Notification) {
        
        if let dict = noti.object as? NSDictionary {
            
            let isBookmark = dict["isBookmark"] as? Bool ?? false
            let url = dict["feedURL"] as? String ?? ""
            
            self.isBookmark = isBookmark
            self.url = url
            
            self.imgBookmark1.image = isBookmark ? imgBookmarkSelected : imgBookmark
            
            //self.btnbookmark.setImage(isBookmark ? imgBookmarkSelected : imgBookmark, for: .normal)

            if let u = URL(string: url)
            {
                webView.navigationDelegate = self
                webView.load(URLRequest(url: u))
                
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        print("calll finish")
        self.loader.stopAnimating()
        self.loader.isHidden = true
    }
    
    
    @objc func bookmarkTapped() {
        
        isBookmark = !isBookmark
        //self.btnbookmark.setImage(isBookmark ? imgBookmarkSelected : imgBookmark, for: .normal)
        self.imgBookmark1.image = isBookmark ? imgBookmarkSelected : imgBookmark
        var db: Firestore!
        db = Firestore.firestore()
        
        guard let appDel = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        if isBookmark
        {
            appDel.arrBookMarkLink.append(url!)
            let d = ["links" : appDel.arrBookMarkLink]
            db.collection("users").document(myDocID!).updateData(d) { (error) in
                if error != nil
                {
                    print(error!.localizedDescription)
                }
            }
            
            let timestamp = Date().currentTimeMillis()
            let searchPredicate = NSPredicate(format: "link beginswith[C] %@",url!)
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
                mutabledict.setValue(url!, forKey: "link")
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
            if let index = appDel.arrBookMarkLink.firstIndex(of: url!) {
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
               let searchPredicate = NSPredicate(format: "link beginswith[C] %@",url!)
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
            
            
        }
    }
    
    @IBAction func onclickforBack(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onclickforBookmark(_ sender: Any)
    {
        isBookmark = !isBookmark
        //self.btnbookmark.setImage(isBookmark ? imgBookmarkSelected : imgBookmark, for: .normal)
        self.imgBookmark1.image = isBookmark ? imgBookmarkSelected : imgBookmark
        var db: Firestore!
        db = Firestore.firestore()
        
        guard let appDel = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        if isBookmark
        {
            appDel.arrBookMarkLink.append(url!)
            let d = ["links" : appDel.arrBookMarkLink]
            db.collection("users").document(myDocID!).updateData(d) { (error) in
                if error != nil
                {
                    print(error!.localizedDescription)
                }
            }
            
            let timestamp = Date().currentTimeMillis()
            let searchPredicate = NSPredicate(format: "link beginswith[C] %@",url!)
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
                mutabledict.setValue(url!, forKey: "link")
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
            if let index = appDel.arrBookMarkLink.firstIndex(of: url!) {
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
               let searchPredicate = NSPredicate(format: "link beginswith[C] %@",url!)
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
            
            
        }
    }
    
    @IBAction func onclickforshare(_ sender: Any)
    {
        SVProgressHUD.show()

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
    @objc func shareTapped() {
        
        SVProgressHUD.show()

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
