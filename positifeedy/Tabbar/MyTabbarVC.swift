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
        tabBar.tintColor = .green
        
        tabBarItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "Avenir", size: 12) as Any], for: .normal)
        
    }
    
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if selectedIndex == 2
        {
            let nav =  self.viewControllers![0] as! UINavigationController
            let wel =  nav.viewControllers.first as! welcomeViewController
            
            let nav1 =  viewController as! UINavigationController
            let bokVc = nav1.viewControllers.first as! BookMarkVc
            bokVc.arrFeeds =  wel.arrFeeds
            bokVc.arrPositifeedy = wel.arrPositifeedy
            
            print("hi")
        }
    }
    
    
}
