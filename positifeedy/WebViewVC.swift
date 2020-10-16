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

class WebViewVC: UIViewController {
    
    @IBOutlet weak var webView : WKWebView!
    
    var myDocID : String?
    var isBookmark: Bool = false
    var url : String?
    
    let bookmark = UIButton(type: .custom)
    let share = UIButton(type: .custom)
    
    let imgBookmark = UIImage.init(named: "book_mark_ic")!
    let imgBookmarkSelected = UIImage.init(named: "selected_bookmark_ic")!
    let imgShare = UIImage.init(named: "share_ic")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookmark.setImage(isBookmark ? imgBookmarkSelected : imgBookmark, for: .normal)
        bookmark.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        bookmark.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
        bookmark.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
        let bookmarkButton = UIBarButtonItem(customView: bookmark)
        
        share.setImage(imgShare, for: .normal)
        share.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        share.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        let shareButton = UIBarButtonItem(customView: share)
        
        self.navigationItem.rightBarButtonItems = [shareButton, bookmarkButton]
        
        if let url = url, let u = URL(string: url)
        {
            webView.load(URLRequest(url: u))
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadWeb(_:)), name: NSNotification.Name(rawValue: "RELOAD_WEB"), object: nil)
    }
    
    @objc func reloadWeb(_ noti: Notification) {
        
        if let dict = noti.object as? NSDictionary {
            
            let isBookmark = dict["isBookmark"] as? Bool ?? false
            let url = dict["url"] as? String ?? ""
            
            self.isBookmark = isBookmark
            self.url = url
            
            bookmark.setImage(isBookmark ? imgBookmarkSelected : imgBookmark, for: .normal)

            if let u = URL(string: url)
            {
                webView.load(URLRequest(url: u))
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func bookmarkTapped() {
        
        isBookmark = !isBookmark
        bookmark.setImage(isBookmark ? imgBookmarkSelected : imgBookmark, for: .normal)
        
        var db: Firestore!
        db = Firestore.firestore()
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
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
        }
    }
    
    @objc func shareTapped() {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "positifeedy.page.link"
        components.path = "/share"
        
        let feedURL = URLQueryItem(name: "feedURL", value: url ?? "")
        components.queryItems = [feedURL]
        
        guard let linkParameter = components.url else {
            return
        }
        
        guard let shareLink = DynamicLinkComponents.init(link: linkParameter, domainURIPrefix: "https://positifeedy.page.link") else {
            return
        }
        
        if let myBundleId = Bundle.main.bundleIdentifier {
            shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleId)
        }
        
        shareLink.iOSParameters?.appStoreID = "1484015088"
        
        guard let longURL = shareLink.url else {
            return
        }
        
        shareLink.shorten { [weak self] (url, warnings, error) in
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
