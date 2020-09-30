//
//  signUpViewController.swift
//  positifeedy
//
//  Created by Evyn Gonzalez  on 9/12/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Toast_Swift

class signUpViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPassTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       setUpElements()
    
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
               view.addGestureRecognizer(tap)
    
    }
    
    @objc func tapHandler( _ gesture : UITapGestureRecognizer)  {
           
           view.endEditing(true)
           
       }
       
    
    
    func setUpElements() {
        errorLabel.alpha = 0

    }
    
    func validateFields() -> String? {
         
        
           // Check that all fields are filled in
           if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
               lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
               emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
               passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
               
               return "Please fill in all fields."
           }
           
           // Check if the password is secure
           let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
           
           if Utilities.isPasswordValid(cleanedPassword) == false {
               // Password isn't secure enough
               return "Please make sure your password is at least 8 characters, contains a special character and a number."
           }
           
           return nil
       }
    
     @IBAction func signUpTapped(_ sender: Any) {
        
        let error = validateFields()
                self.view.endEditing(true)
               if error != nil {
                   
                   // There's something wrong with the fields, show error message
//                   showError(error!)
               
                self.view.makeToast(error!)
                
               }
               else {
                   
                   // Create cleaned versions of the data
                   let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                   let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                   let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                   let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                   
                   // Create the user
                   Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                       
                       // Check for errors
                       if err != nil {
                           
                           // There was an error creating the user
//                           self.showError("Error creating user")
                           self.view.makeToast("Error creating user")
                       }
                       else {
                           
                        
                         UserDefaults.standard.set(true, forKey: "isLogin")
                        
                           // User was created successfully, now store the first name and last name
                           let db = Firestore.firestore()
                           
                           db.collection("users").addDocument(data: ["firstname":firstName, "lastname":lastName, "uid": result!.user.uid ]) { (error) in
                               
                               if error != nil {
                                   // Show error message
//                                   self.showError("Error saving user data")
                                     self.view.makeToast("Error saving user data")
                                 return
                               }
                           }
                           
                           // Transition to the home screen
                           self.transitionToHome()
                       }
                       
                   }
                   
                   
                   
               }
           }
           
           func showError(_ message:String) {
               
               errorLabel.text = message
               errorLabel.alpha = 1
           }
           
           func transitionToHome() {
               
//               let welcomeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.welcomeViewController) as? welcomeViewController
            
            
            
//            let welcomeViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.welcomeViewController) as! welcomeViewController
            
              let welcomeViewController = storyboard?.instantiateViewController(withIdentifier: "MyTabbarVC") as! MyTabbarVC
            
               view.window?.rootViewController = welcomeViewController
               view.window?.makeKeyAndVisible()
               
           }
           
        
        
     }

