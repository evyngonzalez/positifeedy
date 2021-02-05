//
//  BookMarkVc.swift
//  positifeedy
//
//  Created by iMac on 24/09/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage
import Toast_Swift
import AVKit
import AVFoundation
import SDWebImage
import FTPopOverMenu_Swift
import Alamofire
import EMPageViewController
import SVProgressHUD

class BookMarkVc: UIViewController,EMPageViewControllerDataSource, EMPageViewControllerDelegate
{
    var textField : UITextField!
    var flagType : Int = 2
    var arrListOfJourny : NSMutableArray!
    
    
    @IBOutlet weak var tableView : UITableView!
    
    @IBOutlet weak var bookmarkview: UIView!
    @IBOutlet weak var lblFName : UILabel!
    @IBOutlet weak var lblLName : UILabel!
    @IBOutlet weak var lblEmail : UILabel!
    
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var journalview: UIView!
    @IBOutlet weak  var activity : UIActivityIndicatorView!
    @IBOutlet weak var segementedCntrl: TTSegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    
    var pageViewController: EMPageViewController?
    
    @IBOutlet weak var pageview: UIView!
    
    var greetings: [String] = ["Journal Entries", "Bookmarks"]
          var greetingColors: [UIColor] = [
              UIColor(red: 108.0/255.0, green: 122.0/255.0, blue: 137.0/255.0, alpha: 1.0),
              UIColor(red: 135.0/255.0, green: 211.0/255.0, blue: 124.0/255.0, alpha: 1.0),
              UIColor(red: 34.0/255.0, green: 167.0/255.0, blue: 240.0/255.0, alpha: 1.0),
              UIColor(red: 245.0/255.0, green: 171.0/255.0, blue: 53.0/255.0, alpha: 1.0),
              UIColor(red: 214.0/255.0, green: 69.0/255.0, blue: 65.0/255.0, alpha: 1.0)
          ]
    
    var arrData : [Any] = []
    var lblError : UILabel?
    
    var arrFeeds  : [Feed]?
    var arrPositifeedy = [Positifeedy]()

    var myDocId : String?
    
    var isProfileImgLoad = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.design()
        
        self.arrListOfJourny = NSMutableArray.init()
        
        activity.isHidden = true
        imageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandel))
        imageView.addGestureRecognizer(tapGesture)
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(UINib(nibName: "FeedCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.register(UINib(nibName: "FeedyCell", bundle: nil), forCellReuseIdentifier: "FeedyCell")
        
        
        tableView.register(UINib(nibName: "tblJournalCell", bundle: nil), forCellReuseIdentifier: "tblJournalCell")

        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        setNavBackground()
        setNavTitle(title : "positifeedy")
        cofigErroLable()
        
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        
        
        // segment controller
        segementedCntrl.setDesignedBorderProfile(radius: 20.0, width: 0)
        
        segementedCntrl.selectItemAt(index: 0, animated: false)
        segementedCntrl.itemTitles = ["Journal Entries", "Bookmarks"]
        segementedCntrl.defaultTextFont = UIFont.systemFont(ofSize: 16.0)
        segementedCntrl.selectedTextFont = UIFont.systemFont(ofSize: 16.0)
        segementedCntrl.thumbPadding = 3.0
        segementedCntrl.didSelectItemWith = { (index, title) in
            
            if index == 0
            {
                //self.viewController(at: 0)
               self.pageViewController!.scrollReverse(animated: true, completion: nil)
            }
            else
            {
                //self.viewController(at: 1)
               self.pageViewController!.scrollForward(animated: true, completion: nil)
            }
        }
        
        initalizePageView()
        
    }
    
    
    //MARK:- init page :
      func initalizePageView() -> Void {
          
      // Instantiate EMPageViewController and set the data source and delegate to 'self'
             let pageViewController = EMPageViewController()
             
             // Or, for a vertical orientation
             // let pageViewController = EMPageViewController(navigationOrientation: .Vertical)
             
             pageViewController.dataSource = self
             pageViewController.delegate = self
             
             // Set the initially selected view controller
             // IMPORTANT: If you are using a dataSource, make sure you set it BEFORE calling selectViewController:direction:animated:completion
             let currentViewController = self.viewController(at: 0)!
             pageViewController.selectViewController(currentViewController, direction: .forward, animated: false, completion: nil)
             pageViewController.view.frame = CGRect.init(x: 0, y: 0, width: self.pageview.frame.size.width, height: self.pageview.frame.size.height)
             // Add EMPageViewController to the root view controller
             self.addChild(pageViewController)
             self.pageview.addSubview(pageViewController.view)
             //self.pageview.insertSubview(pageViewController.view, at: 0) // Insert the page controller view below the navigation buttons
             pageViewController.didMove(toParent: self)
             
             self.pageViewController = pageViewController
      }
      
      
   // MARK: - EMPageViewController Data Source
       
       func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
           if let viewControllerIndex = self.index(of: viewController as! GreetingViewControllerProfile) {
               let beforeViewController = self.viewController(at: viewControllerIndex - 1)
               return beforeViewController
           } else {
               return nil
           }
       }
       
       func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
           if let viewControllerIndex = self.index(of: viewController as! GreetingViewControllerProfile) {
               let afterViewController = self.viewController(at: viewControllerIndex + 1)
               return afterViewController
           } else {
               return nil
           }
       }
       
       func viewController(at index: Int) -> GreetingViewControllerProfile? {
           if (self.greetings.count == 0) || (index < 0) || (index >= self.greetings.count) {
               return nil
           }
           
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let viewController = storyboard.instantiateViewController(withIdentifier: "GreetingViewControllerProfile") as! GreetingViewControllerProfile
          
          
           viewController.greeting = self.greetings[index]
        
           //viewController.color = self.greetingColors[index]
           return viewController
       }
       
       func index(of viewController: GreetingViewControllerProfile) -> Int? {
           if let greeting: String = viewController.greeting {
               return self.greetings.firstIndex(of: greeting)
           } else {
               return nil
           }
       }
    
    // MARK: - EMPageViewController Delegate
        
        
         func em_pageViewController(_ pageViewController: EMPageViewController, willStartScrollingFrom startViewController: UIViewController, destinationViewController: UIViewController) {
             
             let startGreetingViewController = startViewController as! GreetingViewControllerProfile
             let destinationGreetingViewController = destinationViewController as! GreetingViewControllerProfile
             
             print("Will start scrolling from \(startGreetingViewController.greeting!) to \(destinationGreetingViewController.greeting!).")
         }
         
         func em_pageViewController(_ pageViewController: EMPageViewController, isScrollingFrom startViewController: UIViewController, destinationViewController: UIViewController, progress: CGFloat) {
             let startGreetingViewController = startViewController as! GreetingViewControllerProfile
             let destinationGreetingViewController = destinationViewController as! GreetingViewControllerProfile
             
             // Ease the labels' alphas in and out
             let absoluteProgress = abs(progress)
             //startGreetingViewController.label.alpha = pow(1 - absoluteProgress, 2)
             //destinationGreetingViewController.label.alpha = pow(absoluteProgress, 2)
             
            print("Is scrolling from \(startGreetingViewController.greeting!) to \(destinationGreetingViewController.greeting!) with progress '\(progress)'.")
         }
         
         func em_pageViewController(_ pageViewController: EMPageViewController, didFinishScrollingFrom startViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
             let startViewController = startViewController as! GreetingViewControllerProfile?
             let destinationViewController = destinationViewController as! GreetingViewControllerProfile
             
             // If the transition is successful, the new selected view controller is the destination view controller.
             // If it wasn't successful, the selected view controller is the start view controller
             if transitionSuccessful {
                 
                if startViewController != nil
                           {
                               if startViewController!.greeting == "Bookmarks"
                               {
                                   self.segementedCntrl.selectItemAt(index: 0, animated: true)
                               }
                               else
                               {
                                   self.segementedCntrl.selectItemAt(index: 1, animated: true)
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
    
    func design() -> Void {
        
        self.bookmarkview.layer.cornerRadius = 5
        self.bookmarkview.clipsToBounds = true
        
        self.journalview.layer.cornerRadius = 5
        self.journalview.clipsToBounds = true
        
        self.journalview.backgroundColor = UIColor.init(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        
        self.bookmarkview.backgroundColor = UIColor.init(red: 57/255, green: 248/255, blue: 168/255, alpha: 1)
        
        self.navigationController?.isNavigationBarHidden = true
        
        
    }
    
    func uploadImage()  {
        
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        // Create a reference to "mountains.jpg"
        let data = imageView.image?.jpegData(compressionQuality: 1.0)
        
        let id = Auth.auth().currentUser!.uid + ".jpg"
        
        // Create a reference to 'images/mountains.jpg'
        let imgRef = storageRef.child("images").child(id)
        
        imgRef.putData(data!, metadata: nil) { (dt, error) in
            
            if error != nil
            {
                self.view.makeToast(error!.localizedDescription)
                return
            }
            imgRef.downloadURL { (url, err) in
                
                if err != nil
                {
                    self.view.makeToast(err!.localizedDescription)
                    return
                }
                
                guard let url = url else {
                    self.view.makeToast("Something went to wrong")
                    return
                }
                
                
                print("url => ", url)
                
                var db: Firestore!
                db = Firestore.firestore()
                
                let d = ["pic" : url.absoluteString ]
                self.activity.startAnimating()
                self.activity.isHidden = false
                db.collection("users").document(self.myDocId!).updateData(d as [AnyHashable : Any]) { (er) in
                    self.activity.stopAnimating()
                    self.activity.isHidden = true
                    if er != nil
                    {
                        self.view.makeToast(er?.localizedDescription)
                        
                        return
                    }
                }
            }
        }
    }
    
    
    @objc func  tapHandel( _ gesture : UITapGestureRecognizer)  {
        
        let alertVC = UIAlertController(title: "Postifieedy", message: "User profile", preferredStyle: .actionSheet)
        
        
        alertVC.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action) in
            
            self.openCameraOrPhoto(.camera)
        }))
        
        
        alertVC.addAction(UIAlertAction(title: "Photo Library", style: .default   , handler: { (action) in
            
            self.openCameraOrPhoto(.photoLibrary)
        }))
        
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertVC, animated: true, completion: nil)
    }
    
    
    func openCameraOrPhoto( _ sourceType : UIImagePickerController.SourceType)  {
        
        if   UIImagePickerController.isSourceTypeAvailable(sourceType)
        {
            let vc = UIImagePickerController()
            vc.sourceType = sourceType
            vc.delegate = self
            present(vc, animated: true)
        }
    }
    
    @IBAction func barBtnLogoutClick( _ sender : UIBarButtonItem)  {
        
        let alertVC = UIAlertController(title: "Postifeedy", message: "Are you sure?", preferredStyle: UIAlertController.Style.alert)
        
        alertVC.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alertVC.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            do
            {
                try   Auth.auth().signOut()
                
                let appDel =  UIApplication.shared.delegate as! AppDelegate
                appDel.arrBookMarkLink = []
                
                UserDefaults.standard.set(false, forKey: "isLogin")
                
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "logInViewController") as! logInViewController
                
                
                let nav = UINavigationController(rootViewController: loginVC )
                nav.setNavigationBarHidden(true, animated: false)
                
                appDel.window?.rootViewController = nav
                appDel.window?.makeKeyAndVisible()
            }
            catch
            {
                self.view.makeToast(error.localizedDescription)
            }
        }))
        
        present(alertVC, animated: true, completion: nil)
    }
    
    
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
                    self.lblFName.text = String.init(format: "%@ %@", (d["firstname"] as! String),(d["lastname"] as! String))
                    
                //    self.lblEmail.text = Auth.auth().currentUser?.email
                    
                    if let strURL = (d["pic"] as? String)
                    {
                        let url = URL(string: strURL)
                        self.activity.startAnimating()
                        self.activity.isHidden = false
                        DispatchQueue.global(qos: .background).async {
                            do
                            {
                                let data = try Data(contentsOf: url!)
                                DispatchQueue.main.async {
                                    self.imageView.image = UIImage(data: data)
                                    self.activity.stopAnimating()
                                    self.activity.isHidden = true
                                }
                                
                            }
                            catch{
                                self.view.makeToast("Somthing went to wrong")
                            }
                        }
                    }
                    
                    let mindstatus = d["mindstatus"] as? String
                    if mindstatus != nil
                    {
                        
                        self.lblEmail.text = String.init(format: "%@",mindstatus as! CVarArg)
                      
                        if mindstatus?.lowercased() == "beginner"
                        {
                            self.imgIcon.image = UIImage.init(named: "1")
                            
                        }
                        else if mindstatus?.lowercased() == "intermediate"
                        {
                            self.imgIcon.image = UIImage.init(named: "2")
                            
                        }
                        else if mindstatus?.lowercased() == "advanced"
                        {
                            self.imgIcon.image = UIImage.init(named: "3")
                            
                        }
                        else if mindstatus?.lowercased() == "expert"
                        {
                            self.imgIcon.image = UIImage.init(named: "4")
                            
                        }
                        else if mindstatus?.lowercased() == "master"
                        {
                            self.imgIcon.image = UIImage.init(named: "5")
                            
                        }else
                        {
                            
                        }
                    }
                    else
                    {
                        self.lblEmail.text = "Beginner"
                        self.imgIcon.image = UIImage.init(named: "1")
                    }
                    
                    
                    
                    
                    let arr = d["JournalEntry"] as? NSArray
                    if arr != nil
                    {
                        if arr!.count > 0
                        {
                            self.arrListOfJourny = NSMutableArray.init(array: arr!)
                            print("My Journal :\(self.arrListOfJourny)")
                            
                        }
                    }
                    else
                    {
                        print("No JournalEntry Object !")
                    }
                        
                }
                }
                
            }
        }
    }
    
    
    func cofigErroLable()  {
        
        lblError = UILabel(frame: .zero)
        //lblError?.text = "Not bookmark available"
        lblError?.text = "Not bookmark available"
        tableView.backgroundView = UIView()
        tableView.backgroundView?.addSubview(lblError!)
        
        
        lblError?.textColor = .gray
        lblError?.font = UIFont(name: Global.Font.regular, size: 16)
        lblError?.translatesAutoresizingMaskIntoConstraints = false
        lblError?.isHidden = true
        
        let centerX =  NSLayoutConstraint(item: lblError as Any, attribute: .centerX, relatedBy: .equal, toItem: tableView.backgroundView, attribute: .centerX, multiplier: 1, constant: 0)
        
        
        let centerY =  NSLayoutConstraint(item: lblError as Any, attribute: .centerY, relatedBy: .equal, toItem: tableView.backgroundView, attribute: .centerY, multiplier: 1, constant: 0)
        
        
        tableView.backgroundView?.addConstraints([centerX, centerY])
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
        
        if isProfileImgLoad == true
        {
        //    getProfileData()
            isProfileImgLoad = false
        }
        //getFeeds()
        getProfileData()
        
        //self.getFeedsList()
        //self.getPositifeedy()
        
    }
    
    
    func getFeedsList()  {
             
             if !NetworkState.isConnected()
             {
                 let alert = UIAlertController(title: Utilities.appName(), message: "Internet not connected", preferredStyle: .alert)
                 alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                 present(alert, animated: true, completion: nil)
                 return
             }
             
//             if self.isRefresh == false {
//                 SVProgressHUD.show()
//             }
             
             AF.request(Global.feedURL).responseDecodable(of: FeedResponse.self)  { (response) in
                 
                 //SVProgressHUD.dismiss()
                 print("response :\(response)")
                
                 switch response.result
                 {
                 case .success(let feedResponse) :
                     if (feedResponse.ok ?? false)
                     {
                        // self.arrFeeds = feedResponse.info.arrFeedData ?? []
                        
                            self.getFeeds()
                        
//                         if self.isRefresh
//                         {
//                             self.refreshControl.endRefreshing()
//                             self.isRefresh = false
//                         }
                     }
                     
                 case .failure(let error) :
                     print(error)
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
                    self.getFeeds()
                }
            }
        }
    
    
    func getFeeds() {
        
        arrData.removeAll()
        
        if arrFeeds != nil
        {
            let appDel =  UIApplication.shared.delegate as! AppDelegate
            
            var tempBookMark = [Feed]()
            
            for link in appDel.arrBookMarkLink
            {
                tempBookMark.append(contentsOf:  (arrFeeds?.filter { $0.link == link})! )
            }
            
            arrData.append(contentsOf: tempBookMark)
            
        }
        
        if arrPositifeedy.count > 0
        {
            let appDel =  UIApplication.shared.delegate as! AppDelegate
            
            var tempBookMark = [Positifeedy]()
            
            for link in appDel.arrBookMarkLinkFeedy
            {
                tempBookMark.append(contentsOf: (arrPositifeedy.filter { $0.documentID == link}) )
            }
            
            arrData.append(contentsOf: tempBookMark)
            
        }
        
        self.tableView.reloadData()
     
    }
   
    
    @IBAction func onclickforEdit(_ sender: Any)
    {
        let alert = UIAlertController(title: "Edit Profile", message: "Please Enter Your Name", preferredStyle: UIAlertController.Style.alert)

        alert.addTextField(configurationHandler: configurationTextField)

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler:{ (UIAlertAction)in
            
            print("text :",self.textField.text)
            self.lblFName.text = self.textField.text
            let d1 = ["firstname" : self.lblFName.text,"lastname" : ""]
            var db1: Firestore!
            db1 = Firestore.firestore()
            db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
                if error != nil
                {
                    
                    print(error!.localizedDescription)
                }
                
            }
            
            //println(self.textField.text)
            }))
        self.present(alert, animated: true, completion: {
                
            })
    }
    
    
    func configurationTextField(textField: UITextField!)
       {
           
        if let tField = textField {
               self.textField = textField!        //Save reference to the UITextField
            self.textField.text = self.lblFName.text
           }
       }

    func handleCancel(alertView: UIAlertAction!)
           {
              
           }
    
    
    @IBAction func onclickforSetting(_ sender: UIButton)
    {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let answ = storyboard.instantiateViewController(withIdentifier: "SetttingScreenVC") as! SetttingScreenVC
        answ.modalPresentationStyle = .fullScreen
        answ.modalTransitionStyle = .crossDissolve
        self.present(answ, animated: true, completion: nil)
        
        
//        FTPopOverMenu.showForSender(sender: sender,
//                                           with: ["Payment method","Cancel subscription","Terms and Conditions","Personal info:email and name","Sign out"],
//                                           done: { (selectedIndex) -> () in
//
//                                               print(selectedIndex)
//               }) {
//
//               }
    }
    
    @IBAction func onclickforJournal(_ sender: Any)
    {
        
        self.flagType = 1
        self.bookmarkview.backgroundColor = UIColor.init(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        self.journalview.backgroundColor = UIColor.init(red: 57/255, green: 248/255, blue: 168/255, alpha: 1)
        
        if self.arrListOfJourny.count > 0
        {
            self.tableView.reloadData()
            lblError?.text = ""
        }
        else
        {
            lblError?.text = "No Journal entries available"
            self.tableView.reloadData()
        }
        
    }
    
    @IBAction func onclickforBookMark(_ sender: Any)
    {
        self.flagType = 2
        self.journalview.backgroundColor = UIColor.init(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        self.bookmarkview.backgroundColor = UIColor.init(red: 57/255, green: 248/255, blue: 168/255, alpha: 1)
        lblError?.text = "No bookmark available"
        self.tableView.reloadData()
    }

    
 /*   @objc func btnShareFeed(sender : UIButton)
    {
                SVProgressHUD.show()

                 //let positifeedy = arrPositifeedy[sender.tag]
                 
                let positifeedy = arrData[sender.tag] as? Feed
        
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
         
    
    @objc func btnShareFeedy(sender : UIButton)
    {
               
            let feed = arrData[sender.tag] as! Positifeedy
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
                 
    }
    */
    
    @objc func btnBookMarkRemoveClick(sender : UIButton)  {
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
        if let obj = arrData[sender.tag] as? Feed {
            let feed = obj.link
            
            arrData.remove(at: sender.tag)
            
            if let index = appDel.arrBookMarkLink.firstIndex(of: feed!)
            {
                appDel.arrBookMarkLink.remove(at:index)
                let d = ["links" : appDel.arrBookMarkLink]
                
                var db: Firestore!
                db = Firestore.firestore()
                
                db.collection("users").document(myDocId!).updateData(d) { (error) in
                    if error != nil
                    {
                        print(error!.localizedDescription)
                    }
                }
            }
        } else {
            let feed = (arrData[sender.tag] as! Positifeedy).documentID
            
            arrData.remove(at: sender.tag)
            
            if let index = appDel.arrBookMarkLinkFeedy.firstIndex(of: feed!)
            {
                
                appDel.arrBookMarkLinkFeedy.remove(at:index)
                let d = ["linksFeedy" : appDel.arrBookMarkLinkFeedy]
                
                var db: Firestore!
                db = Firestore.firestore()
                
                db.collection("users").document(myDocId!).updateData(d) { (error) in
                    if error != nil
                    {
                        print(error!.localizedDescription)
                    }
                }
            }
        }
        
        tableView.reloadData()

        
    }
}


//MARK:- UITableViewDataSource
extension BookMarkVc : UITableViewDataSource
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.flagType == 1
        {
            if self.arrListOfJourny != nil
            {
                if self.arrListOfJourny.count > 0
                {
                    return self.arrListOfJourny.count
                }
                else
                {
                    return 0
                }
            }
            else
            {
                return 0
            }
            
        }else
        {
                lblError?.isHidden = arrData.count == 0  ? false : true
                
                    return arrData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.flagType == 1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tblJournalCell", for: indexPath) as! tblJournalCell
            
            cell.bgview.layer.cornerRadius = 10
            cell.bgview.clipsToBounds  = true
            
            let dict = self.arrListOfJourny.object(at: indexPath.row) as! NSDictionary
            cell.lblDate.text = String.init(format: "%@", self.changeFormateDate(strDate: (dict.value(forKey: "current_date") as? String)!))
            cell.lblQuestion.text = String.init(format: "%@",(dict.value(forKey: "question") as? CVarArg)!)
            
            
            return cell
        }
        else
        {
            
            if let feed = arrData[indexPath.row] as? Feed {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FeedCell

                let date = feed.time?.toDate()
                
                cell.btnPlay.isHidden = true

                cell.lblTitle.text = feed.title
                cell.lblDesc.text = feed.desc
                cell.lblTime.text  = date!.getElapsedInterval((feed.time?.getTimeZone())!)
                
                cell.btnBookMark.setImage(UIImage(named: "cancel"), for: .normal)
                        
                cell.btnBookMark.tag = indexPath.row
                cell.btnBookMark.addTarget(self, action: #selector(btnBookMarkRemoveClick), for: .touchUpInside)
                cell.imgView.cornerRadius(10)
                
                if let link = URL(string: feed.link!)
                {
                    if let img = Images(rawValue: (link.domain)!)?.image
                    {
                        cell.imgView.image = UIImage(named: img )
                    }
                }
                
//                cell.btnShare.isHidden = false
//                cell.btnShare.tag = indexPath.row
//                cell.btnShare.addTarget(self, action: #selector(btnShareFeed), for: .touchUpInside)
                
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "FeedyCell", for: indexPath) as! FeedyCell
                
                let feed = arrData[indexPath.row] as! PositifeedAllSet
                
                cell.bindData(feed: feed)

                cell.btnShare.isHidden = true

                cell.btnBookMark.setImage(UIImage(named: "cancel"), for: .normal)
                        
                cell.btnBookMark.tag = indexPath.row
                cell.btnBookMark.addTarget(self, action: #selector(btnBookMarkRemoveClick), for: .touchUpInside)
                
                cell.btnPlay.tag = indexPath.row
                cell.btnPlay.addTarget(self, action: #selector(btnPlayTapped(_:)), for: .touchUpInside)
                
//                cell.btnShare.isHidden = false
//                cell.btnShare.tag = indexPath.row
//                cell.btnShare.addTarget(self, action: #selector(btnShareFeedy), for: .touchUpInside)
                
                return cell
            }
        }
    }
    
    
    //MARK:- change formate date!
    func changeFormateDate(strDate : String) -> String {
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let showDate = inputFormatter.date(from: strDate)
        inputFormatter.dateFormat = "dd MMM yyyy"
        let resultString = inputFormatter.string(from: showDate!)
        
        return resultString
        
    }
    
    
    @objc func btnPlayTapped(_ sender: UIButton) {
        
        if let feed = arrData[sender.tag] as? Positifeedy {
            if let strUrl = feed.feed_video, let url = URL(string: strUrl) {
                self.playVideo(url: url)
            }
        }
    }
    
    func playVideo(url: URL) {
        let player = AVPlayer(url: url)

        let vc = AVPlayerViewController()
        vc.player = player

        self.present(vc, animated: true) { vc.player?.play() }
    }
}


//MARK: -UITableViewDelegate
extension BookMarkVc : UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.flagType == 1
        {
            return 160
            
        }else
        {
            return UITableView.automaticDimension
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.flagType == 1
        {
            
            self.tableView.deselectRow(at: indexPath, animated: true)
            
            let dict = self.arrListOfJourny.object(at: indexPath.row) as? NSDictionary
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let answ = storyboard.instantiateViewController(withIdentifier: "AnswerDetailsVC") as! AnswerDetailsVC
            answ.modalPresentationStyle = .fullScreen
            answ.modalTransitionStyle = .crossDissolve
            answ.dictDetails = dict?.mutableCopy() as? NSMutableDictionary
            self.present(answ, animated: true, completion: nil)
            
        }
        else
        {
            if let feed = arrData[indexPath.row] as? Feed {
                let webVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
                webVC.url = feed.link
                webVC.myDocID = self.myDocId
                webVC.isBookmark = true
                navigationController?.pushViewController(webVC, animated: true)
                
            } else if let feed = arrData[indexPath.row] as? PositifeedAllSet {
                
                let feed_type = feed.feed_type ?? ""

                if feed_type == "link" {
                    let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewFeedy") as! WebViewFeedy
                    detailVC.myDocID = self.myDocId
                    detailVC.isBookmark = true
                    detailVC.positifeedy = feed
                    navigationController?.pushViewController(detailVC, animated: true)
                } else {
                    let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "PostDetailViewController") as! PostDetailViewController
                    detailVC.myDocID = self.myDocId
                    detailVC.isBookmark = true
                    detailVC.positifeedy = feed
                    navigationController?.pushViewController(detailVC, animated: true)
                }
            }
        }
    }
}

extension BookMarkVc : UIImagePickerControllerDelegate , UINavigationControllerDelegate
{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isProfileImgLoad = false
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
         imageView.image = (info[UIImagePickerController.InfoKey.originalImage] as! UIImage)
        isProfileImgLoad = false
        picker.dismiss(animated: true, completion: nil)
        uploadImage()
        
    }
}

