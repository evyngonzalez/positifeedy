//
//  EditProfileVc.swift
//  positifeedy
//
//  Created by iMac on 03/05/21.
//  Copyright © 2021 Evyn Gonzalez . All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage
import Toast_Swift
import AVKit
import AVFoundation
import SDWebImage
import FTPopOverMenu_Swift
import Alamofire
import EMPageViewController
import SVProgressHUD


class EditProfileVc: UIViewController,UIImagePickerControllerDelegate , UINavigationControllerDelegate, UITextViewDelegate{
    
    @IBOutlet weak var chooseBgimage: UIButton!
    
    @IBOutlet weak var ChooseAddUser: UIButton!
    @IBOutlet weak var ProfileImage: UIImageView!
    @IBOutlet weak var LoactionArea: UITextField!
    @IBOutlet weak var AboutName: UITextView!
    @IBOutlet weak var EditUserName: UITextField!
    @IBOutlet weak var AdduserImage: RoundableImageView!
    
    var IsBgImage = true
    
    var IsBgSet = false
    var IsProfileSet = false
    
    var myDocId : String?
    var isProfileImgLoad = true

    @IBOutlet weak var boxView: UIView!

    override func viewDidLoad() {
        
        DispatchQueue.main.async {
            self.boxView.layer.cornerRadius = 20
            self.boxView.dropShadow(color: .lightGray, opacity: 0.4, offSet: CGSize(width: 1, height: 1), radius: 20, scale: true)
        }
        
        profileData()
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        AboutName.delegate = self
        updateTextview()
    }
    
    func updateTextview() {
        if(AboutName.text.isEmpty){
            AboutName.text = "Something about you..."
            AboutName.textColor = UIColor.lightGray
        }else{
            AboutName.text = AboutName.text
            AboutName.textColor = UIColor.black
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Something about you..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    func profileData()
       {
           var db: Firestore!
           
           db = Firestore.firestore()
           
           db.collection("users").getDocuments { (snap, error) in
               if error != nil
               {
                   print("error ", error!.localizedDescription)
                   return
               }
               
               for doc in snap?.documents ?? []
               {
                   let  d = doc.data()
                   if d.count > 0
                   {
                       print("data = ",  d)
                       if (d["uid"] as! String)  ==  Auth.auth().currentUser?.uid
                       {
                        self.myDocId = doc.documentID
//                        self.EditUserName.text = String.init(format: "%@", (d["firstname"] as? String ?? ""))
                        self.EditUserName.text = String.init(format: "%@ %@", (d["firstname"] as? String ?? ""),(d["lastname"] as? String ?? ""))
                        self.AboutName.text = String.init(format: "%@", (d["About"] as? String ?? ""))
                         self.LoactionArea.text = String.init(format: "%@", (d["Location"] as? String ?? ""))
                        self.updateTextview()
                        
                        //    self.lblEmail.text = Auth.auth().currentUser?.email
                        
                        if let strURL = (d["profileImage"] as? String)
                        {
                            let url = URL(string: strURL)!
//                            self.activity.startAnimating()
//                            self.activity.isHidden = false
                            //                            DispatchQueue.global(qos: .background).async {
                            do
                            {
                                // let data = try Data(contentsOf: url!)
                                DispatchQueue.main.async {
                                    self.AdduserImage.sd_setImage(with: url, placeholderImage: UIImage(named: "profile-placeholder-big"), options: .highPriority)
                                   // self.activity.stopAnimating()
                                    //self.activity.isHidden = true
                                }
                                
                            }
                            catch   {
                                self.view.makeToast("Somthing went to wrong")
                            }
                            //                            }
                        }
                        if let strURL = (d["backgroundImage"] as? String)
                        {
                            let url = URL(string: strURL)!
                            // DispatchQueue.global(qos: .background).async {
                            do
                            {
                                self.ProfileImage.sd_setImage(with: url, placeholderImage: UIImage(named: "album_placeholder"), options: .highPriority)
                                
                            }
                            catch{
                                self.view.makeToast("Somthing went to wrong")
                            }
                            // }
                        }

                       }
                   }
                   
               }
           }
       }

    func uploadImage(imageType : Bool)  {

        let storage = Storage.storage()

        // Create a storage reference from our storage service
        let storageRef = storage.reference()

        // Create a reference to "mountains.jpg"
        var data = Data()
        if imageType {
            data = (ProfileImage.image?.jpegData(compressionQuality: 1.0)) ?? Data()
        }
        else {
            data = (AdduserImage.image?.jpegData(compressionQuality: 1.0)) ?? Data()
        }
        
        if(data.count == 0){
            SVProgressHUD.dismiss()
            self.view.makeToast("Something went wrong")
            return
        }
        var id = ""
        if imageType {
            id = Auth.auth().currentUser!.uid + "-Background" + ".jpg"
        }
        else {
            id = Auth.auth().currentUser!.uid + "-Profile" + ".jpg"
        }

        // Create a reference to 'images/mountains.jpg'
        let imgRef = storageRef.child("images").child(id)

        imgRef.putData(data, metadata: nil) { (dt, error) in
            SVProgressHUD.dismiss()
            if error != nil
            {
                self.view.makeToast(error!.localizedDescription)
                return
            }
            SVProgressHUD.show()
            imgRef.downloadURL { (url, err) in

                SVProgressHUD.dismiss()
                if err != nil
                {
                    self.view.makeToast(err!.localizedDescription)
                    return
                }

                guard let url = url else {
                    self.view.makeToast("Something went to wrong")
                    return
                }


                print("url => ", url)

                var db: Firestore!
                db = Firestore.firestore()
                var d = ["" : ""]
                if imageType {
                    d = ["backgroundImage" : url.absoluteString ]
                }
                else {
                    d = ["profileImage" : url.absoluteString ]
                }
                print(d)
                
               // self.activity.startAnimating()
              //  self.activity.isHidden = false
                SVProgressHUD.show()
                db.collection("users").document(self.myDocId ?? "").updateData(d as [AnyHashable : Any]) { [self] (er) in
                    //self.activity.stopAnimating()
                    //self.activity.isHidden = true
                    SVProgressHUD.dismiss()
                    if er != nil
                    {
                        self.view.makeToast(er?.localizedDescription)

                        return
                    }
                    if imageType {
                        self.IsBgSet = false
                    }else {
                        self.IsProfileSet = false
                    }

                    if self.IsProfileSet{
                        SVProgressHUD.show()
                        self.IsProfileSet = false
                        self.uploadImage(imageType: false)
                    }else{
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func backhome(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
       }
    @IBAction func settinglogout(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let answ = storyboard.instantiateViewController(withIdentifier: "SetttingScreenVC") as! SetttingScreenVC
        answ.modalPresentationStyle = .fullScreen
        answ.modalTransitionStyle = .crossDissolve
        self.present(answ, animated: true, completion: nil)
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        IsBgImage = true
        
            let alertVC = UIAlertController(title: "Postifieedy", message: "User profile", preferredStyle: .actionSheet)


            alertVC.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action) in

                self.openCameraOrPhoto(.camera)
            }))


            alertVC.addAction(UIAlertAction(title: "Photo Library", style: .default   , handler: { (action) in

                self.openCameraOrPhoto(.photoLibrary)
            }))


            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            present(alertVC, animated: true, completion: nil)
        
    }
    @IBAction func profileIMage(_ sender: UIButton) {
        IsBgImage = false
        let alertVC = UIAlertController(title: "Postifieedy", message: "User profile", preferredStyle: .actionSheet)

        alertVC.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action) in
            self.openCameraOrPhoto(.camera)
        }))

        alertVC.addAction(UIAlertAction(title: "Photo Library", style: .default   , handler: { (action) in
            self.openCameraOrPhoto(.photoLibrary)
        }))

        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alertVC, animated: true, completion: nil)
    }
    func openCameraOrPhoto( _ sourceType : UIImagePickerController.SourceType)  {

       if   UIImagePickerController.isSourceTypeAvailable(sourceType)
       {
            let vc = UIImagePickerController()
            vc.sourceType = sourceType
           vc.delegate = self
           vc.allowsEditing = true
           self.present(vc, animated: true,completion: nil)
        
//               let vc = UIImagePickerController()
//               vc.sourceType = sourceType
//               vc.delegate = self
//               present(vc, animated: true)
       }
   }
    
            
        
        //MARK:- Open Gallery Click on button
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
            
            let imag_var = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as! UIImage
            if IsBgImage {
                IsBgSet = true
                ProfileImage.image = imag_var
                //chooseBgimage.setImage(nil, for: .normal)
            }
            else
            {
                IsProfileSet = true
                AdduserImage.image = imag_var
                //chooseBgimage.setImage(nil, for: .normal)
                
            }
            self.dismiss(animated: true, completion: nil)
            
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
            
        }
    
    
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }

    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertToUITextDirection(_ input: Int) -> UITextDirection {
        return UITextDirection(rawValue: input)
    }

    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
    
    @IBAction func saveimages(_ sender: Any) {
        
        SVProgressHUD.show()
        if IsBgSet{
            uploadImage(imageType: true)
        }else{
            if IsProfileSet{
                uploadImage(imageType: false)
            }
        }
        
        
        //AboutUS
        if(AboutName.text != "Something about you..."){
            let d1 = ["About" : self.AboutName.text]
               var db1: Firestore!
               db1 = Firestore.firestore()
               db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
                   if error != nil
                   {
                       print(error!.localizedDescription)
                   }
               }
        }
            //Location
        let d2 = ["Location" : self.LoactionArea.text]
       var db2: Firestore!
       db2 = Firestore.firestore()
       db2.collection("users").document(self.myDocId!).updateData(d2) { (error) in
           if error != nil
           {
               print(error!.localizedDescription)
           }
        //Name
        let d3 = ["firstname" : self.EditUserName.text,"lastname" : ""] as [String : Any]
           var db3: Firestore!
           db3 = Firestore.firestore()
           db3.collection("users").document(self.myDocId!).updateData(d3) { (error) in
               if error != nil
               {
                   print(error!.localizedDescription)
               }
                if(!self.IsBgSet && !self.IsProfileSet){
                    SVProgressHUD.dismiss()
                    self.navigationController?.popViewController(animated: true)
                }
           }
       }
           
        
    }

}

//extension EditProfileVc : UIImagePickerControllerDelegate , UINavigationControllerDelegate
//{
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        isProfileImgLoad = false
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//
//         AdduserImage.image = (info[UIImagePickerController.InfoKey.originalImage] as! UIImage)
//        isProfileImgLoad = false
//        picker.dismiss(animated: true, completion: nil)
//        uploadImage()
//
//    }
//}
