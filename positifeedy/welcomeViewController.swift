//
//  welcomeViewController.swift
//  positifeedy
//
//  Created by Evyn Gonzalez  on 9/12/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import CoreData
import SVProgressHUD
import GoogleMobileAds
import AVKit
import AVFoundation
import SDWebImage

class welcomeViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var segmentedControl: TTSegmentedControl!

//    @IBOutlet var collectionView: UICollectionView!
//    @IBOutlet weak var heightCol: NSLayoutConstraint!
    
    var arrFeeds : [Feed] = []
    var arrPositifeedy = [Positifeedy]()

    var adsCount : Int = 0
    var refreshControl = UIRefreshControl()
    var isRefresh = false
    var myDocID : String?
    var ac : UIActivityIndicatorView!

    var selectedTab: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure collection view
//        collectionView.register(UINib(nibName: "PositifeedyCell", bundle: nil), forCellWithReuseIdentifier: "PositifeedyCell")
//        collectionView.register(UINib(nibName: "AdsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AdsCollectionViewCell")
//
//        collectionView.contentInset = UIEdgeInsets.init(top: 0, left: 30, bottom: 0, right: 30)
//        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
//        collectionView.delegate = self
//        collectionView.dataSource = self
//
//        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.estimatedItemSize = .zero
//
//        collectionView.reloadData()
        
        // configure tableview
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200.0
        
        tableView.register(UINib(nibName: "FeedCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.register(UINib(nibName: "FeedyCell", bundle: nil), forCellReuseIdentifier: "FeedyCell")

        
        tableView.register(UINib(nibName: "AdsTableViewCell", bundle: nil), forCellReuseIdentifier: "adsCell")
        
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        //         UIApplication.shared.statusBarView?.backgroundColor = UIColor.green
        
        getBookmarsData()
        getBookmarsDataFeedy()
        
        getFeeds()
        getPositifeedy()
        
        setNavBackground()
        
        //        refreshControl.attributedTitle = NSAttributedString(string: )
        //  refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
                
        // segment controller
        segmentedControl.setDesignedBorder(radius: 20.0, width: 0)
        
        segmentedControl.selectItemAt(index: 0, animated: false)
        segmentedControl.itemTitles = ["From Us", "Articles"]
        segmentedControl.defaultTextFont = UIFont.systemFont(ofSize: 16.0)
        segmentedControl.selectedTextFont = UIFont.systemFont(ofSize: 16.0)
        segmentedControl.thumbPadding = 3.0
        segmentedControl.didSelectItemWith = { (index, title) in
            
            self.selectedTab = index
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavTitle(title : "positifeedy")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        self.isRefresh = true
        getFeeds()
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
                    
                }
                catch {
                    
                }
                self.tableView.reloadData()
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
                if (d["uid"] as! String) == Auth.auth().currentUser?.uid
                {
                    let appDel = UIApplication.shared.delegate as! AppDelegate

                    self.myDocID = doc.documentID
                    appDel.myDocID = doc.documentID
                    
                    if let links = (d["links"] as? [String])
                    {
                        appDel.arrBookMarkLink = links
                    }
                    self.tableView.reloadData()
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
                if (d["uid"] as! String) == Auth.auth().currentUser?.uid
                {
                    let appDel = UIApplication.shared.delegate as! AppDelegate

                    self.myDocID = doc.documentID
                    appDel.myDocID = doc.documentID
                    
                    if let links = (d["linksFeedy"] as? [String])
                    {
                        appDel.arrBookMarkLinkFeedy = links
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
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
        
        AF.request(Global.feedURL).responseDecodable(of: FeedResponse.self)  { (response) in
            
            SVProgressHUD.dismiss()
            
            switch response.result
            {
            case .success(let feedResponse) :
                if (feedResponse.ok ?? false)
                {
                    self.arrFeeds = feedResponse.info.arrFeedData ?? []
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
            
        }
    }
        
    @objc func btnShareClick(_ sender : UIButton) {
        
        SVProgressHUD.show()

        let positifeedy = arrPositifeedy[sender.tag]
        
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
                appDel.arrBookMarkLinkFeedy.append(arrPositifeedy[sender.tag].documentID!)
                let d = ["linksFeedy" : appDel.arrBookMarkLinkFeedy]
                db.collection("users").document(myDocID!).updateData(d) { (error) in
                    if error != nil
                    {
                        print(error!.localizedDescription)
                    }
                }
            } else {
                appDel.arrBookMarkLink.append(arrFeeds[sender.tag].link!)
                let d = ["links" : appDel.arrBookMarkLink]
                db.collection("users").document(myDocID!).updateData(d) { (error) in
                    if error != nil
                    {
                        print(error!.localizedDescription)
                    }
                }
            }
            
        }
        else
        {
            sender.isSelected = false
            
            if selectedTab == 0 {
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
            } else {
                let link = arrFeeds[sender.tag].link
                
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
            }
            
        }
        tableView.reloadData()
    }
    
    func isBookMark(link : String) -> Bool
    {
        if selectedTab == 0 {
            let appDel = UIApplication.shared.delegate as! AppDelegate
            
            let ind = appDel.arrBookMarkLinkFeedy.firstIndex(of: link) ?? -1
            if ind > -1
            {
                return true
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
    
}

//MARK:- Collection View Delegate & Data Source
//extension welcomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
//
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 10
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        if indexPath.row % 5 == 0 && indexPath.row != 0
//        {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdsCollectionViewCell", for: indexPath) as! AdsCollectionViewCell
//            cell.controller = self
//
//            return cell
//        }
//
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PositifeedyCell", for: indexPath) as! PositifeedyCell
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        var cellSize: CGSize = collectionView.bounds.size
//
//        cellSize.width -= collectionView.contentInset.left
//        cellSize.width -= collectionView.contentInset.right
//
//        return cellSize
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("Item selected at \(indexPath.row)")
//    }
//}

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
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedyCell", for: indexPath) as! FeedyCell

            let feed = arrPositifeedy[indexPath.row]
            
            cell.bindData(feed: feed)
                        
            cell.btnBookMark.tag = indexPath.row
            cell.btnBookMark.isSelected = isBookMark(link: feed.documentID!)
            cell.btnBookMark.addTarget(self, action: #selector(btnBookMarkClick), for: .touchUpInside)
            
            cell.btnShare.tag = indexPath.row
            cell.btnShare.addTarget(self, action: #selector(btnShareClick), for: .touchUpInside)
            
            cell.btnPlay.tag = indexPath.row
            cell.btnPlay.addTarget(self, action: #selector(btnPlayTapped(_:)), for: .touchUpInside)
            
            return cell

            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FeedCell

            let feed = arrFeeds[indexPath.row]
            
            let date =  feed.time?.toDate()
            
            cell.btnPlay.isHidden = true
            cell.lblTitle.text = feed.title
            cell.lblDesc.text = feed.desc
            cell.lblTime.text  = date!.getElapsedInterval((feed.time?.getTimeZone())!)
            
            cell.btnBookMark.setImage(UIImage(named: "bookmark"), for: .normal)
            cell.btnBookMark.setImage(UIImage(named: "bookmarkSelected"), for: .selected)
            cell.btnBookMark.tag = indexPath.row
            cell.btnBookMark.isSelected = isBookMark(link: feed.link!)
            cell.btnBookMark.addTarget(self, action: #selector(btnBookMarkClick), for: .touchUpInside)
            cell.imgView.cornerRadius(10)
            
            if let link = URL(string: feed.link!)
            {
                if let img = Images(rawValue: (link.domain)!)!.image
                {
                    cell.imgView.image = UIImage(named: img )
                }
            }
            
            return cell

        }
        
    }
    
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
            return 155
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var link: String = ""
        var feed_type: String = ""

        if selectedTab == 0 {
            let feed = arrPositifeedy[indexPath.row]
            link = feed.documentID ?? ""
            feed_type = feed.feed_type ?? ""
            
        } else {
            let feed = arrFeeds[indexPath.row]
            link = feed.link ?? ""
            
        }
        
        if selectedTab == 0 {
            
            if feed_type == "link" {
                let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewFeedy") as! WebViewFeedy
                detailVC.myDocID = self.myDocID
                detailVC.isBookmark = isBookMark(link: link)
                detailVC.positifeedy = arrPositifeedy[indexPath.row]
                navigationController?.pushViewController(detailVC, animated: true)
            } else {
                let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "PostDetailViewController") as! PostDetailViewController
                detailVC.myDocID = self.myDocID
                detailVC.isBookmark = isBookMark(link: link)
                detailVC.positifeedy = arrPositifeedy[indexPath.row]
                navigationController?.pushViewController(detailVC, animated: true)
            }
            
        } else {
            let webVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
            webVC.url = link
            webVC.myDocID = self.myDocID
            webVC.isBookmark = isBookMark(link: link)
            navigationController?.pushViewController(webVC, animated: true)
        }
        
        
    }
    
}

