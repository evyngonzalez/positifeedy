//
//  logInViewController.swift
//  positifeedy
//
//  Created by Evyn Gonzalez  on 9/12/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

//shidhdharthjoshi.weapplinse@gmail.com
//123456

import UIKit
import Firebase
import FirebaseAuth
import Toast_Swift
import SVProgressHUD
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
import VideoBackground

class logInViewController: UIViewController, GIDSignInDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var googleview: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var fbview: UIView!
    
    @IBOutlet weak var scrollview: UIScrollView!
    var dictSocial = [String: String]()

    @IBOutlet weak var btnsignup: UIButton!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.design()
        self.setupVideoView()
        setUpElements()
        //
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        view.addGestureRecognizer(tap)
    }
    
    private func setupVideoView() {
        
        guard let videoPath = Bundle.main.path(forResource: "splash", ofType: "mov") else {
                return
        }
        
        let options = VideoOptions(pathToVideo: videoPath, pathToImage: "",
                                   isMuted: true,
                                   shouldLoop: true)
        let videoView = VideoBackground(frame: view.frame, options: options)
        view.insertSubview(videoView, at: 0)
    }
    
    func design() -> Void
    {
        self.scrollview.contentSize = CGSize.init(width: self.view.frame.size.width, height: self.btnsignup.frame.origin.y + self.btnsignup.frame.size.height + 50)
        
        self.loginButton.layer.cornerRadius = 5
        self.loginButton.clipsToBounds = true
        
        self.fbview.layer.cornerRadius = 5
        self.fbview.clipsToBounds = true
        
        self.googleview.layer.cornerRadius = 5
        self.googleview.clipsToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
//                let prefdate = UserDefaults.standard.object(forKey: PREF_CURRENT_DATE) as? String
//                if prefdate != nil
//                {
//                    let dateString = prefdate
//                    let dateFormatter = DateFormatter()
//                    dateFormatter.dateFormat = "yyyy-MM-dd"
//                    let start_date = dateFormatter.date(from: dateString!)
//                    let final_date = Date()
//                    let diff = final_date.interval(ofComponent: .day, fromDate: start_date!)
//                    print("diffrent day :\(diff)")
//                    
//                    // here in future set 100
//                    if diff > 5
//                    {
//                        UserDefaults.standard.setValue(1, forKey: PREF_DAILY_QUESTION_COUNT)
//                    }
//                    else
//                    {
//                        UserDefaults.standard.setValue(diff, forKey: PREF_DAILY_QUESTION_COUNT)
//                    }
//                    
//                    
//        //            let dateFormatter1 = DateFormatter()
//        //            dateFormatter1.dateFormat = "yyyy-MM-dd"
//        //            let final_date = dateFormatter1.date(from: "2020-12-20")
//                    
//                    
//
//                    
//                }
//                else
//                {
//                    
//                    let date = Date()
//                    let dateFormatter = DateFormatter()
//                    dateFormatter.dateFormat = "yyyy-MM-dd"
//                    let dateString = dateFormatter.string(from: date)
//                    UserDefaults.standard.setValue(dateString, forKey: PREF_CURRENT_DATE)
//                    
//                    let dateString1 = dateString
//                    let dateFormatter1 = DateFormatter()
//                    dateFormatter1.dateFormat = "yyyy-MM-dd"
//                    let start_date = dateFormatter1.date(from: dateString1)
//                    let final_date = Date()
//                    let diff = final_date.interval(ofComponent: .day, fromDate: start_date!)
//                    print("diffrent day :\(diff)")
//                    UserDefaults.standard.setValue(diff, forKey: PREF_DAILY_QUESTION_COUNT)
//                    
//                    
//                    
//        //           let dateString = "Thu, 22 Oct 2015 07:45:17 +0000"
//        //           let dateFormatter = DateFormatter()
//        //           dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
//        //           dateFormatter.locale = Locale.init(identifier: "en_GB")
//        //
//        //           let dateObj = dateFormatter.date(from: dateString)
//        //
//        //           dateFormatter.dateFormat = "MM-dd-yyyy"
//        //           print("Dateobj: \(dateFormatter.string(from: dateObj!))")
//                    
//                }
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
                  
                let appDel = UIApplication.shared.delegate as! AppDelegate
                appDel.setRoot()
                
                // Transition to the home screen
                //self.transitionToHome()
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
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
       let vcSubscri = storyboard.instantiateViewController(withIdentifier: "SubscriptionViewController") as! SubscriptionViewController
       vcSubscri.modalPresentationStyle = .fullScreen
       vcSubscri.modalTransitionStyle = .crossDissolve
        self.present(vcSubscri, animated: true, completion: nil)
        
        
        //let appDel = UIApplication.shared.delegate as! AppDelegate
        //appDel.setRoot()
    }
}
    


