//
//  NewsArticalScreenViewController.swift
//  positifeedy
//
//  Created by iMac on 22/04/21.
//  Copyright © 2021 Evyn Gonzalez . All rights reserved.
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
import EMPageViewController
import VideoBackground
import LinkPresentation
import UIImageColors
import DLLocalNotifications

class NewsArticalScreenViewController: UIViewController,UIScrollViewDelegate {
    
    @IBOutlet weak var videoShowHideVIew: UIView!
   
    @IBOutlet weak var gradintviewforbg: Gradient!
    @IBOutlet weak var lbltitle: UILabel!
    
    @IBOutlet weak var lblBGAffirmation: UILabel!
    
    @IBOutlet weak var imgTest: UIImageView!
    @IBOutlet weak var loaderIndicator: UIActivityIndicatorView!
    
    //@IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var greadintView: Gradient!
    //@IBOutlet weak var dailyAffirmation: UILabel!
    //@IBOutlet weak var doubletabview: UIView!
    
    var IsSubscripted = false
    var Message = [String]()
    //@IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var tableview: UITableView!
    var myDocId : String!
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
    
    var greetings: [String] = ["From us"]
    var greetingColors: [UIColor] = [
        UIColor(red: 108.0/255.0, green: 122.0/255.0, blue: 137.0/255.0, alpha: 1.0),
        UIColor(red: 135.0/255.0, green: 211.0/255.0, blue: 124.0/255.0, alpha: 1.0),
        UIColor(red: 34.0/255.0, green: 167.0/255.0, blue: 240.0/255.0, alpha: 1.0),
        UIColor(red: 245.0/255.0, green: 171.0/255.0, blue: 53.0/255.0, alpha: 1.0),
        UIColor(red: 214.0/255.0, green: 69.0/255.0, blue: 65.0/255.0, alpha: 1.0)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblBGAffirmation.text = currentAffirmationMessage
        
        loaderIndicator.startAnimating()
        loaderIndicator.isHidden = false
        
        self.greadintView.endColor = .clear
        self.gradintviewforbg.startColor = .clear
        
        self.tableview.separatorStyle = UITableViewCell.SeparatorStyle.none
        gradintviewforbg.isHidden = true
        tabBarController?.tabBar.isHidden = false
        //        videoShowHideVIew.isHidden = true
//        setupVideo View()
//        dailyAffirmation.isUserInteractionEnabled = false
        self.navigationController?.navigationBar.isHidden = true
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 200.0
//        self.scrollview.delegate = self
        self.arrTempararyArray = NSMutableArray.init()
        self.arrBookMarkArrray = NSMutableArray.init()
        
        tableview.register(UINib(nibName: "FeedCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableview.register(UINib(nibName: "FeedyCellUr", bundle: nil), forCellReuseIdentifier: "FeedyCellUr")
        
        tableview.register(UINib(nibName: "AdsTableViewCell", bundle: nil), forCellReuseIdentifier: "adsCell")
        tableview.register(UINib(nibName: "AdsTableViewNew", bundle: nil), forCellReuseIdentifier: "AdsTableViewNew")

        tableview.tableFooterView = UIView()
        tableview.dataSource = self
        tableview.delegate = self

        
//         UIApplication.shared.statusBarView?.backgroundColor = UIColor.green
        
        getBookmarsData()
        getBookmarsDataFeedy()
        
        //getFeeds()
        getThemes()
        getPositifeedy()
        
        let scheduler = DLNotificationScheduler()
        scheduler.getScheduledNotifications { (request) in
            request?.forEach({ (item) in
                if(item.identifier.contains("manifest")){
                    scheduler.cancelNotification(identifier: item.identifier)
                }
            })
            self.setupNotification()
        }

        
        
        gestureaddonbackground()
        gestureAdd()
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableview.addSubview(refreshControl) // not required when using UITableViewController
        
    }
    
    func getThemes() {
        var db: Firestore!
        db = Firestore.firestore()
        db.collection("Themes").getDocuments { (snap, error) in
            if error != nil
            {
                print("error ", error!.localizedDescription)
                return
            }
            
            for doc in snap?.documents ?? []
            {
                let  d = doc.data()
                if d.count > 0{
                    var arr : [[String : Any]] = []
                    arrTheme = d["Themes"]! as? [[String : Any]] ?? []
                    
                    for item in arrTheme {
                        let data = item as? NSDictionary
                        let isFree = data?.value(forKey: "isFree") as? Bool ?? false
                        if(isFree){
                            arr.append(item)
                        }
                    }
                    for item in arrTheme {
                        let data = item as? NSDictionary
                        let isFree = data?.value(forKey: "isFree") as? Bool ?? false
                        if(!isFree){
                            arr.append(item)
                        }
                    }
                    
                    arrTheme = arr
                    print(arrTheme)
                    
                    if(arrTheme.count > 0){
                        self.getProfileData()
                        break
                    }
                }
            }
        }
    }
        
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        print("Refreshing")
        
        getBookmarsData()
        getBookmarsDataFeedy()
        
        //getFeeds()
        getPositifeedy()


    }
    
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         
     }
    
    @IBAction func btnLogoutClicked(_ sender: Any) {
//        let alertVC = UIAlertController(title: "Postifeedy", message: "Are you sure?", preferredStyle: UIAlertController.Style.alert)
//
//        alertVC.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
//        alertVC.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
//
//            do
//            {
//                try   Auth.auth().signOut()
//
//                let appDel =  UIApplication.shared.delegate as! AppDelegate
//                appDel.arrBookMarkLink = []
//
//                UserDefaults.standard.set(false, forKey: "isLogin")
//                let scheduler = DLNotificationScheduler()
//                scheduler.cancelNotif ication(identifier: "Manifest")
//
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let loginVC = storyboard.instantiateViewController(withIdentifier: "logInViewController") as! logInViewController
//
//
//                let nav = UINavigationController(rootViewController: loginVC )
//                nav.setNavigationBarHidden(true, animated: false)
//
//                appDel.window?.rootViewController = nav
//                appDel.window?.makeKeyAndVisible()
//            }
//            catch
//            {
//                self.view.makeToast(error.localizedDescription)
//            }
//        }))
//
//        present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func btnCategoriesClicked(_ sender: Any) {
        
        if(dict.allKeys.count <= 0){
            return
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "categoriesViewController") as! categoriesViewController
        vc.IsSubscription = IsSubscripted
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnThemeClicked(_ sender: Any) {
        
        if(arrTheme.count<=0){
            return
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "chengethemeViewController") as! chengethemeViewController
        vc.IsSubscription = IsSubscripted
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:- SCrollview Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView!) {
        gradintviewforbg.isHidden = false
//        print(tableview.contentOffset.y)
        if(tableview.contentOffset.y >= 0 && tableview.contentOffset.y <= 150.0) {
            let  percent = (tableview.contentOffset.y / 180);
             self.gradintviewforbg.alpha = percent;

          } else if (tableview.contentOffset.y > 180.0){
                
            self.gradintviewforbg.alpha = 0.8;

          } else if (tableview.contentOffset.y < 0) {
                self.gradintviewforbg.alpha = 0
          }
//              print(self.scrollview.contentOffset.y)
    }
    override func viewWillAppear(_ animated: Bool) {
        lblBGAffirmation.isHidden = true

        loadCategoriData()
        self.tableview.reloadData()
        let data = UserDefaults.standard.data(forKey: "UserProfileImage") ?? Data()
        if(data.count > 0){
            let image = UIImage(data: data)!
            
            self.tabBarController?.tabBar.items?[3].image = image.resizedImage().roundedImageWithBorder(width: 0)!.withRenderingMode(.alwaysOriginal)
            self.tabBarController?.tabBar.items?[3].selectedImage = image.resizedImage().roundedImageWithBorder(width: 2)!.withRenderingMode(.alwaysOriginal)
        }else{
            
            let image = UIImage(named: "profile-placeholder-big")!
            
            self.tabBarController?.tabBar.items?[3].image = image.resizedImage().roundedImageWithBorder(width: 0)!.withRenderingMode(.alwaysOriginal)
            self.tabBarController?.tabBar.items?[3].selectedImage = image.resizedImage().roundedImageWithBorder(width: 2)!.withRenderingMode(.alwaysOriginal)

            
        }
        
        tabBarController?.tabBar.isHidden = false
        super.viewWillAppear(animated)
        setNavTitle(title : "positifeedy")
        self.getBookmarsDataOther()
        self.navigationController?.navigationBar.isHidden = true
        
        if(UserDefaults.standard.bool(forKey: "IsThemeChange")){
            UserDefaults.standard.set(false, forKey: "IsThemeChange")
            UserDefaults.standard.synchronize()
            getProfileData()
        }

    }
    func gestureaddonbackground()
    {
        let tap1 = UITapGestureRecognizer(target: self, action:#selector(doubleTappedonbackground))
           tap1.numberOfTapsRequired = 2
          // doubletabview.addGestureRecognizer(tap)
           videoShowHideVIew.addGestureRecognizer(tap1)
    }
    @objc func doubleTappedonbackground() {
        greadintView.isHidden = false
//        doubletabview.isHidden = false
        tableview.isHidden = false
//        scrollview.isHidden = false
        videoShowHideVIew.isHidden = true
      tabBarController?.tabBar.isHidden = false
        gradintviewforbg.alpha = oldAlpha
        lblBGAffirmation.isHidden = true
        
    }
   func gestureAdd()
   {
    let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
    tap.numberOfTapsRequired = 2
//    doubletabview.addGestureRecognizer(tap)
   
    }
    var oldAlpha : CGFloat = 0.0
    @objc func doubleTapped() {
//        scrollview.isHidden = true
        greadintView.isHidden = true
//        doubletabview.isHidden = true
        tableview.isHidden = true
        tabBarController?.tabBar.isHidden = true
         videoShowHideVIew.isHidden = false
        oldAlpha = gradintviewforbg.alpha
        gradintviewforbg.alpha = 0.0
        
        lblBGAffirmation.isHidden = false
    }
    
    
    var BGVideoView = UIView()
    var videoBG = VideoBackgroundURL()
    //let BGImageView = UIImageView()
    var IsLightText = true
    private func setupVideoView() {
        
//        guard let videoPath = Bundle.main.path(forResource: "splash", ofType: "mov") else {
//                return
//        }
//
//        let options = VideoOptions(pathToVideo: videoPath, pathToImage: "",
//                                   isMuted: true,
//                                   shouldLoop: true)
//        let videoView = VideoBackground(frame: view.frame, options: options)
//        view.insertSubview(videoView, at: 0)
                
        let dict = arrTheme[0]
        let defaultThemeUrl = dict["themeUrl"] as! String
        let defaultThemeStatus = dict["isVideo"] as! Bool
        
        var isVideo = themeData.value(forKey: "isVideo") as? Bool ?? true
        IsLightText = themeData.value(forKey: "TextColorIsLight") as? Bool ?? true
        
        if(IsLightText){
            lblBGAffirmation.textColor = .white
        }else{
            lblBGAffirmation.textColor = .black
        }
        
        self.tableview.reloadData()

        var url = themeData.value(forKey: "themeUrl") as? String ?? ""
        if(url == ""){
            url = defaultThemeUrl
            isVideo = defaultThemeStatus
        }
        
//        url = "http://techslides.com/demos/sample-videos/small.mp4"
        
        self.greadintView.endColor = .clear
        self.gradintviewforbg.startColor = .clear
        
        var maxColor = themeData.value(forKey: "maxColor") as? String ?? ""
        
        let ownTheme = UserDefaults.standard.bool(forKey: "OwnTheme")
        if(ownTheme){
            let selectedTheme = UserDefaults.standard.string(forKey: "SelectedTheme")
            if(selectedTheme != nil && selectedTheme != ""){
                let ownThemeType = UserDefaults.standard.string(forKey: "SelectedThemeType")
                if(ownThemeType != nil && ownThemeType == "Image"){
                    isVideo = false
                    let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let destinationUrl = docsUrl.appendingPathComponent("Themes").appendingPathComponent(selectedTheme!)
                    url = destinationUrl.absoluteString
                }
                if(ownThemeType != nil && ownThemeType == "Video"){
                    isVideo = true
                    let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let destinationUrl = docsUrl.appendingPathComponent("Themes").appendingPathComponent(selectedTheme!)
                    url = destinationUrl.absoluteString
                    maxColor = UserDefaults.standard.value(forKey: "maxColor")as? String ?? ""
                    
                }
                UserDefaults.standard.set(false, forKey: "OwnTheme")
                UserDefaults.standard.set("", forKey: "SelectedTheme")
                UserDefaults.standard.removeObject(forKey: "SelectedThemeType")
            }
        }


        if(isVideo){
            UserDefaults.standard.set(true, forKey:"IsVideo")
            UserDefaults.standard.synchronize()
            
            let volume = themeData.value(forKey: "volume") as? Float ?? 0.0
            
            
            if(maxColor != ""){
                self.greadintView.endColor = colorWithHexString(hexString: maxColor)
                self.gradintviewforbg.startColor = colorWithHexString(hexString: maxColor)
            }else{
                self.greadintView.endColor = defaultGradientColor
                self.gradintviewforbg.startColor = defaultGradientColor
            }
            
            let asset = videoPlayer.currentItem?.asset
            if asset == nil {
              print("nil") // It is not nil. It doesn't go within this if-clause
            }
            
//            var currentPlayerUrl = ""
//            if let urlAsset = asset as? AVURLAsset {
//                currentPlayerUrl = urlAsset.url.absoluteString
//            }
//
//            if(defaultThemeUrl == url && url == currentPlayerUrl){
//                videoPlayer.volume = volume
//                return
//            }
            
            var options = VideoOptionsURL(
                pathToVideo: url,
                pathToImage: "",
                volume: volume,
                shouldLoop: true
            )
            
            options = VideoOptionsURL(
                pathToVideo: url,
                pathToImage: "",
                volume: volume,
                shouldLoop: true
            )
            
//            let col = image?.getPixelColor(pos: CGPoint(x: 0, y: 0))
//            self.greadintView.endColor = col!
//            self.gradintviewforbg.startColor = col!

            BGVideoView = UIView.init(frame: view.frame)
            
            videoPlayer.pause()
            videoPlayer = AVPlayer()
            playerLayer?.player?.pause()

            videoBG.removeFromSuperview()
            videoBG = VideoBackgroundURL(frame: view.frame, options: options)
            
            BGVideoView.insertSubview(videoBG, at: 0)
            //BGImageView.removeFromSuperview()
            
            BGVideoView.isHidden = false
            imgTest.isHidden = true
            
            view.insertSubview(BGVideoView, at: 0)
        }else{
            
            UserDefaults.standard.set(false, forKey:"IsVideo")
            UserDefaults.standard.synchronize()
            
            //BGImageView.frame = view.frame
            
            let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationUrl = docsUrl.appendingPathComponent("Themes").appendingPathComponent(URL(string: url)!.lastPathComponent)

            if(FileManager().fileExists(atPath: destinationUrl.path)){
                let imageURL = destinationUrl
                let image    = UIImage(contentsOfFile: imageURL.path)
                imgTest.image = image
                
                let col = image?.getColors({ (colors) in
                    self.greadintView.endColor = colors?.primary ?? defaultGradientColor
                    self.gradintviewforbg.startColor = colors?.primary ?? defaultGradientColor

                })
                
                //imgTest.image = image
                //imgTest.frame = view.frame
            }else{
                
                imgTest.sd_setImage(with: URL(string: url), placeholderImage: UIImage.init(named: "album_placeholder"), options: .highPriority) { (image, error, type, url) in
                    do{
                        do {
                            try FileManager.default.createDirectory(atPath: docsUrl.appendingPathComponent("Themes").path, withIntermediateDirectories: true, attributes: nil)
                        } catch {
                            print(error.localizedDescription)
                        }
                        let path = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                        let newPath = path.appendingPathComponent("Themes").appendingPathComponent(url!.lastPathComponent)
                        let imageData = image!.jpegData(compressionQuality: 1.0)
                        let result = try imageData!.write(to: newPath)
                        print(result)
                        
                        
                        let col = image?.getColors({ (colors) in
                            self.greadintView.endColor = colors?.primary ?? defaultGradientColor
                            self.gradintviewforbg.startColor = colors?.primary ?? defaultGradientColor
                        })

                    }catch{
                        print("Save Image Error")
                    }
                }
            }
            
            //BGImageView.contentMode = .scaleAspectFill
            
            BGVideoView.removeFromSuperview()
            
            BGVideoView.isHidden = true
            imgTest.isHidden = false
            
            videoPlayer.pause()
            videoPlayer = AVPlayer()
            playerLayer?.player?.pause()

//            view.insertSubview(BGImageView, at: 0)
        }
        

//        let videoURL = URL(string: "http://techslides.com/demos/sample-videos/small.mp4")
//        let player = AVPlayer(url: videoURL!)
//        player.actionAtItemEnd = .none
//        player.isMuted = true
//
//        let playerLayer = AVPlayerLayer(player: player)
//        playerLayer.frame = view.frame
//        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//
//        let newView = UIView(frame: playerLayer.frame)
//        newView.layer.addSublayer(playerLayer)
//
//        view.insertSubview(newView, at: 0)
//
//        player.play()
        
    }
    
    var themeData = NSMutableDictionary()
    //MARK:- ForFeting Name
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
                                                        
                            let fname = (d["firstname"] as! String)
                            self.themeData = (d["CurrentTheme"] as? NSDictionary ?? NSDictionary()).mutableCopy() as? NSMutableDictionary ?? NSMutableDictionary()
                            
                            self.setupVideoView()
                            if let strURL = (d["profileImage"] as? String)
                            {
                               let url = URL(string: strURL)!
                               do
                               {
                                   DispatchQueue.main.async {
                                    
                                    if !NetworkState.isConnected(){
                                        let data = try! Data(contentsOf: url)
                                        let image = UIImage(data: data)!
                                        UserDefaults.standard.setValue(data, forKey: "UserProfileImage")
                                        UserDefaults.standard.synchronize()
                    
//                                        let resized: UIImage = image.resizedImage().roundedImageWithBorder(width: 2, color: UIColor.green)!.withRenderingMode(.alwaysOriginal)
                                        self.tabBarController?.tabBar.items?[3].image = image.resizedImage().roundedImageWithBorder(width: 0)!.withRenderingMode(.alwaysOriginal)
                                        self.tabBarController?.tabBar.items?[3].selectedImage = image.resizedImage().roundedImageWithBorder(width: 2)!.withRenderingMode(.alwaysOriginal)                                    }
                                   }
                               }catch{
                                   self.view.makeToast("Profile image not found")
                               }
                           }
                            
                            // let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate()) Swift 2 legacy
                            let hour = Calendar.current.component(.hour, from: Date())
                            switch hour {
                            case 6..<12 :
                                self.lbltitle.text = String.init(format: "Good Morning, \(fname)! %@" ,"")
                                //self.lblsun.image =  UIImage.init(named: "sun")
                            case 12 :
                                self.lbltitle.text = String.init(format: "Good Afternoon, \(fname)! %@","")
                                //self.lblsun.image =  UIImage.init(named: "sun")
                            case 13..<17 :
                                self.lbltitle.text = String.init(format: "Good Afternoon, \(fname)! %@","")
                                //self.lblsun.image =  UIImage.init(named: "sun")
                            case 17..<22 :
                                self.lbltitle.text = String.init(format: "Good Evening, \(fname)! %@","")
                               // self.lblsun.image =  UIImage.init(named: "moon")
                            default:
                                self.lbltitle.text = String.init(format: "Good Night, \(fname)! %@","")
                               // self.lblsun.image =  UIImage.init(named: "moon")
                            }
                            
                            // subscription :
                            let subscription = d["Subscription"] as? String
                            if subscription != nil
                            {
                                if subscription == "0"
                                {
                                    // Not subscribe !
                                    self.IsSubscripted = false
                                   // self.suscriptionView.isHidden = false
                                    
                                }else
                                {
                                    // subscribed :
                                    self.IsSubscripted = true
                                    //self.suscriptionView.isHidden = true
                                }
                                
                            }else
                            {
                                
                                 // self.suscriptionView.isHidden = false
                                   let d = ["Subscription" : "0"]
                                   var db: Firestore!
                                   db = Firestore.firestore()
                                   db.collection("users").document(self.myDocId!).updateData(d) { (error) in
                                       if error != nil
                                       {
                                           print(error!.localizedDescription)
                                       }
                                   }
                                   print("point added :")
                            }
                            
                            
                            
                            //---------------- START -------------------//
                                  // list of added journal :
    //                               let arr = d["JournalEntry"] as? NSArray
    //                              if arr != nil
    //                              {
    //                                  if arr!.count > 0
    //                                  {
    //                                      self.arrListOfJourny = NSMutableArray.init(array: arr!)
    //                                      print("My Journal :\(self.arrListOfJourny)")
    //
    //                                       for i in (0..<self.arrListOfJourny.count)
    //                                       {
    //                                           let dict = self.arrListOfJourny.object(at: i) as? NSDictionary
    //                                           let point = Int((dict?.value(forKey: "point") as? String)!) ?? 0
    //                                           self.currentPoint = self.currentPoint + point
    //                                       }
    //                                  }
    //                                   print("Self current :\(self.currentPoint)")
    //
    //                              }
    //                              else
    //                              {
    //                                  print("No JournalEntry Object !")
    //                              }
                                   //---------------- END -----------------------//
                                   
                                   
                                   //my point
                                   //---------------- START -------------------//
                                        let mypoint = d["myPoint"] as? String
                                       if mypoint != nil
                                       {
                                             //if mypoint == "0"
                                            //{
                                                // first time set point :
    //                                            let str = String.init(format: "%d", self.currentPoint)
    //                                            let d = ["myPoint" : str]
    //                                            var db: Firestore!
    //                                            db = Firestore.firestore()
    //                                            db.collection("users").document(self.myDocId!).updateData(d) { (error) in
    //                                                if error != nil
    //                                                {
    //                                                    print(error!.localizedDescription)
    //                                                }
    //                                            }
                                            //}
                                            print("================point added :==================")
                                        
                                        
                                        let mypoint = d["myPoint"] as? String
                                        print("My point :\(mypoint)")
                                        var point = Int(mypoint!)
                                       
                                          if point! > 0
                                           {
                                               
                                               let booked_date = UserDefaults.standard.object(forKey: PREF_BOOKED_DATE) as? String
                                               if booked_date != nil
                                               {
                                                   let dateFormatter = DateFormatter()
                                                   dateFormatter.dateFormat = "yyyy-MM-dd"
                                                   let start_date = dateFormatter.date(from: booked_date!)
                                                   let final_date = Date().localDate()
                                                   let diff = final_date.interval(ofComponent: .day, fromDate: start_date!)
                                                   print("diffrent day :\(diff)")
                                                  //self.view.makeToast("diffrent day 4:\(diff) :  store date: \(start_date) and final date :\(final_date)")
                                                   if diff >= 3
                                                   {
                                                       let set_new_point = point! - 2
                                                       let str = String.init(format: "%d",set_new_point)
                                                       let d = ["myPoint" : str]
                                                       var db: Firestore!
                                                       db = Firestore.firestore()
                                                       db.collection("users").document(self.myDocId!).updateData(d) { (error) in
                                                           if error != nil
                                                           {
                                                               print(error!.localizedDescription)
                                                           }
                                                       }
                                                       let date1 = Date()
                                                       let dateFormatter1 = DateFormatter()
                                                       dateFormatter1.dateFormat = "yyyy-MM-dd"
                                                       let dateString = dateFormatter1.string(from: date1)
                                                       UserDefaults.standard.setValue(dateString, forKey: PREF_BOOKED_DATE)
                                                   }
                                               }
                                            
                                           }
                                           else
                                           {
                                              // let set_new_point = point! - 5
                                               let d = ["myPoint" : "0"]
                                               var db: Firestore!
                                               db = Firestore.firestore()
                                               db.collection("users").document(self.myDocId!).updateData(d) { (error) in
                                                   if error != nil
                                                   {
                                                       print(error!.localizedDescription)
                                                   }
                                               }
                                           }
                                           
                                           print("Goal :\(point)")
                                           
                                           if point == 0
                                           {
                                            // beginer
                                                let d1 = ["mindstatus" : "beginner".capitalized]
                                                    var db1: Firestore!
                                                    db1 = Firestore.firestore()
                                                    db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
                                                        if error != nil
                                                        {
                                                            print(error!.localizedDescription)
                                                        }
                                                    }
                                            
                                               // Beginner
    //                                           self.lbl1.isHidden = true
    //                                           self.imgone.isHidden = true
    //
    //                                           self.lbl2.isHidden = true
    //                                           self.imgtwo.isHidden = true
    //
    //                                           self.lbl3.isHidden = true
    //                                           self.imgthree.isHidden = true
    //
    //                                           self.lbl4.isHidden = true
    //                                           self.imgFour.isHidden = true
    //
    //                                           //self.lbl.isHidden = true
    //                                           self.imgFive.isHidden = true
                                            
    //                                        self.lbl1.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                           // self.imgone.image = UIImage.init(named: "circle")
    //
    //                                        self.lbl2.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                           // self.imgtwo.image = UIImage.init(named: "circle_s")
    //
    //                                        self.lbl3.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                          // self.imgthree.image = UIImage.init(named: "circle_s")
    //
    //                                        self.lbl4.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                           // self.imgFour.image = UIImage.init(named: "circle_s")
    //
                                          //  self.imgFive.image = UIImage.init(named: "circle_s")
                                            
                                            
                                               
                                               
                                           }
                                           else if point! > 0 && point! < 25
                                           {
                                                let d1 = ["mindstatus" : "beginner".capitalized]
                                                var db1: Firestore!
                                                db1 = Firestore.firestore()
                                                db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
                                                    if error != nil
                                                    {
                                                        print(error!.localizedDescription)
                                                    }
                                                }
                                              
    //                                           // beginer
    //                                           self.lbl1.isHidden = true
    //                                           self.imgone.isHidden = false
    //
    //                                           self.lbl2.isHidden = true
    //                                           self.imgtwo.isHidden = true
    //
    //                                           self.lbl3.isHidden = true
    //                                           self.imgthree.isHidden = true
    //
    //                                           self.lbl4.isHidden = true
    //                                           self.imgFour.isHidden = true
    //
    //                                           //self.lbl.isHidden = true
    //                                           self.imgFive.isHidden = true
                                            
                                            
                                            //self.lbl1.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                          //  self.imgone.image = UIImage.init(named: "circle")
                                            
    //                                        self.lbl2.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                          //  self.imgtwo.image = UIImage.init(named: "circle_s")
    //
    //                                        self.lbl3.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                           // self.imgthree.image = UIImage.init(named: "circle_s")
    //
    //                                        self.lbl4.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                           // self.imgFour.image = UIImage.init(named: "circle_s")
    //
                                           // self.imgFive.image = UIImage.init(named: "circle_s")
                                            
                                               
                                           }
                                           else if point! >= 25 && point! < 50
                                           {
                                             //Intermediate
                                               
                                               let d1 = ["mindstatus" : "intermediate".capitalized]
                                                 var db1: Firestore!
                                                 db1 = Firestore.firestore()
                                                 db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
                                                     if error != nil
                                                     {
                                                         print(error!.localizedDescription)
                                                     }
                                                 }
                                               
                                            
    //                                           self.lbl1.isHidden = false
    //                                           self.imgone.isHidden = false
    //
    //                                           self.lbl2.isHidden = true
    //                                           self.imgtwo.isHidden = false
    //
    //                                           self.lbl3.isHidden = true
    //                                           self.imgthree.isHidden = true
    //
    //                                           self.lbl4.isHidden = true
    //                                           self.imgFour.isHidden = true
    //
    //                                           //self.lbl.isHidden = true
    //                                           self.imgFive.isHidden = true
                                            
                                                //self.lbl1.backgroundColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
                                               // self.imgone.image = UIImage.init(named: "circle_s")
                                                
                                                //self.lbl2.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                              //  self.imgtwo.image = UIImage.init(named: "circle")
                                                
    //                                            self.lbl3.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                             //   self.imgthree.image = UIImage.init(named: "circle_s")
    //
    //                                            self.lbl4.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                              //  self.imgFour.image = UIImage.init(named: "circle_s")
    //
                                              //  self.imgFive.image = UIImage.init(named: "circle_s")
                                            
                                            
                                               
                                           }
                                           else if point! >= 50 && point! < 75
                                           {
                                            //Advanced
                                            let d1 = ["mindstatus" : "advanced".capitalized]
                                            var db1: Firestore!
                                            db1 = Firestore.firestore()
                                            db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
                                                if error != nil
                                                {
                                                    print(error!.localizedDescription)
                                                }
                                            }
                                                   
    //                                           self.lbl1.isHidden = false
    //                                           self.imgone.isHidden = false
    //
    //                                           self.lbl2.isHidden = false
    //                                           self.imgtwo.isHidden = false
    //
    //                                           self.lbl3.isHidden = true
    //                                           self.imgthree.isHidden = false
    //
    //                                           self.lbl4.isHidden = true
    //                                           self.imgFour.isHidden = true
    //
    //                                           //self.lbl.isHidden = true
    //                                           self.imgFive.isHidden = true
                                            
    //                                                self.lbl1.backgroundColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
                                                   // self.imgone.image = UIImage.init(named: "circle_s")
    //
    //                                                self.lbl2.backgroundColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
                                                  //  self.imgtwo.image = UIImage.init(named: "circle_s")
    //
                                                    //self.lbl3.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                                   // self.imgthree.image = UIImage.init(named: "circle")
    //
    //                                                self.lbl4.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                                    //self.imgFour.image = UIImage.init(named: "circle_s")

                                                    //self.imgFive.image = UIImage.init(named: "circle_s")
                                            
                                            
                                           }
                                           else if point! >= 75 && point! < 100
                                           {
                                            //Expert
        
                                              let d1 = ["mindstatus" : "expert".capitalized]
                                              var db1: Firestore!
                                              db1 = Firestore.firestore()
                                              db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
                                                  if error != nil
                                                  {
                                                      print(error!.localizedDescription)
                                                  }
                                              }
                                               
    //                                           self.lbl1.isHidden = false
    //                                           self.imgone.isHidden = false
    //
    //                                           self.lbl2.isHidden = false
    //                                           self.imgtwo.isHidden = false
    //
    //                                           self.lbl3.isHidden = false
    //                                           self.imgthree.isHidden = false
    //
    //                                           self.lbl4.isHidden = true
    //                                           self.imgFour.isHidden = false
    //
    //                                           //self.lbl.isHidden = true
    //                                           self.imgFive.isHidden = true
                                            
                                            
    //                                            self.lbl1.backgroundColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
                                              //  self.imgone.image = UIImage.init(named: "circle_s")
    //
    //                                            self.lbl2.backgroundColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
                                             //   self.imgtwo.image = UIImage.init(named: "circle_s")
    //
    //                                            self.lbl3.backgroundColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
                                               // self.imgthree.image = UIImage.init(named: "circle_s")
    //
    //                                            self.lbl4.backgroundColor = UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                                               // self.imgFour.image = UIImage.init(named: "circle")
                                                
                                              //  self.imgFive.image = UIImage.init(named: "circle_s")
                                            
                                            
                                           }
                                           else
                                           {
                                                    let d1 = ["mindstatus" : "master".capitalized]
                                                     var db1: Firestore!
                                                     db1 = Firestore.firestore()
                                                     db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
                                                         if error != nil
                                                         {
                                                             print(error!.localizedDescription)
                                                         }
                                                     }
                                            //Master
    //                                              self.lbl1.isHidden = false
    //                                             self.imgone.isHidden = false
    //
    //                                             self.lbl2.isHidden = false
    //                                             self.imgtwo.isHidden = false
    //
    //                                             self.lbl3.isHidden = false
    //                                             self.imgthree.isHidden = false
    //
    //                                             self.lbl4.isHidden = false
    //                                             self.imgFour.isHidden = false
    //
    //                                             //self.lbl.isHidden = true
    //                                             self.imgFive.isHidden = false
                                            
    //                                                self.lbl1.backgroundColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
                                                  //  self.imgone.image = UIImage.init(named: "circle_s")
    //
    //                                                self.lbl2.backgroundColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
                                                  //  self.imgtwo.image = UIImage.init(named: "circle_s")
    //
    //                                                self.lbl3.backgroundColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
                                                 //   self.imgthree.image = UIImage.init(named: "circle_s")
    //
    //                                                self.lbl4.backgroundColor = UIColor.init(red: 123/255, green: 246/255, blue: 171/255, alpha: 1)
                                                  //  self.imgFour.image = UIImage.init(named: "circle_s")
                                                    
                                                  //  self.imgFive.image = UIImage.init(named: "circle")
                                            
                                            
                                           }
                                           
                                       }
                                       else
                                       {
                                        
                                           let d1 = ["mindstatus" : "beginner".capitalized]
                                           var db1: Firestore!
                                           db1 = Firestore.firestore()
                                           db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
                                               if error != nil
                                               {
                                                   print(error!.localizedDescription)
                                               }
                                           }
                                        
                                        
                                          // let str = String.init(format: "%d", self.currentPoint)
                                         //  let d = ["myPoint" : str]
                                           var db: Firestore!
                                           db = Firestore.firestore()
                                           db.collection("users").document(self.myDocId!).updateData(d) { (error) in
                                               if error != nil
                                               {
                                                   print(error!.localizedDescription)
                                               }
                                           }
                                           print("point added :")
                                       }
                                   
                                   //---------------- END -------------------//
                                // self.checkIfPurchaed()
                         }
                     }
                 }
             }
         }
    
    func setupNotification()
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
                       
                       let arr = d["ManifestEntry"] as? NSArray
                       var arrMyManifestEntry = NSMutableArray()
                        var isActiveManifestAvailable = false
                       if arr != nil
                       {
                           if arr!.count > 0
                           {
                               arrMyManifestEntry = NSMutableArray.init(array: arr!)
                               print("My Manifest :\(arrMyManifestEntry)")
                               for i in (0..<arrMyManifestEntry.count)
                               {
                                let dict = (arrMyManifestEntry.object(at: i) as? NSDictionary ?? NSDictionary()).mutableCopy() as? NSMutableDictionary ?? NSMutableDictionary()
                                
                                if dict.object(forKey: "isActive") != nil
                                   {
                                       let active = dict.value(forKey: "isActive") as? Bool ?? false
                                       if(active){
                                           
                                            isActiveManifestAvailable = true
                                            print(dict)
                                            
                                            let title = "Manifestation"
                                            let message = dict.value(forKey: "answer") as? String ?? "NA"
                                            let strSelectedDate = dict.value(forKey: "manifestTime") as? String ?? ""
                                            let strEndDate = dict.value(forKey: "endDate") as? String ?? ""
                                            let selectedDay = dict.value(forKey: "manifestDay")as? String ?? ""
                                            
                                            let totalSecondsInDay = 24 * 60 * 60    //86400 //DayHour * HourMinute * MinuteSecond

                                            
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                                            let startDate = dateFormatter.date(from:strSelectedDate)!

                                            var newDate = startDate
                                            newDate = Calendar.current.date(bySettingHour: startDate.hour, minute: startDate.minute, second: 0, of: Date())!

                                            
                                            let dateFormatter1 = DateFormatter()
                                            dateFormatter1.locale = Locale(identifier: "en_US_POSIX")
                                            dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                            let endDate = Calendar.current.date(byAdding: .month, value: 1, to: newDate)!
                                            let newEnd = dateFormatter1.string(from: endDate)
                                            let newStart = dateFormatter1.string(from: newDate)
                                            
                                            dict.setValue(newStart, forKey: "startDate")
                                            dict.setValue(newEnd, forKey: "endDate")
                                            
                                            print("\(newStart) - \(newEnd)")
                                        
                                            print("Dinal J" + "\(newDate.hour):\(newDate.minute):\(newDate.second)")
                                            
                                            let scheduler1 = DLNotificationScheduler()
                                            scheduler1.getScheduledNotifications { (request) in
                                                request?.forEach({ (item) in
                                                    if(item.identifier.contains("journal")){
                                                        scheduler1.cancelNotification(identifier: item.identifier)
                                                    }
                                                })
                                            }
                                            
                                            let scheduler = DLNotificationScheduler()

                                            if(selectedDay == "every day"){
                                                let interval = Double(totalSecondsInDay)
                                                scheduler.repeatsFromToDate(identifier: "manifest", alertTitle: title, alertBody: message, fromDate: newDate, toDate: endDate, interval: interval, repeats: .none )
                                                scheduler.scheduleAllNotifications()
                                            }else if(selectedDay == "once a week"){
                                                let interval = Double(totalSecondsInDay * 7)
                                                scheduler.repeatsFromToDate(identifier: "manifest", alertTitle: title, alertBody: message, fromDate: newDate, toDate: endDate, interval: interval, repeats: .none )
                                                scheduler.scheduleAllNotifications()

                                            }else if(selectedDay == "every 3 days"){
                                                let interval = Double(totalSecondsInDay * 3)
                                                scheduler.repeatsFromToDate(identifier: "manifest", alertTitle: title, alertBody: message, fromDate: newDate, toDate: endDate, interval: interval, repeats: .none )
                                                scheduler.scheduleAllNotifications()
                                            }
                                                                                        
                                            arrMyManifestEntry.replaceObject(at: i, with: dict)
                                            
                                            
                                            let d = ["ManifestEntry" : arrMyManifestEntry]

                                            db.collection("users").document(self.myDocId!).updateData(d) { (error) in
                                                    if error != nil
                                                    {
                                                        print(error!.localizedDescription)
                                                    }
                                                }
                                            
                                            break
                                       }
                                   }else{
                                       
                                   }
                               }
                           }
                       }
                       
                        if(!isActiveManifestAvailable){
                            let scheduler1 = DLNotificationScheduler()
                            scheduler1.getScheduledNotifications { (request) in
                                request?.forEach({ (item) in
                                    if(item.identifier.contains("journal")){
                                        scheduler1.cancelNotification(identifier: item.identifier)
                                    }
                                })
                                self.setupJournalNotification()
                            }
                        }
                        
                        
                    }
                }
            }
        }
        
    }
    
    func setupJournalNotification()
   {
        var arrQuestionList = [QuestionListItem]()
        let notificationTime = 11

        var db: Firestore!
        db = Firestore.firestore()
        db.collection("QuestionList").getDocuments { (snap, error) in
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
                    let obj = try jsonDecoder.decode([QuestionListItem].self, from: jsonData)
                    arrQuestionList = obj
                    
                    if arrQuestionList.count > 0
                    {
                         var currentInx = UserDefaults.standard.object(forKey: PREF_DAILY_QUESTION_COUNT) as? Int ?? 0
                        
                        var index = 0
                        
                        let hour = Calendar.current.component(.hour, from: Date())
                        if(hour > notificationTime){
                            currentInx += 1
                            index += 1
                        }
                        
                        if(currentInx < 0 || currentInx > (arrQuestionList.count-1)){
                            currentInx = 0
                        }
                        
                        for i in currentInx..<arrQuestionList.count {
                            
                            let questionItem = arrQuestionList[i]
                            
                            var dayComponent    = DateComponents()
                            dayComponent.day    = index

                            var newDate = Date()
                            newDate = Calendar.current.date(bySettingHour: notificationTime, minute: 0, second: 0, of: Date())!
                            
                            let theCalendar     = Calendar.current
                            let nextDate = theCalendar.date(byAdding: dayComponent, to:newDate)!
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            let dateString = dateFormatter.string(from: nextDate)
                            print("DKL :" + dateString)
                             
//                            let interval = Double(500)
//                            scheduler.repeatsFromToDate(identifier: "journal\(i)", alertTitle: "Journal Question", alertBody: questionItem.question ?? "", fromDate: newDate, toDate: newDate, interval: interval, repeats: .none )
//                            scheduler.scheduleAllNotifications()

                            let scheduler = DLNotificationScheduler()

                            let firstNotification = DLNotification(identifier: "journal\(index)", alertTitle: "Journal Question", alertBody: questionItem.question ?? "", date: nextDate)
                            scheduler.scheduleNotification(notification: firstNotification)
                            scheduler.scheduleAllNotifications()
                            
                            if(index>30){
                                break
                            }
                            index += 1
                        }

                        print("Set journal notification completed")
                        
                    }
                }
                catch {
                    print(error)
                }
               
            }
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
                      
                      self.tableview.reloadData()
                      
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
                  
                    self.tableview.reloadData()
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
//                     SVProgressHUD.show()
                    loaderIndicator.startAnimating()
                    loaderIndicator.isHidden = false
                 }
                AF.session.configuration.timeoutIntervalForRequest = 120
               AF.request(Global.feedURL, method: .get,  parameters: nil, encoding: JSONEncoding.default)
                   .responseJSON { response in
                       switch response.result {
                       case .success(let value):
                           if let json = value as? [String: Any] {
                              
                               //SVProgressHUD.dismiss()
                            
                            self.loaderIndicator.stopAnimating()
                            self.loaderIndicator.isHidden = true
                            
                                self.refreshControl.endRefreshing()
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
                                           let dict = temp.object(at: i) as? NSDictionary
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
                                                          self.tableview.reloadData()
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
                     
                     //SVProgressHUD.dismiss()
                      
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
                                    //SVProgressHUD.dismiss()
                                    self.loaderIndicator.stopAnimating()
                                    self.loaderIndicator.isHidden = true
                                    return
                                }
                                
                                guard let shareLink = DynamicLinkComponents.init(link: linkParameter, domainURIPrefix: "https://positifeedy.page.link") else {
                                    //SVProgressHUD.dismiss()
                                    self.loaderIndicator.stopAnimating()
                                    self.loaderIndicator.isHidden = true
                                    return
                                }
                                
                                if let myBundleId = Bundle.main.bundleIdentifier {
                                    shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleId)
                                }
                                
                                shareLink.iOSParameters?.appStoreID = "1484015088"
                                
                                guard let longURL = shareLink.url else {
                                    //SVProgressHUD.dismiss()
                                    self.loaderIndicator.stopAnimating()
                                    self.loaderIndicator.isHidden = true
                                    return
                                }
                                
                                shareLink.shorten { [weak self] (url, warnings, error) in
                                    //SVProgressHUD.dismiss()
                                    self?.loaderIndicator.stopAnimating()
                                    self?.loaderIndicator.isHidden = true
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
        
//        SVProgressHUD.show()
        loaderIndicator.startAnimating()
        loaderIndicator.isHidden = false
        
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
              //SVProgressHUD.dismiss()
            self.loaderIndicator.stopAnimating()
            self.loaderIndicator.isHidden = true
              return
          }
          
          guard let shareLink = DynamicLinkComponents.init(link: linkParameter, domainURIPrefix: "https://positifeedy.page.link") else {
              //SVProgressHUD.dismiss()
            self.loaderIndicator.stopAnimating()
            self.loaderIndicator.isHidden = true
              return
          }
          
          if let myBundleId = Bundle.main.bundleIdentifier {
              shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleId)
          }
          
          shareLink.iOSParameters?.appStoreID = "1484015088"
          
          guard shareLink.url != nil else {
              
              //SVProgressHUD.dismiss()
            self.loaderIndicator.stopAnimating()
            self.loaderIndicator.isHidden = true
              return
          }
          
          shareLink.shorten { [weak self] (url, warnings, error) in
              
              //SVProgressHUD.dismiss()
            self?.loaderIndicator.stopAnimating()
            self?.loaderIndicator.isHidden = true

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
//         tableview.reloadData()
        let indexpath = IndexPath(row: sender.tag, section: 0)
        tableview.reloadRows(at: [indexpath], with: .none)
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
                
                
            }
            deinit {
              //  print("deinit: \(self.greeting!)")
            }

    
    var dailyAffirmation = NSMutableDictionary()
    var categoriData = [String]()
    func loadCategoriData()
    {
            var db: Firestore!
            db = Firestore.firestore()
            db.collection("Affirmation").getDocuments { [self] (snap, error) in
                
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
                        dict = d as NSDictionary
                        //print(dict)
                        
                        self.getCategoriData()
                    }
                }
        }
        
    }
    func getCategoriData()
    {
        
            var db: Firestore!
            db = Firestore.firestore()
            db.collection("users").getDocuments { [self] (snap, error) in
                
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
                            self.categoriData = (d["checkCategories"]) as? [String] ?? []
                            print(self.categoriData)
                            
                            self.dailyAffirmation = (d["DailyAffirmation"] as? NSDictionary ?? NSDictionary()).mutableCopy() as? NSMutableDictionary ?? NSMutableDictionary()
                            
                            if(categoriData.count == 0){
                                
                                let sortedKeys = (dict.allKeys as [String]).sorted()
                                if(sortedKeys.count > 0){
                                    for item in sortedKeys {
                                        let key = item as? String ?? ""
                                        let data = dict.value(forKey: key) as? NSDictionary
                                        let isFree = data?.value(forKey: "Isfree") as? Bool ?? false
                                        if(isFree){
                                            categoriData.append(key)
                                        }
                                    }
                                }else{
                                    categoriData = ["SELF LOVE"]
                                }
                                
                                var db: Firestore!
                                db = Firestore.firestore()
                                
                                let d1 = ["checkCategories" : categoriData]
                                var db1: Firestore!
                                db1 = Firestore.firestore()
                                db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
                                    if error != nil
                                    {
                                      print(error!.localizedDescription)
                                    }
                                    self.checkForAffirmation()
                                }
                            }
                            
                            self.checkForAffirmation()
                            
                            
                            let fname = (d["firstname"] as? String ?? "")

                            let hour = Calendar.current.component(.hour, from: Date())
                            switch hour {
                            case 6..<12 :
                                self.lbltitle.text = String.init(format: "Good Morning, \(fname)! %@" ,"")
                                //self.lblsun.image =  UIImage.init(named: "sun")
                            case 12 :
                                self.lbltitle.text = String.init(format: "Good Afternoon, \(fname)! %@","")
                                //self.lblsun.image =  UIImage.init(named: "sun")
                            case 13..<17 :
                                self.lbltitle.text = String.init(format: "Good Afternoon, \(fname)! %@","")
                                //self.lblsun.image =  UIImage.init(named: "sun")
                            case 17..<22 :
                                self.lbltitle.text = String.init(format: "Good Evening, \(fname)! %@","")
                               // self.lblsun.image =  UIImage.init(named: "moon")
                            default:
                                self.lbltitle.text = String.init(format: "Good Night, \(fname)! %@","")
                               // self.lblsun.image =  UIImage.init(named: "moon")
                            }

                            break
                        }
                    }
                }
        }
        
    }
    var currentAffirmationMessage = "Daliy Affirmation"
    func checkForAffirmation(){
        let date = dailyAffirmation.value(forKey: "date") as? String ?? ""
        let message = dailyAffirmation.value(forKey: "message") as? String ?? ""
        
        let isCategoryChange = UserDefaults.standard.bool(forKey: "IsCategoryChange")
        
        if((date == "" && message == "") || isCategoryChange){
            UserDefaults.standard.set(false, forKey: "IsCategoryChange")
            //Generate new [yyy-mm-dd]
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateData = Date()
            let data = formatter.string(from: dateData) as? String
            dailyAffirmation.setValue(data, forKey: "date")
            
            //get Affirmation with random method
            
            let totalLength = self.categoriData.count
            let randomInt = Int.random(in: 0..<totalLength)
            let strCatName = self.categoriData[randomInt] as? String
          
            let dataCat = dict.value(forKey: strCatName!) as? NSDictionary ?? NSDictionary()
            let array = dataCat.value(forKey: "Messages") as? [String] ?? []

            if array.count > 0
            {
                print("general array :\(array)")
                let randomeArray = Int.random(in: 0..<array.count)
                let mess = array[randomeArray] as String
                
                currentAffirmationMessage = mess
                lblBGAffirmation.text = currentAffirmationMessage
                tableview.reloadData()
                dailyAffirmation.setValue(mess, forKey: "message")
            }
            
            var db: Firestore!
            db = Firestore.firestore()
            print(dailyAffirmation)
            let d1 = ["DailyAffirmation" : dailyAffirmation]
            var db1: Firestore!
            db1 = Firestore.firestore()
            db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
                if error != nil
                {
                    print(error!.localizedDescription)
                }
            }
            
        }else{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateData = Date()
            let strDate = formatter.string(from: dateData) as! String

            var newMessage = ""
            if date != strDate
            {
                let dateData = Date()
                let data = formatter.string(from: dateData) as? String
                dailyAffirmation.setValue(data, forKey: "date")

                repeat{
                    let totalLength = self.categoriData.count
                    let randomInt = Int.random(in: 0..<totalLength)
                    let strCatName = self.categoriData[randomInt] as? String
                    let dataCat = dict.value(forKey: strCatName!) as? NSDictionary ?? NSDictionary()
                    let array = dataCat.value(forKey: "Messages") as? [String] ?? []
                    if array.count > 0
                    {
                        let randomeArray = Int.random(in: 0..<array.count)
                        let mess = array[randomeArray] as String
                        newMessage = mess
                    }
                }while(newMessage == message)
                
                
                currentAffirmationMessage = newMessage
                lblBGAffirmation.text = currentAffirmationMessage
                tableview.reloadData()
                dailyAffirmation.setValue(newMessage, forKey: "message")
                
                var db: Firestore!
                db = Firestore.firestore()
                
                let d1 = ["DailyAffirmation" : dailyAffirmation]
                var db1: Firestore!
                db1 = Firestore.firestore()
                db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
                    if error != nil
                    {
                        print(error!.localizedDescription)
                    }
                }
            }
            else
            {
                currentAffirmationMessage = message
                lblBGAffirmation.text = currentAffirmationMessage
                tableview.reloadData()

            }
            
        }
    }
    
        
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
    extension NewsArticalScreenViewController : UITableViewDataSource
    {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            self.tableview.isHidden = selectedTab == 0 ? (arrPositifeedy.count == 0) : (arrFeeds.count == 0)
            return selectedTab == 0 ? arrPositifeedy.count : arrFeeds.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          
            if(indexPath.row == 112){
                print("")
            }
            if indexPath.row % 5 == 0 && indexPath.row != 0 && !IsSubscripted
            {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "adsCell", for: indexPath) as! AdsTableViewCell
//                cell.controller = self
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AdsTableViewNew", for: indexPath) as! AdsTableViewNew
                cell.controller = self
                
                return cell
            }
            
            if selectedTab == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "FeedyCellUr", for: indexPath) as! FeedyCellUr
                
                let feed = arrPositifeedy[indexPath.row]

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
                    
                    cell.btnShare.tag = indexPath.row
                   cell.btnShare.addTarget(self, action: #selector(btnShareClickFeed), for: .touchUpInside)
                  
//                   cell.btnBookmark.setImage(UIImage(named: "book_mark_ic"), for: .normal)
//                   cell.btnBookmark.setImage(UIImage(named: "bookmarkSelected"), for: .selected)
                   cell.btnBookmark.tag = indexPath.row
                   cell.btnBookmark.isSelected = isBookMark(link: feed.link!,desc: feed.description_d!)
                    
                    if(isBookMark(link: feed.link!,desc: feed.description_d!)){
                        cell.imgBookmark.image = UIImage(named: "bookmarkSelected")
                    }else{
                        cell.imgBookmark.image = UIImage(named: "book_mark_ic")
                    }
                    
                   cell.btnBookmark.addTarget(self, action: #selector(btnBookMarkClick), for: .touchUpInside)
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
                    
                    cell.btnBookmark.tag = indexPath.row
                    cell.btnBookmark.isSelected = isBookMark(link: feed.documentID!,desc: "")

                    if(isBookMark(link: feed.documentID!,desc: "")){
                        cell.imgBookmark.image = UIImage(named: "bookmarkSelected")
                    }else{
                        cell.imgBookmark.image = UIImage(named: "book_mark_ic")
                    }
//                    cell.btnBookmark.tag = indexPath.row
//                    cell.btnBookmark.isSelected = isBookMark(link: feed.documentID!,desc: "")
                    cell.btnBookmark.addTarget(self, action: #selector(btnBookMarkClick), for: .touchUpInside)
                    
                    cell.btnShare.tag = indexPath.row
                    cell.btnShare.addTarget(self, action: #selector(btnShareClick), for: .touchUpInside)
                    
                    cell.btnplay.tag = indexPath.row
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
                
                return cell

                
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
                
//                cell.btnBookMark.setImage(UIImage(named: "book_mark_ic"), for: .normal)
//                cell.btnBookMark.setImage(UIImage(named: "bookmarkSelected"), for: .selected)
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
        
        @objc func btnPlayTapped(_ sender: UIButton) {
            
            let feed = arrPositifeedy[sender.tag]
            if(feed.link?.contains("youtube") ?? false){
                if let strUrl = feed.link, let url = URL(string: strUrl) {
                    self.playVideo(url: url)
                }
            }else{
                if let strUrl = feed.feed_video, let url = URL(string: strUrl) {
                    self.playVideo(url: url)
                }
            }
            
        }
    }


    //MARK: -UITableViewDelegate
    extension NewsArticalScreenViewController : UITableViewDelegate
    {
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width-20, height: UIScreen.main.bounds.height/2))
                headerView.backgroundColor = .clear
                let label = UILabel()
                label.frame = CGRect.init(x: 10, y: 0, width: UIScreen.main.bounds.width-20, height: headerView.frame.height-10)
                label.textAlignment = .center
                //label.font = .boldSystemFont(ofSize: 30)
                label.font = UIFont(name: Global.NewFont.medium, size: 38)
                label.font = label.font.withSize(38)
                label.numberOfLines = 0
                label.textAlignment = .center
                label.text = currentAffirmationMessage

                if(IsLightText){
                    label.textColor = .white
                }else{
                    label.textColor = .black
                }
                
                headerView.addSubview(label)
            
                let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
                tap.numberOfTapsRequired = 2
                headerView.addGestureRecognizer(tap)

                
                return headerView
            }
        
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return UIScreen.main.bounds.height/2
        }
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            
            if indexPath.row % 5 == 0 && indexPath.row != 0 && !IsSubscripted
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
                    webVC.objPositifeedAllSet = feed
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
        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            //self.height.constant = self.tableview.contentSize.height
        }
        
        
    }



extension UINavigationController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}
