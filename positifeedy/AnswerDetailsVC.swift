//
//  AnswerDetailsVC.swift
//  positifeedy
//
//  Created by Hiren Dhamecha on 11/12/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
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


class AnswerDetailsVC: UIViewController
{
    var timer: Timer?
    var currentMin : Float = 0.0
    var player : AVPlayer!
    var isPlay: Int! = 0
    var audio_url : String! = ""
    var anser_feed : AnswerFeed!
    var dictDetails : NSMutableDictionary!
    var totalSecond : Float = 0.0
    @IBOutlet weak var imgItem: UIImageView!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var imgProf: UIImageView!
    @IBOutlet weak var lblquestion: UILabel!
    @IBOutlet weak var txtdesc: UITextView!
    
    @IBOutlet weak var progressbar: UIProgressView!
    @IBOutlet weak var btnpla: UIButton!
    @IBOutlet weak var recordinnerview: UIView!
    @IBOutlet weak var recordview: UIView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.design()
        self.getProfileData()
        self.setDetails()
    }
    
    
    
    func design() -> Void
    {
        self.imgProf.layer.cornerRadius = self.imgProf.frame.size.height / 2
        self.imgProf.layer.cornerRadius = self.imgProf.frame.size.width / 2
        self.imgProf.clipsToBounds = true
        
        self.scrollview.contentSize = CGSize.init(width: self.view.frame.size.width, height: self.txtdesc.frame.size.height)
        
        self.recordinnerview.layer.cornerRadius = 2
        self.recordinnerview.clipsToBounds = true
        
        
    }

    func setDetails() -> Void {
        
        self.lblDate.text = String.init(format: "%@", self.changeFormateDate(strDate: anser_feed.current_date!))
        self.lblquestion.text = String.init(format: "%@",anser_feed.question!)
        self.txtdesc.text = String.init(format: "%@",anser_feed.answer!)
        
        let strURL = String.init(format: "%@", anser_feed.link!)
        self.imgItem.sd_setImage(with: URL.init(string: strURL), placeholderImage: UIImage(named: "place"))
        
        if anser_feed.type != nil
        {
            if anser_feed.type == "1"
            {
                self.recordview.isHidden = false
                self.txtdesc.isHidden = true
                
                print(anser_feed.audio_url)
                let myString = String.init(format: "%@", self.anser_feed.play_time!)
                let myFloat = (myString as NSString).floatValue
                
                self.audio_url = anser_feed.audio_url
                self.totalSecond = myFloat
                print("My total play time :\(self.totalSecond)")
                
                
            }else
            {
                self.recordview.isHidden = true
                self.txtdesc.isHidden = false
            }
        }
        else
        {
            self.recordview.isHidden = true
            self.txtdesc.isHidden = false
        }
        
    }
    
    
    //MARK:- change formate date!
       func changeFormateDate(strDate : String) -> String {
           
           let inputFormatter = DateFormatter()
           inputFormatter.dateFormat = "yyyy-MM-dd"
           let showDate = inputFormatter.date(from: strDate)
           inputFormatter.dateFormat = "dd MMMM yyyy"
           let resultString = inputFormatter.string(from: showDate!)
        
           return resultString
           
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
                  if d.count > 0
                  {
                  print("data = ",  d)
                  if (d["uid"] as! String)  ==  Auth.auth().currentUser?.uid
                  {
                     
                      
                      if let strURL = (d["pic"] as? String)
                      {
                          let url = URL(string: strURL)
                          DispatchQueue.global(qos: .background).async {
                              do
                              {
                                  let data = try Data(contentsOf: url!)
                                  DispatchQueue.main.async {
                                      self.imgProf.image = UIImage(data: data)
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
      }
    
    @IBAction func onclickforBack(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func onclickforPlay(_ sender: Any)
    {
        
            if self.audio_url != ""
            {
                if isPlay == 0
                {
                    self.isPlay = 1
                    self.btnpla.setImage(UIImage.init(named: "stop"), for: .normal)
                    self.play(url: URL.init(string: self.audio_url)!)
                    self.currentMin = 0.0
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
                }
                else
                {
                    self.isPlay = 0
                    self.btnpla.setImage(UIImage.init(named: "play"), for: .normal)
                    self.player.pause()
                    self.timer?.invalidate()
                    self.timer = nil
                }
            }
    }
    
    @objc func update()
       {
           if self.currentMin >= self.totalSecond
           {
               self.timer?.invalidate()
               self.timer = nil
               print("call record things..")
               self.btnpla.setImage(UIImage.init(named: "play"), for: .normal)
               self.progressbar.setProgress(0, animated: true)
               
           }else
           {
               if self.currentMin > 0.59
               {
                   self.currentMin = 1.0
               }
               else
               {
                   self.currentMin = self.currentMin + 0.01
                   let currentprogress = self.currentMin * 1 / self.totalSecond
                   self.progressbar.setProgress(currentprogress, animated: true)
               }
               //lblMinit.text = String.init(format: "%.2f / %.2f", self.currentMin,self.totalSecond)
               print("time :\(self.currentMin)")
           }
               
       }
    
    
  /*  @objc func update()
       {
           if self.currentMin >= 1
           {
               self.timer?.invalidate()
               self.timer = nil
               print("call record things..")
               self.btnpla.setImage(UIImage.init(named: "play"), for: .normal)
            self.progressbar.setProgress(0.0, animated: true)
               
               
           }else
           {
               if self.currentMin > 0.59
               {
                   self.currentMin = 1.0
               }
               else
               {
                   self.currentMin = self.currentMin + 0.01
                   let currentprogress = self.currentMin * 1 / 0.60
                   self.progressbar.setProgress(currentprogress, animated: true)
               }
           }
               
       }
    */
    func play(url:URL) {
        print("playing \(url)")

        do {
            let playerItem = AVPlayerItem(url: url)

            self.player = try AVPlayer(playerItem:playerItem)
            player!.volume = 3
            player!.play()
        } catch let error as NSError {
            self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
