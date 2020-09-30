//
//  BookMarkVc.swift
//  positifeedy
//
//  Created by iMac on 24/09/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage
import Toast_Swift

class BookMarkVc: UIViewController {

    @IBOutlet weak var tableView : UITableView!
    
    @IBOutlet weak var lblFName : UILabel!
    @IBOutlet weak var lblLName : UILabel!
    @IBOutlet weak var lblEmail : UILabel!
    
    var arrFeeds : [Feed] = []
    var lblError : UILabel?
    
    var arrBook  : [Feed]?

    var myDocId : String?
    
    var isProfileImgLoad = true
    
   @IBOutlet weak  var activity : UIActivityIndicatorView!
    
   
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        activity.isHidden = true
        imageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandel))
        imageView.addGestureRecognizer(tapGesture)
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(UINib(nibName: "FeedCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
    
        
        setNavBackground()
        setNavTitle(title : "postifieedy")
        cofigErroLable()
       
        
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        
    }
    
    
    func uploadImage()  {
        
        let storage = Storage.storage()

        // Create a storage reference from our storage service
        let storageRef = storage.reference()

        // Create a reference to "mountains.jpg"
        let data = imageView.image?.jpegData(compressionQuality: 1.0)

        let id = Auth.auth().currentUser!.uid + ".jpg"
    
        // Create a reference to 'images/mountains.jpg'
        let imgRef = storageRef.child("images").child(id)

        imgRef.putData(data!, metadata: nil) { (dt, error) in
            
            if error != nil
            {
                self.view.makeToast(error!.localizedDescription)
                return
            }
            imgRef.downloadURL { (url, err) in
                
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
                
                let d = ["pic" : url.absoluteString ]
                 self.activity.startAnimating()
                self.activity.isHidden = false
                db.collection("users").document(self.myDocId!).updateData(d as [AnyHashable : Any]) { (er) in
                    self.activity.stopAnimating()
                    self.activity.isHidden = true
                    if er != nil
                    {
                        self.view.makeToast(er?.localizedDescription)
                        
                        return
                    }
                    
                }
                
                
            }
        }

        
    }
    
    
    
    
    
    
@objc    func  tapHandel( _ gesture : UITapGestureRecognizer)  {
        
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
               present(vc, animated: true)
           }
       }
    
   @IBAction func barBtnLogoutClick( _ sender : UIBarButtonItem)  {
        
    let alertVC = UIAlertController(title: "Postifeedy", message: "Are you sure?", preferredStyle: UIAlertController.Style.alert)
    
    alertVC.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
    alertVC.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
        
        do
        {
            try   Auth.auth().signOut()
        
            let appDel =  UIApplication.shared.delegate as! AppDelegate
            appDel.arrBookMarkLink = []
            
             UserDefaults.standard.set(false, forKey: "isLogin")
            
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "logInViewController") as! logInViewController
            
            
            let nav = UINavigationController(rootViewController: loginVC )
            nav.setNavigationBarHidden(true, animated: false)
            if #available(iOS 13, *)
            {
                let sceneDeleage = SceneDelegate.shared
                sceneDeleage!.window?.rootViewController = nav
                sceneDeleage?.window?.makeKeyAndVisible()
                
            }
            else
            {
                let appDel = UIApplication.shared.delegate as! AppDelegate
                appDel.window?.rootViewController = nav
                appDel.window?.makeKeyAndVisible()
            }
            
            
        }
        catch
        {
            self.view.makeToast(error.localizedDescription)
        }
        
        
    }))
    
    
     present(alertVC, animated: true, completion: nil)
    
    }
    
    
    func getProfileData()
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
                print("data = ",  d)
                if (d["uid"] as! String)  ==  Auth.auth().currentUser?.uid
                {
                    self.myDocId = doc.documentID
                    self.lblFName.text = (d["firstname"] as! String)
                    self.lblLName.text = (d["lastname"] as! String)
                    self.lblEmail.text = Auth.auth().currentUser?.email
                    
                     if let strURL = (d["pic"] as? String)
                     {
                        let url = URL(string: strURL)
                        self.activity.startAnimating()
                        self.activity.isHidden = false
                        DispatchQueue.global(qos: .background).async {
                            do
                            {
                                let data = try Data(contentsOf: url!)
                                DispatchQueue.main.async {
                                   self.imageView.image = UIImage(data: data)
                                     self.activity.stopAnimating()
                                    self.activity.isHidden = true
                                }
                                
                            }
                            catch{
                                self.view.makeToast("Somthing went to wrong")
                            }
                            
                        }
                     }
                }
            }
        }

        
    }
    
    
    func cofigErroLable()  {
        
        lblError = UILabel(frame: .zero)
        lblError?.text = "Not bookmark available"
        tableView.backgroundView = UIView()
        tableView.backgroundView?.addSubview(lblError!)
        
        
        lblError?.textColor = .gray
        lblError?.font = UIFont(name: Global.Font.regular, size: 16)
        lblError?.translatesAutoresizingMaskIntoConstraints = false
        lblError?.isHidden = true
        
        let centerX =  NSLayoutConstraint(item: lblError as Any, attribute: .centerX, relatedBy: .equal, toItem: tableView.backgroundView, attribute: .centerX, multiplier: 1, constant: 0)
        
        
        let centerY =  NSLayoutConstraint(item: lblError as Any, attribute: .centerY, relatedBy: .equal, toItem: tableView.backgroundView, attribute: .centerY, multiplier: 1, constant: 0)
        
        
        tableView.backgroundView?.addConstraints([centerX, centerY])
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if isProfileImgLoad == true
        {
            getProfileData()
            isProfileImgLoad = false
        }
        getFeeds()
        
    }
    
    func getFeeds() {
        
       if arrBook != nil
        {
            let appDel =  UIApplication.shared.delegate as! AppDelegate
            
            var tempBookMark = [Feed]()
            
            for link in appDel.arrBookMarkLink
            {
                tempBookMark.append(contentsOf:  (arrBook?.filter { $0.link == link})! )
            }
           
            arrFeeds =  tempBookMark
            self.tableView.reloadData()
            
        }
        
        
    }
    
   @objc func btnBookMarkRemoveClick(sender : UIButton)  {
    
        let appDel = UIApplication.shared.delegate as! AppDelegate

     let feed = arrFeeds[sender.tag].link
      
    if let index =  arrFeeds.firstIndex(of: arrFeeds[sender.tag])
    {
        arrFeeds.remove(at: index)
    }
    
    if let index = appDel.arrBookMarkLink.firstIndex(of: feed!)
    {
        appDel.arrBookMarkLink.remove(at:index)
        let d = ["links" : appDel.arrBookMarkLink]
        
        var db: Firestore!
        db = Firestore.firestore()
        
        db.collection("users").document(myDocId!).updateData(d) { (error) in
            if error != nil
            {
                print(error!.localizedDescription)
            }
        }
        tableView.reloadData()
    }
    
    
    
       

    }
    
    

}


//MARK:- UITableViewDataSource
extension BookMarkVc : UITableViewDataSource
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        lblError?.isHidden =  arrFeeds.count == 0  ? false : true
        
            return arrFeeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FeedCell
    
        let feed = arrFeeds[indexPath.row]
        
        
        let date = feed.time?.toDate()
        
        cell.lblTitle.text = feed.title
        cell.lblDesc.text = feed.desc
        cell.lblTime.text  = date!.getElapsedInterval((feed.time?.getTimeZone())!)
        
        
         cell.btnBookMark.setImage(UIImage(named: "cancel"), for: .normal)
        
    
        cell.btnBookMark.tag = indexPath.row
        cell.btnBookMark.addTarget(self, action: #selector(btnBookMarkRemoveClick), for: .touchUpInside)
        cell.imgView.cornerRadius(10)
        
         if   let link = URL(string: feed.link!)
         {
            if let img = Images(rawValue: (link.domain)!)?.image
            {
                cell.imgView.image = UIImage(named: img )
            }
        }
            return cell
    }
    
    
}


//MARK: -UITableViewDelegate
extension BookMarkVc : UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let webVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
        webVC.url = arrFeeds[indexPath.row].link
        navigationController?.pushViewController(webVC, animated: true)
        
    }
    
}


extension BookMarkVc : UIImagePickerControllerDelegate , UINavigationControllerDelegate
{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isProfileImgLoad = false
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
         imageView.image = (info[UIImagePickerController.InfoKey.originalImage] as! UIImage)
        isProfileImgLoad = false
        picker.dismiss(animated: true, completion: nil)
        uploadImage()
        
    }
}

