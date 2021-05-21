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
import VideoBackground
import AuthenticationServices
import CryptoKit

class signUpViewController: UIViewController, GIDSignInDelegate,ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding
{
    
    fileprivate var currentNonce: String?
    var flag : Int = 0
   
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPassTextField: UITextField!
    
    @IBOutlet weak var lblbottomLine: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var btngoogle: UIView!
    @IBOutlet weak var appleview: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var btnfacebook: UIView!
    @IBOutlet weak var btnemail: UIView!
    @IBOutlet weak var scrollview: UIScrollView!
    
    @IBOutlet weak var lblaleardy: UILabel!
    var dictSocial = [String: String]()
    
    @IBOutlet weak var alltextfieldsview: UIView!
    @IBOutlet weak var bottomviw: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.design()
        self.setupVideoView()
        
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
    
    
    func design() -> Void {
        
        self.appleview.layer.cornerRadius = 5
        self.appleview.clipsToBounds = true
        self.appleview.layer.borderColor = UIColor.init(red: 37/255, green: 250/255, blue: 168/255, alpha: 1).cgColor
        self.appleview.layer.borderWidth = 2
        
        self.btngoogle.layer.cornerRadius = 5
       self.btngoogle.clipsToBounds = true
       self.btngoogle.layer.borderColor = UIColor.init(red: 37/255, green: 250/255, blue: 168/255, alpha: 1).cgColor
       self.btngoogle.layer.borderWidth = 2
        
        self.btnfacebook.layer.cornerRadius = 5
        self.btnfacebook.clipsToBounds = true
        self.btnfacebook.layer.borderColor = UIColor.init(red: 37/255, green: 250/255, blue: 168/255, alpha: 1).cgColor
        self.btnfacebook.layer.borderWidth = 2
        
        self.btnemail.layer.cornerRadius = 5
        self.btnemail.clipsToBounds = true
        self.btnemail.layer.borderColor = UIColor.init(red: 37/255, green: 250/255, blue: 168/255, alpha: 1).cgColor
        self.btnemail.layer.borderWidth = 2
        
        
        self.signUpButton.layer.cornerRadius = 5
        self.signUpButton.clipsToBounds = true
        self.signUpButton.layer.borderColor = UIColor.init(red: 37/255, green: 250/255, blue: 168/255, alpha: 1).cgColor
        self.signUpButton.layer.borderWidth = 2
        
        self.lblbottomLine.colorString2(text:"By signing up you are agreeing to our Privacy Policy & Terms and Conditions", coloredText1:"Privacy Policy", coloredText2: "Terms and Conditions")
        
        
        self.lblaleardy.colorString2(text:"Already have an account? Log In", coloredText1:"Log In", coloredText2: "")
        
        //self.scrollview.contentSize = CGSize.init(width: self.view.frame.size.width, height: self.lblaleardy.frame.origin.y + self.lblaleardy.frame.size.height + 50)
        
        self.setUpDesign()
        
    }
    
    func setUpDesign() -> Void {
        
        self.alltextfieldsview.isHidden = true
        self.bottomviw.frame = CGRect.init(x: 0, y: self.btnemail.frame.origin.y + self.btnemail.frame.size.height +  10, width: self.bottomviw.frame.size.width, height: self.bottomviw.frame.size.height)
        
        self.scrollview.contentSize = CGSize.init(width: self.view.frame.size.width, height: self.bottomviw.frame.size.height + self.bottomviw.frame.origin.y)
    }
    
    func setDownDesign() -> Void
    {
        self.alltextfieldsview.isHidden = false
           self.bottomviw.frame = CGRect.init(x: 0, y: self.alltextfieldsview.frame.origin.y + self.alltextfieldsview.frame.size.height +  10, width: self.bottomviw.frame.size.width, height: self.bottomviw.frame.size.height)
           
           self.scrollview.contentSize = CGSize.init(width: self.view.frame.size.width, height: self.bottomviw.frame.size.height + self.bottomviw.frame.origin.y)
       }
    
     @available(iOS 13, *)
          func startSignInWithAppleFlow() {
              let nonce = randomNonceString()
              currentNonce = nonce
              let appleIDProvider = ASAuthorizationAppleIDProvider()
              let request = appleIDProvider.createRequest()
              request.requestedScopes = [.fullName, .email]
              request.nonce = sha256(nonce)
              
              let authorizationController = ASAuthorizationController(authorizationRequests: [request])
              authorizationController.delegate = self
              authorizationController.presentationContextProvider = self
              authorizationController.performRequests()
          }
          
          @available(iOS 13, *)
          private func sha256(_ input: String) -> String {
              let inputData = Data(input.utf8)
            let hashedData = inputData.digest(using: .sha256)
//              let hashedData = SHA256.hash(data: inputData)
              let hashString = hashedData.compactMap {
                  return String(format: "%02x", $0)
              }.joined()
              
              return hashString
          }
          
          private func randomNonceString(length: Int = 32) -> String {
              precondition(length > 0)
              let charset: Array<Character> =
                  Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
              var result = ""
              var remainingLength = length
              
              while remainingLength > 0 {
                  let randoms: [UInt8] = (0 ..< 16).map { _ in
                      var random: UInt8 = 0
                      let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                      if errorCode != errSecSuccess {
                          fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                      }
                      return random
                  }
                  randoms.forEach { random in
                      if length == 0 {
                          return
                      }
                      
                      if random < charset.count {
                          result.append(charset[Int(random)])
                          remainingLength -= 1
                      }
                  }
              }
              return result
          }
        
        @available(iOS 13, *)
        //MARK:- apple sign in :
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if (error != nil) {
                        // Error. If error.code == .MissingOrInvalidNonce, make sure
                        // you're sending the SHA256-hashed nonce as a hex string with
                        // your request to Apple.
                        print(error?.localizedDescription ?? "")
                        return
                    }
                    guard let user = authResult?.user else { return }
                    let email = user.email ?? ""
                    if email != ""
                    {
                        let namear = email.components(separatedBy: "@")
                        let fname = namear[0]
                        let displayName = user.displayName ?? fname
                        guard let uid = Auth.auth().currentUser?.uid else { return }
                       
                        print("Apple :")
                        print("email :\(email)")
                        print("displayname :\(displayName)")
                        print("email :\(uid)")
                        // success
                        self.checkUserIfAlready(firstName: displayName, lastName: "", uid: uid)
                        
                    }
                    
    //                let db = Firestore.firestore()
    //                db.collection("User").document(uid).setData([
    //                    "email": email,
    //                    "displayName": displayName,
    //                    "uid": uid
    //                ]) { err in
    //                    if let err = err {
    //                        print("Error writing document: \(err)")
    //                    } else {
    //                        print("the user has sign up or is logged in")
    //                    }
    //                }
                }
            }
        }
              @available(iOS 13, *)
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            // Handle error.
            print("Sign in with Apple errored: \(error)")
        }
              @available(iOS 13, *)
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            return self.view.window!
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
                        
//                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                        let vcSubscri = storyboard.instantiateViewController(withIdentifier: "SubscriptionViewController") as! SubscriptionViewController
//                        vcSubscri.modalPresentationStyle = .fullScreen
//                        vcSubscri.modalTransitionStyle = .crossDissolve
//                        self.present(vcSubscri, animated: true, completion: nil)
                        
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
    
    
    
    @IBAction func onclickforEmail(_ sender: Any)
    {
        if self.flag == 0
        {
            self.flag = 1
            self.setDownDesign()
            
        }else
        {
            self.flag = 0
            self.setUpDesign()
        }
        
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
    
    @IBAction func onclickforapple(_ sender: Any) {
              
        if #available(iOS 13, *) {
           self.startSignInWithAppleFlow()
        } else {
            // show sad face emoji
        }
        
    }
    
    @IBAction func btnGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func onclickforPrvacyPolicy(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let answ = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyScreenVC") as! PrivacyPolicyScreenVC
        answ.modalPresentationStyle = .fullScreen
        answ.modalTransitionStyle = .crossDissolve
        self.present(answ, animated: true, completion: nil)
    }
    
    
    @IBAction func onclickfortermsAndconditons(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let answ = storyboard.instantiateViewController(withIdentifier: "TermsNConditionVC") as! TermsNConditionVC
        answ.modalPresentationStyle = .fullScreen
        answ.modalTransitionStyle = .crossDissolve
        self.present(answ, animated: true, completion: nil)
        
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

extension UILabel
{

    func colorString(text: String?, coloredText1: String?,coloredText2: String?, color: UIColor? = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)) {

    let attributedString = NSMutableAttributedString(string: text!)
    let range = (text! as NSString).range(of: coloredText1!)
        attributedString.setAttributes([NSAttributedString.Key.foregroundColor: color!],
                             range: range)
    let range2 = (text! as NSString).range(of: coloredText2!)
        attributedString.setAttributes([NSAttributedString.Key.foregroundColor: color!],
                             range: range2)
        
    self.attributedText = attributedString
    }
    
    
    func colorString2(text: String?, coloredText1: String?,coloredText2: String?, color: UIColor? = UIColor.init(red: 37/255, green: 250/255, blue: 168/255, alpha: 1)) {

       let attributedString = NSMutableAttributedString(string: text!)
       let range = (text! as NSString).range(of: coloredText1!)
           attributedString.setAttributes([NSAttributedString.Key.foregroundColor: color!],
                                range: range)
       let range2 = (text! as NSString).range(of: coloredText2!)
           attributedString.setAttributes([NSAttributedString.Key.foregroundColor: color!],
                                range: range2)
           
       self.attributedText = attributedString
       }
}
