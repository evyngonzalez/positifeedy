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

class WebViewFeedy: UIViewController {

    @IBOutlet weak var webView : WKWebView!

    var myDocID : String?
    var isBookmark: Bool = false
    var positifeedy : Positifeedy?

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
        bookmark.addTarget(self, action: #selector(self.bookmarkTapped), for: .touchUpInside)
        let bookmarkButton = UIBarButtonItem(customView: bookmark)
        
        share.setImage(imgShare, for: .normal)
        share.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        share.addTarget(self, action: #selector(self.shareTapped), for: .touchUpInside)
        let shareButton = UIBarButtonItem(customView: share)
        
        self.navigationItem.rightBarButtonItems = [shareButton, bookmarkButton]
        
        if let url = positifeedy?.feed_url, let u = URL(string: url)
        {
            webView.load(URLRequest(url: u))
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadWeb(_:)), name: NSNotification.Name(rawValue: "RELOAD_WEB_FEED"), object: nil)
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
            
            bookmark.setImage(isBookmark ? imgBookmarkSelected : imgBookmark, for: .normal)

            if let url = positifeedy?.feed_url, let u = URL(string: url)
            {
                webView.load(URLRequest(url: u))
            }
        }
    }

    @objc func bookmarkTapped() {
        
        isBookmark = !isBookmark
        bookmark.setImage(isBookmark ? imgBookmarkSelected : imgBookmark, for: .normal)
        
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
    
    func showShareSheet(url: URL) {
        
        let promoText = "Check out this feed"
        let activityVC = UIActivityViewController(activityItems: [promoText, url], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
