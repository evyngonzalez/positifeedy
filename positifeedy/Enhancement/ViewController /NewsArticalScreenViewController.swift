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
class NewsArticalScreenViewController: UIViewController,UIScrollViewDelegate {
    
    @IBOutlet weak var videoShowHideVIew: UIView!
   
    @IBOutlet weak var gradintviewforbg: UIView!
    @IBOutlet weak var lbltitle: UILabel!
    
    //@IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var greadintView: Gradient!
    //@IBOutlet weak var dailyAffirmation: UILabel!
    //@IBOutlet weak var doubletabview: UIView!
    
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
        self.tableview.separatorStyle = UITableViewCell.SeparatorStyle.none
        gradintviewforbg.isHidden = true
        tabBarController?.tabBar.isHidden = false
        //        videoShowHideVIew.isHidden = true
//        setupVideoView()
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
        getPositifeedy()
        getProfileData()
        
        gestureaddonbackground()
        gestureAdd()
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         
     }
    
    
    @IBAction func btnThemeClicked(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "chengethemeViewController") as! chengethemeViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:- SCrollview Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView!) {
        gradintviewforbg.isHidden = false
        if(tableview.contentOffset.y >= 0 && tableview.contentOffset.y <= 150.0) {
            let  percent = (tableview.contentOffset.y / 180);
                         self.gradintviewforbg.alpha = percent;

              } else if (tableview.contentOffset.y > 180.0){
            self.gradintviewforbg.alpha = 0.8;

              } else if (tableview.contentOffset.y < 0) {
           // self.gradintviewforbg.alpha = 0.5
              }
//              print(self.scrollview.contentOffset.y)
    }
    override func viewWillAppear(_ animated: Bool) {
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
        
    }
   func gestureAdd()
   {
    let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
    tap.numberOfTapsRequired = 2
//    doubletabview.addGestureRecognizer(tap)
   
    }
    @objc func doubleTapped() {
//        scrollview.isHidden = true
        greadintView.isHidden = true
//        doubletabview.isHidden = true
        tableview.isHidden = true
        tabBarController?.tabBar.isHidden = true
         videoShowHideVIew.isHidden = false
        
    }
    
    var BGVideoView = UIView()
    var videoBG = VideoBackgroundURL()
    let BGImageView = UIImageView()
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
        self.tableview.reloadData()

        var url = themeData.value(forKey: "themeUrl") as? String ?? ""
        if(url == ""){
            url = defaultThemeUrl
            isVideo = defaultThemeStatus
        }
        
//        url = "http://techslides.com/demos/sample-videos/small.mp4"
        if(isVideo){
            let volume = themeData.value(forKey: "volume") as? Float ?? 0.0
            
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
            let options = VideoOptionsURL(
                pathToVideo: url,
                pathToImage: "",
                volume: volume,
                shouldLoop: true
            )
            BGVideoView = UIView.init(frame: view.frame)
            
            videoPlayer.pause()
            videoPlayer = AVPlayer()
            playerLayer?.player?.pause()

            videoBG.removeFromSuperview()
            videoBG = VideoBackgroundURL(frame: view.frame, options: options)
            
            BGVideoView.insertSubview(videoBG, at: 0)
            BGImageView.removeFromSuperview()
            
            BGVideoView.isHidden = false
            BGImageView.isHidden = true
            
            view.insertSubview(BGVideoView, at: 0)
        }else{
            
            BGImageView.frame = view.frame
            
            BGImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage.init(named: "album_placeholder"), options: .highPriority, completed: nil)
            BGImageView.contentMode = .scaleAspectFill
            
            BGVideoView.removeFromSuperview()
            
            BGVideoView.isHidden = true
            BGImageView.isHidden = false
            
            videoPlayer.pause()
            videoPlayer = AVPlayer()
            playerLayer?.player?.pause()
            
            view.insertSubview(BGImageView, at: 0)
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
             db.collection("userNew").getDocuments { (snap, error) in
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
                            
                            
                            // let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate()) Swift 2 legacy
                            let hour = Calendar.current.component(.hour, from: Date())
                            switch hour {
                            case 6..<12 :
                                self.lbltitle.text = String.init(format: "Good Morning, \(fname)! %@" ,"")
                                //self.lblsun.image =  UIImage.init(named: "sun")
                            case 12 :
                                self.lbltitle.text = String.init(format: "Good Noon, \(fname)! %@","")
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
                                   // self.suscriptionView.isHidden = false
                                    
                                }else
                                {
                                    // subscribed :
                                    //self.suscriptionView.isHidden = true
                                }
                                
                            }else
                            {
                                
                                 // self.suscriptionView.isHidden = false
                                   let d = ["Subscription" : "0"]
                                   var db: Firestore!
                                   db = Firestore.firestore()
                                   db.collection("userNew").document(self.myDocId!).updateData(d) { (error) in
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
                                                       let set_new_point = point! - 5
                                                       let str = String.init(format: "%d",set_new_point)
                                                       let d = ["myPoint" : str]
                                                       var db: Firestore!
                                                       db = Firestore.firestore()
                                                       db.collection("userNew").document(self.myDocId!).updateData(d) { (error) in
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
                                               db.collection("userNew").document(self.myDocId!).updateData(d) { (error) in
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
                                                    db1.collection("userNew").document(self.myDocId!).updateData(d1) { (error) in
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
                                                db1.collection("userNew").document(self.myDocId!).updateData(d1) { (error) in
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
                                                 db1.collection("userNew").document(self.myDocId!).updateData(d1) { (error) in
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
                                            db1.collection("userNew").document(self.myDocId!).updateData(d1) { (error) in
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
                                              db1.collection("userNew").document(self.myDocId!).updateData(d1) { (error) in
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
                                                     db1.collection("userNew").document(self.myDocId!).updateData(d1) { (error) in
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
                                           db1.collection("userNew").document(self.myDocId!).updateData(d1) { (error) in
                                               if error != nil
                                               {
                                                   print(error!.localizedDescription)
                                               }
                                           }
                                        
                                        
                                          // let str = String.init(format: "%d", self.currentPoint)
                                         //  let d = ["myPoint" : str]
                                           var db: Firestore!
                                           db = Firestore.firestore()
                                           db.collection("userNew").document(self.myDocId!).updateData(d) { (error) in
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
                 tableview.reloadData()
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
            
            
            if indexPath.row % 5 == 0 && indexPath.row != 0
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
                  
                   cell.btnBookmark.setImage(UIImage(named: "book_mark_ic"), for: .normal)
                   cell.btnBookmark.setImage(UIImage(named: "bookmarkSelected"), for: .selected)
                   cell.btnBookmark.tag = indexPath.row
                   cell.btnBookmark.isSelected = isBookMark(link: feed.link!,desc: feed.description_d!)
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
        
        @objc func btnPlayTapped(_ sender: UIButton) {
            
            let feed = arrPositifeedy[sender.tag]
            if let strUrl = feed.feed_video, let url = URL(string: strUrl) {
                self.playVideo(url: url)
            }
        }
    }


    //MARK: -UITableViewDelegate
    extension NewsArticalScreenViewController : UITableViewDelegate
    {
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: UIScreen.main.bounds.height/2))
                headerView.backgroundColor = .clear
                let label = UILabel()
                label.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: headerView.frame.height-10)
                label.text = "Daily Affirmation"
                label.textAlignment = .center
                label.font = .boldSystemFont(ofSize: 30)
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
            
            if indexPath.row % 5 == 0 && indexPath.row != 0
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



