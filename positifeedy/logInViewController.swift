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
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit

class logInViewController: UIViewController, GIDSignInDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var dictSocial = [String: String]()

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
        
        SVProgressHUD.show()

        // Signing in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            SVProgressHUD.dismiss()
            
            if error != nil {
                self.view.makeToast(error!.localizedDescription)
            } else {
                
                UserDefaults.standard.set(true, forKey: "isLogin")
                                
                // Transition to the home screen
                self.transitionToHome()
            }
        }
    }
    
    //MARK:- Facebook & Google login
    @IBAction func btnFacebook(_ sender: Any) {
        
        SVProgressHUD.show()
        
        LoginManager().logIn(permissions: ["email", "public_profile"], from: self) { (result, err) in
            
            if(err != nil){
                SVProgressHUD.dismiss()
                print("Custom FB Login Failed")
                return
            }
            
            let accesstoken = AccessToken.current;
            guard (accesstoken?.tokenString) != nil else {
                SVProgressHUD.dismiss()
                return
            }
            
            GraphRequest(graphPath: "/me", parameters: ["fields": "id, name, first_name, last_name, email"]).start { (connection, result, err) in
                
                if(err != nil){
                    SVProgressHUD.dismiss()
                    print("Failed to start GraphRequest", err ?? "")
                    return
                }
                
                print("Facebook LoginData Result :\(result ?? "")")
                let details = result as! NSDictionary
                let email = details.value(forKey: "email") as? String ?? ""
                let fName = details.value(forKey: "first_name") as? String ?? ""
                let lName = details.value(forKey: "last_name") as? String ?? ""
                let socialId = details.value(forKey: "id") as? String ?? ""
                
                self.dictSocial = [
                    "email": email,
                    "fname": fName,
                    "lName": lName,
                    "socialId": socialId
                ]
                
                print("email: \(email), fName: \(fName), lName: \(lName), socialId: \(socialId)")
                
                let credential = FacebookAuthProvider.credential(withAccessToken: accesstoken!.tokenString)
                self.authenticateWithFacebook(credential: credential)
            }
        }
    }
    
    @IBAction func btnGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
    {
        if let error = error {
            print("Error while google sign in :\(error.localizedDescription)")
            return
        }
        
        guard let authentication = user.authentication else { return }
        
        SVProgressHUD.show()
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        print(credential)
        
        
        let email = user.profile.email ?? ""
        let userId = user.userID ?? ""
        let idToken = user.authentication.idToken
        let fullName = user.profile.name ?? ""
        let givenName = user.profile.givenName ?? ""
        let familyName = user.profile.familyName ?? ""
        
        self.dictSocial = [
            "email": email,
            "fname": givenName,
            "lName": familyName,
            "socialId": userId
        ]
        
        print("email: \(email ?? ""), userId: \(userId), idToken: \(idToken), fullName: \(fullName), givenName: \(givenName), familyName: \(familyName)")
        
        authenticateWithGoogle(credential: credential)
        
    }
    
    func authenticateWithFacebook(credential: AuthCredential)
    {
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                SVProgressHUD.dismiss()
                self.view.makeToast(error.localizedDescription)
                return
            }
            
            // success
            self.checkUserIfAlready(firstName: self.dictSocial["fname"]!, lastName: self.dictSocial["lName"]!, uid: authResult!.user.uid)
        }
    }
    
    func authenticateWithGoogle(credential: AuthCredential)
    {
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                SVProgressHUD.dismiss()
                self.view.makeToast(error.localizedDescription)
                return
            }
            
            // success
            self.checkUserIfAlready(firstName: self.dictSocial["fname"]!, lastName: self.dictSocial["lName"]!, uid: authResult!.user.uid)
        }
    }
    
    func checkUserIfAlready(firstName: String, lastName: String, uid: String)
    {
        var db: Firestore!
        
        db = Firestore.firestore()
        
        db.collection("users").whereField("uid", isEqualTo: uid).getDocuments { (snap, error) in
            
            if error != nil
            {
                print("error ", error!.localizedDescription)
                
                self.createUserCloudData(firstName: firstName, lastName: lastName, uid: uid)
                return
            }
            
            if snap != nil {
                if snap!.documents.count > 0 {
                    
                    let data = ["firstname":firstName, "lastname":lastName, "uid": uid]
                    db.collection("users").document(snap!.documents[0].documentID).updateData(data) { (error) in
                        
                        SVProgressHUD.dismiss()
                        if error != nil
                        {
                            print(error!.localizedDescription)
                        }
                        
                        UserDefaults.standard.set(true, forKey: "isLogin")
                        self.transitionToHome()
                    }
                } else {
                    self.createUserCloudData(firstName: firstName, lastName: lastName, uid: uid)
                }
            } else {
                self.createUserCloudData(firstName: firstName, lastName: lastName, uid: uid)
            }
            
        }
    }
    
    func createUserCloudData(firstName: String, lastName: String, uid: String) {
        
        // User was created successfully, now store the first name and last name
        let db = Firestore.firestore()
        
        db.collection("users").addDocument(data: ["firstname":firstName, "lastname":lastName, "uid": uid]) { (error) in
            
            SVProgressHUD.dismiss()
            
            if error != nil {
                // Show error message
                self.view.makeToast("Error saving user data")
                return
            }
            
            UserDefaults.standard.set(true, forKey: "isLogin")
            
            // Transition to the home screen
            self.transitionToHome()
        }
    }
    
    func transitionToHome() {
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.setRoot()
    }
}
    


