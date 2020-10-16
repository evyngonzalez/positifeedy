//
//  ViewController.swift
//  positifeedy
//
//  Created by Evyn Gonzalez  on 9/11/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func btnSignUp(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "signUpViewController") as! signUpViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "logInViewController") as! logInViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

