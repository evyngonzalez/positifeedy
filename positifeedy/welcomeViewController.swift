//
//  welcomeViewController.swift
//  positifeedy
//
//  Created by Evyn Gonzalez  on 9/12/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//


//shidhdharthjoshi.weapplinse@gmail.com
//123456

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

class welcomeViewController: UIViewController,EMPageViewControllerDataSource, EMPageViewControllerDelegate
{
    
    @IBOutlet weak var segmentedControl: TTSegmentedControl!

    
    var arrFeeds : [Feed] = []
    var arrPositifeedy = [Positifeedy]()
    
//    @IBOutlet var collectionView: UICollectionView!
//    @IBOutlet weak var heightCol: NSLayoutConstraint!

    var myDocID : String?
    var ac : UIActivityIndicatorView!

    @IBOutlet weak var pageview: UIView!
    var selectedTab: Int = 0
    
    var pageViewController: EMPageViewController?
       
       var greetings: [String] = ["From us", "Articles"]
       var greetingColors: [UIColor] = [
           UIColor(red: 108.0/255.0, green: 122.0/255.0, blue: 137.0/255.0, alpha: 1.0),
           UIColor(red: 135.0/255.0, green: 211.0/255.0, blue: 124.0/255.0, alpha: 1.0),
           UIColor(red: 34.0/255.0, green: 167.0/255.0, blue: 240.0/255.0, alpha: 1.0),
           UIColor(red: 245.0/255.0, green: 171.0/255.0, blue: 53.0/255.0, alpha: 1.0),
           UIColor(red: 214.0/255.0, green: 69.0/255.0, blue: 65.0/255.0, alpha: 1.0)
       ]

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        //setNavBackground()
            // segment controller
            segmentedControl.setDesignedBorder(radius: 20.0, width: 0)
            
            segmentedControl.selectItemAt(index: 0, animated: false)
            segmentedControl.itemTitles = ["From Us", "Articles"]
            segmentedControl.defaultTextFont = UIFont.systemFont(ofSize: 16.0)
            segmentedControl.selectedTextFont = UIFont.systemFont(ofSize: 16.0)
            segmentedControl.thumbPadding = 3.0
            segmentedControl.didSelectItemWith = { (index, title) in
                
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
        self.initalizePageView()
        
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavTitle(title : "positifeedy")
        self.navigationController?.navigationBar.isHidden = true

    }

    
    // MARK: - EMPageViewController Data Source
     
     func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
         if let viewControllerIndex = self.index(of: viewController as! GreetingViewController) {
             let beforeViewController = self.viewController(at: viewControllerIndex - 1)
             return beforeViewController
         } else {
             return nil
         }
     }
     
     func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
         if let viewControllerIndex = self.index(of: viewController as! GreetingViewController) {
             let afterViewController = self.viewController(at: viewControllerIndex + 1)
             return afterViewController
         } else {
             return nil
         }
     }
     
     func viewController(at index: Int) -> GreetingViewController? {
         if (self.greetings.count == 0) || (index < 0) || (index >= self.greetings.count) {
             return nil
         }
         
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "GreetingViewController") as! GreetingViewController
        
        
         viewController.greeting = self.greetings[index]
         //viewController.color = self.greetingColors[index]
         return viewController
     }
     
     func index(of viewController: GreetingViewController) -> Int? {
         if let greeting: String = viewController.greeting {
             return self.greetings.firstIndex(of: greeting)
         } else {
             return nil
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
            
            
            
            AF.request(Global.feedURL).responseDecodable(of: FeedResponse.self)  { (response) in
                
                SVProgressHUD.dismiss()
                
                switch response.result
                {
                case .success(let feedResponse) :
                    if (feedResponse.ok ?? false)
                    {
                        self.arrFeeds = feedResponse.info.arrFeedData ?? []
                    }
                    
                case .failure(let error) :
                    print(error)
                }
                
            }
        }
    
     
     // MARK: - EMPageViewController Delegate
    
    
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
    
}
