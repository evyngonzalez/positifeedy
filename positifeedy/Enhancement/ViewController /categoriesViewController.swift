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
let dict : NSDictionary = ["SELF LOVE":["Today, I choose me.",
"I am worthy of infinite compassion.",
"I feel profound empathy and love for others and their own unique paths.",
" I choose to stop apologizing for being me.",
"I am at peace with all that has happened in my life.",
"My life is filled with joy and abundance.",
"Happiness flows from me",
"I will surround myself with positive people who will help bring the best out in me.",
"I am willing to keep going, when things get tough, to achieve the success I deserve",
"My body is beautiful and expresses my spirit.",
"I am grounded, peaceful, and centered.",
"I respect my limitations and thank myself for the things I am able to accomplish.",
"My life is full of happiness and love",
"I release my negative thoughts, embracing positivity and optimism.",
"I feel pride in myself.",
"I am not the sum of my mistakes.",
"I have everything I need.",
"I feel beautiful, I am beautiful",
"I am empowered to create change in my life",
"I will focus on the bright side.",
"I follow my own expectations, not the expectations of others.",
"I am in control of my own actions.",
"I overflow with creativity and good ideas.",
"I do not judge myself or others.",
"I did not get up today to “just” be average. I will excel!",
"I am not my negative thoughts or emotions.",
"I am becoming the person I want to be.",
"I have the tools I need to achieve my dreams.",
"When I practice self-love, I become more lovable.",
"The universe conspires to help me succeed.",
"I control my fears, they do not control me.",
"I love the person that I am.",
"I am whole alone.",
"Today, I choose myself.",
"I have faith in my abilities.",
"My life is full of love.",
"I will stand my ground and defend myself.",
"I respect myself.",
"I have worth and inner beauty.",
"I will care for myself as much as I care for others.",
"I deserve to be happy and successful",
"I am competent, smart and able",
"My opinions are valid and well-reasoned",
"I am growing and changing for the better",
"I believe in myself, my skills, and abilities",
"My life is a gift and I will make the most out of it",
"I will let go of negativity about myself",
"I see the best in other people",
"My body is sacred and I will take care of it",
"I recognise my good qualities, and there are many",
"I am worthy of my successes",
"My flaws are what make me unique and I will work towards loving them",
"I am confident with my plan for my life",
"I accept that I am not perfect and have the courage to change what I can",
"My decisions are sound and reasoned and I will stand by them",
"I will continue to pursue the knowledge I need to succeed",
"I love what I do and do what I am good at",
"All of my actions lead to success",
"I have a beautiful smile",
"I love myself",
"I deserve to be happy and successful.",
"I have to power to change myself.",
"I can forgive and understand others and their motives.",
"I can make my own choices and decisions.",
"I am free to choose to live as I wish and to give my priorities to my desires.",
"I can choose happiness whenever I wish no matter what my circumstances.",
"I am flexible and open to change in every aspect of my life."],
    "STRESS":["I replace my anger with understanding and compassion.",
"I release the past and live fully in the present moment.",
"All my problems have a solution.",
"With every breath out, I release stress in my body.",
"I breathe deeply, exercise regularly, and feed only good nutritious food to my body.",
"I am surrounded by people who encourage and support healthy choices.",
"My world is a peaceful, loving, and joy-filled place to live.",
"I sow the seeds of peace wherever I go."],
 "MOTIVATION":["I refuse to give up because I haven’t tried all possible ways.",
"I adopt the mindset to praise myself.",
"I cannot give up and will never give up.",
"Every day in every way, I am becoming more and more successful.",
"I see fear as the fuel for my success and take bold action despite fear.",
"I always attract only the best of circumstances and the best positive people in my life.",
"Self-confidence is what I thrive on. Nothing is impossible, and life is great.",
"I always see only the good in others. I attract only positive, confident people.",
"I fill my mind with positive and nourishing thoughts.",
"There are no limits to what I can achieve in my life.",
"Today, I abandon my old habits and take up new, more positive ones.",
"I choose love, joy, and freedom, open my heart, and allow wonderful things to flow into my life.",
"I am full of money-making ideas.",
"I awaken in the morning, feeling happy and enthusiastic about life.",
"I rest in happiness when I go to sleep, knowing all is well in my world.",
"Time is the most valuable resource; therefore, I spend it wisely.",
"I have the power to live my dreams.",
"I inspire others to be their best self.",
"I stand up for what I believe in."],
 "FAMILY":["I love my family even if they do not understand me completely.",
"I choose to see my family as a gift.",
"I feel the love of those who are not physically around me.",
"I trust in my own ability to provide well for my family.",
"I have so many good people in my life and so many more yet to meet.",
"My partner and I share a deep and powerful love for each other.",
"My partner and I communicate openly and resolve conflict peacefully and respectfully.",
"I have a wonderful partner, and we are both happy and at peace.",
"I am able to be fully myself and completely authentic in my love relationship.",
"My partner and I have fun together and find new ways to enjoy our time together"],
 "CAREER":["I play a significant role in my own career success.",
"I engage in work that impacts this world positively.",
"My business is growing, expanding, and thriving.",
"I may not understand the good in this situation, but it is there.",
"Today will be a gorgeous day to remember.",
"I deserve to be employed and paid well for my time, efforts, and ideas. Each day, I am closer, to finding the perfect job for me.",
"Mistakes and setbacks are stepping stones to my success because I learn from them.",
"I welcome financial abundance. I am capable of wisely handling financial success.",
"I am self-reliant, creative, and persistent in whatever I do.",
"I deserve to be rich."]]
class categoriesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
 
    var myDocId : String?
    var IsSubscription = false
    var userData = NSMutableDictionary()
    var arrayimage = [UIImage()]
    var arrayDesc = NSArray()
    var strCheck = [String]()
    var CategoryName = [String]()
    
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                   self.getProfileData()
               }
        arrayDesc = ["Gain self-confidence","Get more done","Control and calm your mind","Create mindulfull relationships","Exeed yourself"]
        arrayimage = [#imageLiteral(resourceName: "selflove"),#imageLiteral(resourceName: "Motivation"),#imageLiteral(resourceName: "Stress"),#imageLiteral(resourceName: "family"),#imageLiteral(resourceName: "career")]
        CategoryName = ["Self Love","Motivation","Managing stress","Family","Career"]
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
        
        let cate = CategoryName[indexPath.row]
         let arr = dict.value(forKey: CategoryName[indexPath.row]) as? NSArray
        cell.lblTitle.text = cate
        
        cell.imgThamel.image = arrayimage[indexPath.row]
        cell.lblDesc.text = arrayDesc[indexPath.row] as? String
        if indexPath.row == 0 || IsSubscription
        {
            cell.lockCheck.isHidden = true
           cell.lockView.isHidden = true
        }   
        else{
              cell.lockCheck.isHidden = false
             cell.lockView.isHidden = false

        }
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            if self.strCheck.contains(cate.uppercased())
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
        
        
        if indexPath.row == 0 || IsSubscription
        {
            let cell = tableView.cellForRow(at: indexPath) as! PresentCategriesCell
            let cate = CategoryName[indexPath.row]
            let arr = dict.value(forKey: CategoryName[indexPath.row]) as? NSArray

            if strCheck.contains(cate.uppercased())
            {
                strCheck.removeAll { (value) -> Bool in
                    if(value == cate.uppercased()){
                        return true
                    }else{
                        return false
                    }
                }
            }else{
                strCheck.append(cate.uppercased())
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
            db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
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
