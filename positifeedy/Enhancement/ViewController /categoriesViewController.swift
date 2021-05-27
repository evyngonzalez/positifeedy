//
//  categoriesViewController.swift
//  positifeedy
//
//  Created by iMac on 24/04/21.
//  Copyright © 2021 Evyn Gonzalez . All rights reserved.
//
//"General":["I am worthy of infinite compassion.","I replace my anger with understanding and compassion.","I refuse to give up because I haven’t tried all possible ways.","I love my family even if they do not understand me completely."]
//MARK:- Urvesh
import UIKit
import Firebase
import AVKit
import SVProgressHUD
import SDWebImage
import UIImageColors

class categoriesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
 
    var myDocId : String?
    var IsSubscription = false
    var userData = NSMutableDictionary()
    var strCheck = [String]()
//
//    var arrayimage = [UIImage()]
//    var arrayDesc = NSArray()
    var CategoryName = [String]()
    
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        
        self.getProfileData()
               
//        arrayDesc = ["Gain self-confidence","Get more done","Control and calm your mind","Create mindulfull relationships","Exeed yourself"]
//        arrayimage = [#imageLiteral(resourceName: "selflove"),#imageLiteral(resourceName: "Motivation"),#imageLiteral(resourceName: "Stress"),#imageLiteral(resourceName: "family"),#imageLiteral(resourceName: "career")]
//        CategoryName = ["Self Love","Motivation","Managing stress","Family","Career"]
        
        
        let sortedKeys = (dict.allKeys as [String]).sorted()

        for item in sortedKeys {
            let key = item as? String ?? ""
            let data = dict.value(forKey: key) as? NSDictionary
            let isFree = data?.value(forKey: "Isfree") as? Bool ?? false
            if(isFree){
                CategoryName.append(key)
            }
        }
        for item in sortedKeys {
            let key = item as? String ?? ""
            let data = dict.value(forKey: key) as? NSDictionary
            let isFree = data?.value(forKey: "Isfree") as? Bool ?? false
            if(!isFree){
                CategoryName.append(key)
            }
        }
        
        print(CategoryName)
     }
    
    
  //MARK:- getProfileData
   func getProfileData() {
            SVProgressHUD.show()

            var db: Firestore!
            db = Firestore.firestore()
            db.collection("users").getDocuments { [self] (snap, error) in
                
                SVProgressHUD.dismiss()

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
                            self.userData = (d as NSDictionary).mutableCopy() as! NSMutableDictionary
                            self.strCheck = self.userData.value(forKey: "checkCategories") as? [String] ?? [String]()
                            self.IsSubscription = (self.userData.value(forKey: "Subscription") as! String)=="0" ? false:true
                            self.tableview.reloadData()
                            break
                        }
                    }
                }
            }
        }
   //MARK:- Tableview
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CategoryName.count
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PresentCategriesCell", for: indexPath) as! PresentCategriesCell
        
        let key = CategoryName[indexPath.row] as! String
        let data = dict.value(forKey:key) as? NSDictionary

        let title = data?.value(forKey: "Title") as? String ?? ""
        let description = data?.value(forKey: "Description") as? String ?? ""
        let image = data?.value(forKey: "Image") as? String ?? ""
        let isFree = data?.value(forKey: "Isfree") as? Bool ?? false

        cell.lblTitle.text = title
        
        if let url = URL(string: image){
            cell.imgThamel.sd_setImage(with: url, placeholderImage: UIImage(named: "cover-placeholder"), options: .highPriority)
        }else{
            cell.imgThamel.image = UIImage(named: "cover-placeholder")
        }
        
        cell.lblDesc.text = description
        
        if isFree || IsSubscription
        {
            cell.lockCheck.isHidden = true
            cell.lockView.isHidden = true
        }   
        else{
              cell.lockCheck.isHidden = false
             cell.lockView.isHidden = false

        }
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            if self.strCheck.contains(key.uppercased())
        {
            cell.viewBG.dropShadow(color: .green, opacity: 0.4, offSet: CGSize(width: 1, height: 1), radius: 3, scale: true)
            cell.viewBG.backgroundColor = UIColor(red: 247/255.0, green: 254/255.0, blue: 249/255.0, alpha: 1)
          
        }
        else
        {
            cell.viewBG.dropShadow(color: .lightGray, opacity: 0.4, offSet: CGSize(width: 1, height: 1), radius: 3, scale: true)
            cell.viewBG.backgroundColor = UIColor(red: 246/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
             
//            cell.viewBG.dropShadow(color: .white, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
            //cell.BAckgroundimage.isHidden = true
        }
        })
        
        
        return cell
      }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 120
       }
       
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let key = CategoryName[indexPath.row] as! String
        let data = dict.value(forKey:key) as? NSDictionary
        let isFree = data?.value(forKey: "Isfree") as? Bool ?? false

        if isFree || IsSubscription
        {
            let cell = tableView.cellForRow(at: indexPath) as! PresentCategriesCell
//            let cate = CategoryName[indexPath.row]
//            let arr = dict.value(forKey: CategoryName[indexPath.row]) as? NSArray
            
            let key = CategoryName[indexPath.row] as! String
//            let data = dict.value(forKey:key) as? NSDictionary

            if strCheck.contains(key.uppercased())
            {
                strCheck.removeAll { (value) -> Bool in
                    if(value == key.uppercased()){
                        return true
                    }else{
                        return false
                    }
                }
            }else{
                strCheck.append(key.uppercased())
            }
            tableView.reloadData()
        }
        else{
            showSubscription()
        }
        
        
    }
      @IBAction func saveChanges(_ sender : UIButton)
      {
            SVProgressHUD.show()
            var db: Firestore!
            db = Firestore.firestore()
            
            let d1 = ["checkCategories" : strCheck]
            var db1: Firestore!
            db1 = Firestore.firestore()
            db1.collection("users").document(self.myDocId ?? "").updateData(d1) { (error) in
                if error != nil
                {
                  print(error!.localizedDescription)
                }
                UserDefaults.standard.set(true, forKey: "IsCategoryChange")
                SVProgressHUD.dismiss()

                self.navigationController?.popViewController(animated: true)
            }
        
      }
      
    
    @IBAction func categoris(_ sender : UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Show Subscription
    func showSubscription() {
        let storyboard = UIStoryboard(name: "Enhancement", bundle: nil)
        let vcSubscri = storyboard.instantiateViewController(withIdentifier: "SubsciptionVc") as! SubsciptionVc
        vcSubscri.modalPresentationStyle = .fullScreen
        vcSubscri.modalTransitionStyle = .crossDissolve
        
        vcSubscri.fromEnhancement = true

        self.present(vcSubscri, animated: true, completion: nil)
    }
}

//MARK:- For Shadow
extension UIView {

  // OUTPUT 1
  func dropShadow(scale: Bool = true) {
    layer.masksToBounds = false
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.5
    layer.shadowOffset = CGSize(width: -1, height: 1)
    layer.shadowRadius = 1

    layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = scale ? UIScreen.main.scale : 1
  }

  // OUTPUT 2
  func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
    layer.masksToBounds = false
    layer.shadowColor = color.cgColor
    layer.shadowOpacity = opacity
    layer.shadowOffset = offSet
    layer.shadowRadius = radius
    layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = scale ? UIScreen.main.scale : 1
  }
}
