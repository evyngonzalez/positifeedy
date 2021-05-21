//
//  MyTabbarVC.swift
//  positifeedy
//
//  Created by iMac on 26/09/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import UIKit

class MyTabbarVC: UITabBarController,  UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        
        let green = colorWithHexString(hexString: "#2FD88E")
        let grey = colorWithHexString(hexString: "#263238")
        tabBar.tintColor = green
        tabBar.unselectedItemTintColor = grey

        tabBarItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "Avenir", size: 12) as Any], for: .normal)
                
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item == (self.tabBar.items as! [UITabBarItem])[3]{
            
        }
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if selectedIndex == 2
        {
            
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let viewController1 = storyboard.instantiateViewController(withIdentifier: "GreetingViewControllerProfile") as! GreetingViewControllerProfile
//            
//            let nav =  self.viewControllers![1] as! UINavigationController
//            let wel =  nav.viewControllers.first as! JournalViewController
//            
//            let nav1 =  viewController as! UINavigationController
//            //let bokVc = nav1.viewControllers.first as! BookMarkVc
//            //bokVc.arrFeeds =  wel.arrFeeds
//            //bokVc.arrPositifeedy = wel.arrPositifeedy
//            viewController1.arrFeeds = wel.arrFeeds
//            viewController1.arrPositifeedy = wel.arrPositifeedy
            
            print("hi")
        }
    }
    
    
}
