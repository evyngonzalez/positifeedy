//
//  TermsNConditionVC.swift
//  positifeedy
//
//  Created by Hiren Dhamecha on 14/12/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import UIKit
import WebKit


class TermsNConditionVC: UIViewController
{

    @IBOutlet weak var webview: WKWebView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.loadurl()
    }
    
    //MARK:- load url :
    func loadurl() -> Void {
        
        if let pdf = Bundle.main.url(forResource: "terms_doc", withExtension: "pdf", subdirectory: nil, localization: nil)  {
            let web_request = NSURLRequest(url: pdf)
            
            self.webview.load(web_request as URLRequest)
        }
        
        
        
    }

    @IBAction func onclickforBack(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
