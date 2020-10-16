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

class welcomeViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var heightCol: NSLayoutConstraint!
    
    var arrFeeds : [Feed] = []
    var adsCount : Int = 0
    var refreshControl = UIRefreshControl()
    var isRefresh = false
    var myDocID : String?
    var ac : UIActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure collection view
        collectionView.register(UINib(nibName: "PositifeedyCell", bundle: nil), forCellWithReuseIdentifier: "PositifeedyCell")
        collectionView.register(UINib(nibName: "AdsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AdsCollectionViewCell")

        collectionView.contentInset = UIEdgeInsets.init(top: 0, left: 30, bottom: 0, right: 30)
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.estimatedItemSize = .zero
        
        collectionView.reloadData()
        
        // configure tableview
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(UINib(nibName: "FeedCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.register(UINib(nibName: "AdsTableViewCell", bundle: nil), forCellReuseIdentifier: "adsCell")
        
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        //         UIApplication.shared.statusBarView?.backgroundColor = UIColor.green
        
        getBookmarsData()
        
        getFeeds()
        setNavBackground()
        
        //        refreshControl.attributedTitle = NSAttributedString(string: )
        //  refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setNavTitle(title : "postifieedy")
    }
    
    @objc func refresh(_ sender: AnyObject) {
        self.isRefresh = true
        getFeeds()
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
        
        AF.request(Global.feedURL).responseDecodable(of: FeedResponse.self )  { (response) in
            
            SVProgressHUD.dismiss()
            
            switch response.result
            {
            case .success(let feedResponse) :
                if  (feedResponse.ok ?? false)
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
        
    
    @objc func btnBookMarkClick(_ sender : UIButton)  {
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        //      let context = appDel.persistentContainer.viewContext
        
        var db: Firestore!
        db = Firestore.firestore()
        
        if sender.isSelected == false
        {
            sender.isSelected = true
            
            appDel.arrBookMarkLink.append(arrFeeds[sender.tag].link!)
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
            sender.isSelected = false
            
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
            tableView.reloadData()
        }
        
    }
    
    
    
    func isBookMark(link : String) -> Bool
    {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
        let ind = appDel.arrBookMarkLink.firstIndex(of: link) ?? -1
        if ind > -1
        {
            return true
        }
        
        return false
    }
    
    
}

//MARK:- Collection View Delegate & Data Source
extension welcomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row % 5 == 0 && indexPath.row != 0
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdsCollectionViewCell", for: indexPath) as! AdsCollectionViewCell
            cell.controller = self
            
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PositifeedyCell", for: indexPath) as! PositifeedyCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellSize: CGSize = collectionView.bounds.size
        
        cellSize.width -= collectionView.contentInset.left
        cellSize.width -= collectionView.contentInset.right
        
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Item selected at \(indexPath.row)")
    }
}

//MARK:- UITableViewDataSource
extension welcomeViewController : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return arrFeeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.row % 5 == 0 && indexPath.row != 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "adsCell", for: indexPath) as! AdsTableViewCell
            cell.controller = self
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FeedCell
      
        let feed = arrFeeds[indexPath.row]
        
        let date =  feed.time?.toDate()
        
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
        
        let feed = arrFeeds[indexPath.row]
        
        let webVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
        webVC.url = arrFeeds[indexPath.row].link
        webVC.myDocID = self.myDocID
        webVC.isBookmark = isBookMark(link: feed.link!)
        navigationController?.pushViewController(webVC, animated: true)
        
    }
    
}

