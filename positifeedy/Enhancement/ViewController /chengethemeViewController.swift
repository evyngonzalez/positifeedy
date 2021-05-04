//
//  chengethemeViewController.swift
//  positifeedy
//
//  Created by iMac on 24/04/21.
//  Copyright © 2021 Evyn Gonzalez . All rights reserved.
//

import UIKit
import Firebase
import AVKit
import SVProgressHUD

class chengethemeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    @IBOutlet weak var clvPresetTheme: UICollectionView!
    @IBOutlet weak var clvOwnTheme: UICollectionView!
    @IBOutlet weak var sliderVolume: UISlider!
    
    @IBOutlet weak var btnSaveChanges: UIButton!
    
    //Light Dark font
    @IBOutlet weak var viewLight: UIView!
    @IBOutlet weak var lblAbLight: UILabel!
    @IBOutlet weak var lblLight: UILabel!
    
    @IBOutlet weak var viewDark: UIView!
    @IBOutlet weak var lblAbDark: UILabel!
    @IBOutlet weak var lblDark: UILabel!
    
    let lightColor = UIColor.black
    let darkColor = UIColor.white
    
    var initialVolume : Float = 0.0
    
    var IsLightSelected = false
    
    let imagePickerController = UIImagePickerController()
    var videoURL: NSURL?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.getProfileData()
        }
        
        // Do any additional setup after loading the view.
        
        btnSaveChanges.layer.cornerRadius = 8
        
        clvPresetTheme.delegate = self
        clvPresetTheme.dataSource = self
        
        clvOwnTheme.delegate = self
        clvOwnTheme.dataSource = self
        
        initialVolume = videoPlayer.volume
        
        updateLightDarkButtons()
    }
    
    var myUserId = ""
    var IsSubscription = false
    var userData = NSMutableDictionary()
    var themeData = NSMutableDictionary()
    
    func getProfileData() {
        SVProgressHUD.show()

        var db: Firestore!
        db = Firestore.firestore()
        db.collection("userNew").getDocuments { [self] (snap, error) in
            
            SVProgressHUD.dismiss()

            if error != nil
            {
                print("error ", error!.localizedDescription)
                return
            }
            for doc in snap?.documents ?? []
            {
                let  d = doc.data()
//                print(d["uid"])
                if d.count > 0
                {
                    print("data = ",  d)
                    
                    if (d["uid"] as! String)  ==  Auth.auth().currentUser?.uid
                    {
                        self.myUserId = doc.documentID
                        self.userData = (d as NSDictionary).mutableCopy() as! NSMutableDictionary
                        self.themeData = (self.userData.value(forKey: "CurrentTheme") as? NSDictionary ?? NSDictionary()).mutableCopy() as? NSMutableDictionary ?? NSMutableDictionary()
                        
                        self.IsSubscription = (self.userData.value(forKey: "Subscription") as! String)=="0" ? false:true
                        
                        let volume = self.themeData.value(forKey: "volume") as? Float ?? 0.0
                        self.sliderVolume.value = volume
                        
                        self.IsLightSelected = self.themeData.value(forKey: "TextColorIsLight") as? Bool ?? true
                        updateLightDarkButtons()
                        self.updateUI()
                        
                        break
                    }
                }
            }
        }
    }
    
    func updateUI() {
        
        self.clvPresetTheme.reloadData()
        self.clvOwnTheme.reloadData()
        print(themeData)
    }
    
    func updateLightDarkButtons() {
        
        //Light
        viewLight.layer.cornerRadius = 5
        viewLight.layer.borderColor = lightColor.cgColor
        viewLight.layer.borderWidth = 1
        
        lblAbLight.layer.cornerRadius = 3
        lblAbLight.layer.borderColor = lightColor.cgColor
        lblAbLight.layer.borderWidth = 1
        
        lblLight.textColor = lightColor
        lblAbLight.textColor = lightColor
        
        viewLight.backgroundColor = darkColor
        viewLight.layer.shadowColor = darkColor.cgColor
        viewLight.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        viewLight.layer.shadowRadius = 0.0
        viewLight.layer.shadowOpacity = 0.0

        //Dark
        viewDark.layer.cornerRadius = 5
        viewDark.layer.borderColor = lightColor.cgColor
        viewDark.layer.borderWidth = 1
        
        lblAbDark.layer.cornerRadius = 3
        lblAbDark.layer.borderColor = lightColor.cgColor
        lblAbDark.layer.borderWidth = 1
        
        lblDark.textColor = lightColor
        lblAbDark.textColor = lightColor
        
        viewDark.backgroundColor = darkColor
        viewDark.layer.shadowColor = darkColor.cgColor
        viewDark.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        viewDark.layer.shadowRadius = 0.0
        viewDark.layer.shadowOpacity = 0.0

        
        if(IsLightSelected){
            viewLight.layer.shadowColor = UIColor.black.cgColor
            viewLight.layer.shadowRadius = 4.0
            viewLight.layer.shadowOpacity = 1.0
            
            viewLight.backgroundColor = lightColor
            
            lblAbLight.layer.borderColor = darkColor.cgColor
            lblAbLight.textColor = darkColor
            lblLight.textColor = darkColor

            viewLight.layer.borderColor = UIColor.green.cgColor

        }else{
            viewDark.layer.shadowColor = UIColor.black.cgColor
            viewDark.layer.shadowRadius = 4.0
            viewDark.layer.shadowOpacity = 1.0
            
            viewDark.backgroundColor = lightColor
            
            lblAbDark.layer.borderColor = darkColor.cgColor
            lblAbDark.textColor = darkColor
            lblDark.textColor = darkColor

            viewDark.layer.borderColor = UIColor.green.cgColor

        }
        
        
    }

//    videoPlayer
    
    //MARK:- Slider delegate - Volume change
    @IBAction func volumeSliderChanged(_ sender: Any) {
        
        videoPlayer.volume = sliderVolume.value
        
    }
    
    //MARK:- Button Click
    @IBAction func btnLightClick(_ sender: Any) {
        IsLightSelected = true
        updateLightDarkButtons()
    }
    
    @IBAction func btnDarkClick(_ sender: Any) {
        IsLightSelected = false
        updateLightDarkButtons()
    }
    
    @IBAction func btnBackClick(_ sender: Any) {
        videoPlayer.volume = initialVolume
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSaveThemeClick(_ sender: Any) {
        
        videoPlayer.volume = sliderVolume.value
        
//        update theme data
        self.themeData.setValue(IsLightSelected, forKey: "TextColorIsLight")
        self.themeData.setValue(sliderVolume.value, forKey: "volume")

        if(!dictSelection.isEmpty){
            let IsVideoTheme = dictSelection["isVideo"] as? Bool ?? false
            let themeUrl = dictSelection["themeUrl"] as! String

            self.themeData.setValue(IsVideoTheme, forKey: "isVideo")
            self.themeData.setValue(themeUrl, forKey: "themeUrl")
        }

        let theme = [
            "CurrentTheme" : themeData
        ]
        
        var db: Firestore!
        db = Firestore.firestore()
        SVProgressHUD.show()
        
        if(isPhoto == nil){
            db.collection("userNew").document(self.myUserId).updateData(theme) { (error) in
                SVProgressHUD.dismiss()
                UserDefaults.standard.set(true, forKey: "IsThemeChange")
                UserDefaults.standard.synchronize()
                self.navigationController?.popViewController(animated: true)
            }
        }else if(isPhoto == true){
            self.themeData.setValue(false, forKey: "isVideo")
            uploadImage(selectedImage: selectedImage!)
        }else if(isPhoto == false){
            self.themeData.setValue(true, forKey: "isVideo")
            uploadVideo()
        }
        
        
        if(!dictSelection.isEmpty){
            let IsVideoTheme = dictSelection["isVideo"] as? Bool ?? false
            let themeUrl = dictSelection["themeUrl"] as! String

            let selectedTheme = themeData.value(forKey: "themeUrl")as? String ?? ""
            if(themeUrl != selectedTheme){
                
                let themeData = [
                    "themeUrl" : themeUrl,
                    "volume" : sliderVolume.value,
                    "isVideo" : IsVideoTheme
                ] as [String : Any]
                
                
                
                let theme = [
                    "CurrentTheme" : themeData
                ]
                var db: Firestore!
                db = Firestore.firestore()
                db.collection("userNew").document(self.myUserId).updateData(theme) { (error) in
                    SVProgressHUD.dismiss()
                    if error != nil
                    {
                        print(error!.localizedDescription)
                    }else{
                        UserDefaults.standard.set(true, forKey: "IsThemeChange")
                        UserDefaults.standard.synchronize()
    //                            self.getProfileData()
                    }
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        
        
    }
    
    //MARK:- Collectionview Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == clvPresetTheme){
            return arrTheme.count
        }else if(collectionView == clvOwnTheme){
            return 2
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == clvPresetTheme){
            let cell = clvPresetTheme.dequeueReusableCell(withReuseIdentifier: "PresetThemeCell", for: indexPath) as! PresetThemeCell
            
            let dict = arrTheme[indexPath.row]
            let IsFreeTheme = dict["isFree"] as? Bool ?? false
            let IsVideoTheme = dict["isVideo"] as? Bool ?? false
            
            if(!IsSubscription){
                if(IsFreeTheme == true){
                    cell.lockView.isHidden = true
                }else{
                    cell.lockView.isHidden = false
                }
            }else{
                cell.lockView.isHidden = true
            }
            
            let themeUrl = URL(string: dict["themeUrl"] as! String)!
            if(IsVideoTheme == true){
                let image = getThumbnailImage(forUrl: themeUrl)
//                let image = UIImage.init(named: "album_placeholder")
                if(image != nil){
                    cell.imgTheme.image = image
                }else{
                    cell.imgTheme.image = UIImage.init(named: "album_placeholder")
                }
            }else{
                cell.imgTheme.sd_setImage(with: themeUrl, placeholderImage: UIImage.init(named: "album_placeholder"), options: .highPriority, completed: nil)
            }
            
            let selectedTheme = themeData.value(forKey: "themeUrl")as? String ?? ""
            let selectionNew = dictSelection["themeUrl"] as? String ?? ""

            if(selectedImage == nil){
                if(dictSelection.isEmpty){
                    if(themeUrl.absoluteString == selectedTheme){
                        cell.isThemeSelected.isHidden = false
                    }else{
                        cell.isThemeSelected.isHidden = true
                    }
                }else{
                    if(selectionNew != "" && selectionNew == themeUrl.absoluteString){
                        cell.isThemeSelected.isHidden = false
                    }else{
                        cell.isThemeSelected.isHidden = true
                    }
                }
            }else{
                cell.isThemeSelected.isHidden = true
            }
            
            
            cell.viewBG.layer.cornerRadius = 10
            return cell
            
        }else if(collectionView == clvOwnTheme){
            let cell = clvOwnTheme.dequeueReusableCell(withReuseIdentifier: "OwnThemeCell", for: indexPath) as! OwnThemeCell
            
            
            if(IsSubscription){
                cell.lockView.isHidden = true
            }else{
                cell.lockView.isHidden = false
            }
            
            if(selectedImage != nil){
                if(isPhoto != nil){
                    if(isPhoto == true){
                        if(isLibrary != nil){
                            if (isLibrary == true && indexPath.row == 1) {
                                cell.selection.image = selectedImage!
                                cell.isThemeSelected.isHidden = false
                            }else if (isLibrary == false && indexPath.row == 0) {
                                cell.selection.image = selectedImage!
                                cell.isThemeSelected.isHidden = false
                            }else{
                                cell.selection.image = UIImage()
                                cell.isThemeSelected.isHidden = true
                            }
                        }
                    }else{
                        if(isLibrary != nil){
                            if (isLibrary == true && indexPath.row == 1) {
                                cell.selection.image = selectedImage!
                                cell.isThemeSelected.isHidden = false
                            }else if (isLibrary == false && indexPath.row == 0) {
                                cell.selection.image = selectedImage!
                                cell.isThemeSelected.isHidden = false
                            }else{
                                cell.selection.image = UIImage()
                                cell.isThemeSelected.isHidden = true
                            }
                        }
                    }
                }
            }

            if(indexPath.row == 0){
                //Camera
                cell.imgType.image = UIImage(named: "camera")
                cell.lblType.text = "Take photo or video"
            }else if(indexPath.row == 1){
                //Gallery
                cell.imgType.image = UIImage(named: "gallery")
                cell.lblType.text = "Upload from library"
            }
            cell.viewBG.layer.cornerRadius = 10
            return cell
        }
        return UICollectionViewCell()
    }
    
    var dictSelection = [String:Any]()

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(SVProgressHUD.isVisible()){
            return
        }
        if(collectionView == clvPresetTheme){
            
            let dict = arrTheme[indexPath.row]
            let IsFreeTheme = dict["isFree"] as? Bool ?? false
            let IsVideoTheme = dict["isVideo"] as? Bool ?? false
            let themeUrl = dict["themeUrl"] as! String

            if(!IsSubscription){
                if(IsFreeTheme == true){
                    dictSelection = arrTheme[indexPath.row]

                }else{
                    showSubscription()
                }
            }else{
                dictSelection = arrTheme[indexPath.row]
            }
            clvPresetTheme.reloadData()
        }else if(collectionView == clvOwnTheme){
            
            if(IsSubscription){
                
                isPhoto = nil
                selectedImage = nil
                clvOwnTheme.reloadData()
                
                if(indexPath.row == 0){
                    imagePickerController.sourceType = .camera
                    imagePickerController.delegate = self
                    imagePickerController.mediaTypes = ["public.image", "public.movie"]
                    isLibrary = false
                    present(imagePickerController, animated: true, completion: nil)

                }else if(indexPath.row == 1){
                    imagePickerController.sourceType = .photoLibrary
                    imagePickerController.delegate = self
                    imagePickerController.mediaTypes = ["public.image", "public.movie"]
                    isLibrary = true
                    present(imagePickerController, animated: true, completion: nil)

                }
            }else{
                showSubscription()
            }
            
        }
        
    }
    
    
    //MARK:- Other methods
    var selectedImage : UIImage? = nil
    var selectedVideoUrl : String? = nil
    var isPhoto : Bool? = nil
    var isLibrary : Bool? = nil
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType  == "public.image" {
                isPhoto = true
                selectedImage = (info[UIImagePickerController.InfoKey.originalImage] as! UIImage)
//                uploadImage(selectedImage: selectedImage!)
            }else if mediaType == "public.movie" {
                isPhoto = false
                let videoURL = info[UIImagePickerController.InfoKey.mediaURL]as? NSURL
                do {
                    let asset = AVURLAsset(url: videoURL as! URL , options: nil)
                    let imgGenerator = AVAssetImageGenerator(asset: asset)
                    imgGenerator.appliesPreferredTrackTransform = true
                    let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                    let thumbnail = UIImage(cgImage: cgImage)
                    selectedImage = thumbnail
                } catch let error {
                    print("*** Error generating thumbnail: \(error.localizedDescription)")
                }
                if(videoURL?.absoluteString != ""){
                    selectedVideoUrl = videoURL?.absoluteString
//                    uploadVideo(videoURL: (videoURL?.absoluteString)!)
                }
                
                print(videoURL)
            }else{
                isPhoto = nil
            }
        }
        clvOwnTheme.reloadData()
        clvPresetTheme.reloadData()
        picker.dismiss(animated: true) {
            
        }

    }
    
    func uploadImage(selectedImage: UIImage)  {
        
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        // Create a reference to "mountains.jpg"
        let data = selectedImage.jpegData(compressionQuality: 1.0)
        
        let userId = Auth.auth().currentUser!.uid
        let id = "\(userId).jpg"
        
        // Create a reference to 'images/mountains.jpg'
        let imgRef = storageRef.child("themes").child("OwnTheme").child(id)
        
        imgRef.putData(data!, metadata: nil) { (dt, error) in
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
                
                self.themeData.setValue(url.absoluteString, forKey: "themeUrl")
                                        
                let theme = [
                    "CurrentTheme" : self.themeData
                ]
                
                var db: Firestore!
                db = Firestore.firestore()
                
                SVProgressHUD.show()
                db.collection("userNew").document(self.myUserId).updateData(theme) { (error) in
                    SVProgressHUD.dismiss()
                    UserDefaults.standard.set(true, forKey: "IsThemeChange")
                    UserDefaults.standard.synchronize()
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
        }
    }
    
    func uploadVideo() {
        let videoURL = selectedVideoUrl
        if(videoURL == ""){
            return
        }

        let storage = Storage.storage()
        let userId = Auth.auth().currentUser!.uid
        let storageReference = storage.reference().child("themes").child("OwnTheme").child("\(userId).mov")


        storageReference.putFile(from: URL(string: videoURL!)!, metadata: nil, completion: { (metadata, error) in
            
            SVProgressHUD.dismiss()
            if error == nil {
                print("Successful video upload")
                
                SVProgressHUD.show()
                storageReference.downloadURL { [self] (url, err) in
                    
                    SVProgressHUD.dismiss()
                    if err != nil{
                        self.view.makeToast(err!.localizedDescription)
                        return
                    }
                    
                    guard let url = url else {
                        self.view.makeToast("Something went to wrong")
                        return
                    }
                    print("url => ", url)
                    
                                            
                    self.themeData.setValue(url.absoluteString, forKey: "themeUrl")

                    let theme = [
                        "CurrentTheme" : self.themeData
                    ]
                    var db: Firestore!
                    db = Firestore.firestore()
                    
                    SVProgressHUD.show()
                    db.collection("userNew").document(self.myUserId).updateData(theme) { (error) in
                        SVProgressHUD.dismiss()
                        UserDefaults.standard.set(true, forKey: "IsThemeChange")
                        UserDefaults.standard.synchronize()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
            } else {
                print(error?.localizedDescription)
            }
        })


    }
    
    func showSubscription() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vcSubscri = storyboard.instantiateViewController(withIdentifier: "SubscriptionViewController") as! SubscriptionViewController
        vcSubscri.modalPresentationStyle = .fullScreen
        vcSubscri.modalTransitionStyle = .crossDissolve
        
        vcSubscri.fromEnhancement = true

        self.present(vcSubscri, animated: true, completion: nil)
    }

}
