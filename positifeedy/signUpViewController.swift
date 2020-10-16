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
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
import SVProgressHUD

class signUpViewController: UIViewController, GIDSignInDelegate {
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPassTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var dictSocial = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // for test
//        firstNameTextField.text = "vipul"
//        lastNameTextField.text = "thummar"
//        emailTextField.text = "shidhdharthjoshi.weapplinse@gmail.com"
//        passwordTextField.text = "Vipul@123"
//        confirmPassTextField.text = "Vipul@123"
        
        setUpElements()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func tapHandler( _ gesture : UITapGestureRecognizer)  {
        
        view.endEditing(true)
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setUpElements() {
        errorLabel.alpha = 0
    }
    
    func validateFields() -> String? {
        
        let firstName = firstNameTextField.text!.trim()
        let lastName = lastNameTextField.text!.trim()
        let email = emailTextField.text!.trim()
        let password = passwordTextField.text!.trim()
        let confirmPassword = confirmPassTextField.text!.trim()
        
        if firstName == "" || lastName == "" || email == "" || password == "" || confirmPassword == "" {
            
            return "Please fill in all fields."
        }
        
        if !email.isValidEmail() {
            return "Invalid email address"
        }
        
        if Utilities.isPasswordValid(password) == false {
            return "Please make sure your password is at least 8 characters, contains a special character and a number."
        }
        
        if password != confirmPassword {
            return "passwords does not match."
        }
        
        return nil
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        
        self.view.endEditing(true)
        
        let error = validateFields()
        
        if error != nil {
            
            // There's something wrong with the fields, show error message
            //                   showError(error!)
            
            self.view.makeToast(error!)
            
        }
        else {
            
            SVProgressHUD.show()
            
            // Create cleaned versions of the data
            let firstName = firstNameTextField.text!.trim()
            let lastName = lastNameTextField.text!.trim()
            let email = emailTextField.text!.trim()
            let password = passwordTextField.text!.trim()
            
            self.checkIfOldUser(email: email, password: password) { (valid) in
                
                if valid {
                    
                    let actionCodeSettings = ActionCodeSettings()
                    actionCodeSettings.url = URL(string: "https://positifeedy.page.link/eNh4")
//                    actionCodeSettings.dynamicLinkDomain = "positifeedy.com"
                    // The sign-in operation has to always be completed in the app.
                    actionCodeSettings.handleCodeInApp = true
                    actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
                    
                    Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { (error) in
                        
                        SVProgressHUD.dismiss()
                        
                        if error != nil {
                            self.view.makeToast(error!.localizedDescription)
                            return
                        }
                        
                        UserDefaults.standard.set(email, forKey: "emailRegister")
                        UserDefaults.standard.set(password, forKey: "passwordRegister")
                        UserDefaults.standard.set(firstName, forKey: "firstNameRegister")
                        UserDefaults.standard.set(lastName, forKey: "lastNameRegister")
                        
                        self.showAlert(title: "Verification", message: "Check your email for link", linkHandler: nil)
                    }
                    
                    // Create the user
                    //                    Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                    //
                    //                        // Check for errors
                    //                        if err != nil {
                    //                            self.view.makeToast("Error creating user")
                    //                        } else {
                    //                            self.createUserCloudData(firstName: firstName, lastName: lastName, uid: result!.user.uid)
                    //                        }
                    //                    }
                } else {
                    SVProgressHUD.dismiss()
                    self.view.makeToast("Email address already registered")
                }
            }
            
        }
    }
    
    func checkIfOldUser(email: String, password: String, completion: @escaping(_ valid: Bool) -> Void) {
        
        Auth.auth().fetchSignInMethods(forEmail: email) { (arr, err) in
            
            // Check for errors
            if err != nil {
                completion(true)
                
            } else {
                if arr != nil {
                    if arr!.count > 0 {
                        completion(false)
                    } else {
                        completion(true)
                    }
                } else {
                    completion(true)
                }
            }
        }
    }
    
    func showError(_ message:String) {
        
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToHome() {
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.setRoot()
    }
    
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
}

