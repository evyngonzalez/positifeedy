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
    
    func setUpElements() {
        errorLabel.alpha = 0
    
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        // TODO: Validate Text Fields
            
        view.endEditing(true)
            // Create cleaned versions of the text field
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Signing in the user
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                
                if error != nil {
                    // Couldn't sign in
//                    self.errorLabel.text =
//                    self.errorLabel.alpha = 1
                    self.view.makeToast(error!.localizedDescription)
                }
                else {
                    
                    UserDefaults.standard.set(true, forKey: "isLogin")
                    
//                    let welcomeViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.welcomeViewController) as? welcomeViewController
//                    let welcomeViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.welcomeViewController) as! welcomeViewController
                    
                    let welcomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyTabbarVC") as! MyTabbarVC
                    
                    self.view.window?.rootViewController =  welcomeViewController
                    self.view.window?.makeKeyAndVisible()
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


