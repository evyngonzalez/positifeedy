//
//  WebViewVC.swift
//  positifeedy
//
//  Created by iMac on 24/09/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import UIKit
import WebKit

class WebViewVC: UIViewController {

    @IBOutlet weak var webView : WKWebView!
   
    var url : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = url, let u = URL(string: url)
        {
            webView.load(URLRequest(url: u))
        }
        
     
    }
    

   
}
