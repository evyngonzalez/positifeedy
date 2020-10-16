//
//  logInViewController.swift
//  positifeedy
//
//  Created by Evyn Gonzalez  on 9/12/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Toast_Swift
import SVProgressHUD

class logInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        //
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        view.addGestureRecognizer(tap)
    }
    
    
    @objc func tapHandler( _ gesture : UITapGestureRecognizer)  {
        
        view.endEditing(true)
        
    }
    
    @IBAction func btnSignUp(_ sender: Any) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "signUpViewController") as! signUpViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setUpElements() {
        errorLabel.alpha = 0
        
    }
    
    @IBAction func btnForgotTapped(_ sender: UIButton) {
        
        view.endEditing(true)
        
        let email = emailTextField.text!.trim()
        
        if email == "" {
            self.view.makeToast("please enter email address")
            return
        } else if !email.isValidEmail() {
            self.view.makeToast("Invalid email address")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            
            if error != nil {
                self.view.makeToast(error!.localizedDescription)
            } else {
                self.view.makeToast("check your email account")
            }
        }
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        view.endEditing(true)
        
        SVProgressHUD.show()
        
        let email = emailTextField.text!.trim()
        let password = passwordTextField.text!.trim()
        
        if email == "" {
            self.view.makeToast("please enter email address")
            return
        } else if password == "" {
            self.view.makeToast("please enter password")
            return
        } else if !email.isValidEmail() {
            self.view.makeToast("Invalid email address")
            return
        }
        
        // Signing in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            SVProgressHUD.dismiss()
            
            if error != nil {
                self.view.makeToast(error!.localizedDescription)
            } else {
                
                UserDefaults.standard.set(true, forKey: "isLogin")
                
                let welcomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyTabbarVC") as! MyTabbarVC
                
                self.view.window?.rootViewController =  welcomeViewController
                self.view.window?.makeKeyAndVisible()
            }
        }
    }
}
    


