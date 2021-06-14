//
//  AddManifestViewController.swift
//  positifeedy
//
//  Created by iMac on 17/05/21.
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
import SVProgressHUD
import DLLocalNotifications

class AddManifestViewController: UIViewController,UITextViewDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate, UNUserNotificationCenterDelegate
{
    
    var totalSecond : Float = 0.0
    var firebaseaudioURL : String! = ""
    var strAudiFileName : String!
    var isPlayFlag : Int = 0
    var isPlayfstTime :Int! = 0
    var timer: Timer?
    var timerPlaying: Timer?
    var currentMin : Float = 0.0
    var strtype : String! = "0"
    var arrMyManifestEntry : NSMutableArray!
    var arrQuestionList = [QuestionListItem]()
    var myDocId : String! = ""
    var strUID : String! = ""
    var imgURL : String! = ""
    var currentPoint : Int! = 0
    var arrListOfJourny : NSMutableArray!
   
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var isPlaying = false
    var IsSubscripted = false
    var IsEditingOn = true
    
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var lblMinChar: UILabel!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var btnsave: UIButton!
    @IBOutlet weak var lblDisableInfo: UILabel!
    @IBOutlet weak var btnrestart: UIButton!
    @IBOutlet weak var btnSubscribe: UIButton!
    @IBOutlet weak var txtcomment: UITextView!
//    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var imgItem: UIImageView!
    @IBOutlet weak var lbldate: UILabel!
    
    @IBOutlet weak var btnStartRecFirst: UIButton!
    @IBOutlet weak var btnpla: UIButton!
    @IBOutlet weak var progressbar: UIProgressView!
    @IBOutlet weak var lblMinit: UILabel!
    @IBOutlet weak var recordingview: UIView!
    
    
    @IBOutlet weak var viewTime: UIView!
    @IBOutlet weak var viewDay: UIView!
    
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var lblSelectedTime: UILabel!
    @IBOutlet weak var lblSelectedDay: UILabel!
    
    var selectedDate = Date()
    var selectedDay = "every day"
    
    @IBOutlet weak var imgProfile: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
//        if #available(iOS 13.4, *) {
//            timePicker.preferredDatePickerStyle = UIDatePickerStyle.wheels
//        }
        
        self.check_record_permission()
        
        self.arrListOfJourny = NSMutableArray.init()
        self.arrMyManifestEntry = NSMutableArray.init()
        
        self.design()
        self.getProfileData()
        self.setQuestionDetails()
        updateTextview()
        
        timePicker.date = selectedDate
        updateTimeLabel()
        updateUIForSubscription()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func updateTimeLabel(){
        let df = DateFormatter()
        df.dateFormat = "hh:mma"
        let dateString = df.string(from: selectedDate)
        timePicker.date = selectedDate
        
        lblSelectedTime.text = dateString
        lblSelectedDay.text = selectedDay
    }
    
    func updateUIForSubscription(){
        if(!IsSubscripted){
            btnrestart.setImage(UIImage(named: "lock-new-black"), for: .normal)
            recordingview.alpha = 0.6
            btnSubscribe.isHidden = false
        }else{
            btnrestart.setImage(UIImage(named: "n_retry"), for: .normal)
            recordingview.alpha = 1
            btnSubscribe.isHidden = true
        }
        
        if(IsEditingOn){
            txtcomment.isEditable = false
        }else{
            txtcomment.isEditable = true
        }

    }
    
    func updateTextview() {
        if(txtcomment.text.isEmpty){
            txtcomment.text = "Write Here..."
            txtcomment.textColor = UIColor.lightGray
        }else{
            txtcomment.text = txtcomment.text
            txtcomment.textColor = UIColor.black
        }
    }
    
    func check_record_permission()
    {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSessionRecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                    if allowed {
                        self.isAudioRecordingGranted = true
                    } else {
                        self.isAudioRecordingGranted = false
                    }
            })
            break
        default:
            break
        }
    }
    
    
    func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func getFileUrl() -> URL
    {
        //let strNM = String.init(format: "%@.m4a", self.randomString(length: 5))
        let strNM = self.strAudiFileName
            print("File Name :\(strNM)")
                    let filename = strNM
            let filePath = getDocumentsDirectory().appendingPathComponent(filename!)
            return filePath
       
    }
    
    func prepare_play()
    {
        do
        {
            audioPlayer = try AVAudioPlayer(contentsOf: getFileUrl())
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        }
        catch{
            print("Error")
        }
    }
    
    
    func setup_recorder()
    {
        if isAudioRecordingGranted
        {
            let session = AVAudioSession.sharedInstance()
            do
            {
                
                try session.setCategory(.playAndRecord,options:  .defaultToSpeaker)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                
                audioRecorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.averagePower(forChannel: 5)
                audioRecorder.prepareToRecord()
            }
            catch let error {
                //display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")
            }
        }
        else
        {
            //display_alert(msg_title: "Error", msg_desc: "Don't have access to use your microphone.", action_title: "OK")
        }
    }
    
    
    func randomString(length: Int) -> String {

        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }
    
    //MARK:- design :
    func design() -> Void {
        
        self.btnsave.layer.cornerRadius = 5
        self.btnsave.clipsToBounds = true
        
        self.txtcomment.layer.cornerRadius = 5
        self.txtcomment.clipsToBounds = true
        self.txtcomment.layer.borderColor = UIColor.black.cgColor
        self.txtcomment.layer.borderWidth = 1
        
        self.audioView.layer.cornerRadius = 2
        self.audioView.clipsToBounds = true
        self.lblMinit.text = "00:00 / 00:00"
        
    }
    
      //MARK:- question List:
        func setQuestionDetails() -> Void {
            
            var db: Firestore!
            
            db = Firestore.firestore()
            
            db.collection("QuestionList").getDocuments { (snap, error) in
                if error != nil
                {
                    print("error ", error!.localizedDescription)
                    return
                }
                
                if let arr = snap?.documents {
                    let arrData = arr.map { (snap) -> [String: Any] in
                        var dict = snap.data()
                        dict["documentID"] = snap.documentID
                        return dict
                    }
                    
                    do {
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: arrData, options: .prettyPrinted)
                        let jsonDecoder = JSONDecoder()
                        let obj = try jsonDecoder.decode([QuestionListItem].self, from: jsonData)
                        self.arrQuestionList = obj
                        
                    }
                    catch {
                        
                    }
                    print("Question List :\(self.arrQuestionList)")
                   if self.arrQuestionList.count > 0
                   {
                        let currentInx = UserDefaults.standard.object(forKey: PREF_DAILY_QUESTION_COUNT) as? Int ?? 0
                        if currentInx != nil
                        {
                            if currentInx == 0
                            {
                                 // question
                                let questionItem = self.arrQuestionList[1]
                                
//                                self.lblQuestion.text = questionItem.question
                                
                                // current date with suffix :
                                let date = Date()
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "MMM dd"
                                let dateString = dateFormatter.string(from: date)
                                
                                let dateFormatter1 = DateFormatter()
                                dateFormatter1.dateFormat = "yyyy"
                                let dateString1 = dateFormatter1.string(from: date)

                                //self.lbldate.text = String.init(format: "%@%@, %@", dateString,self.daySuffix(from: date), dateString1)
                                
                                
                                // image :
                                if let strURL = (questionItem.link)
                                   {
                                    
                                        self.imgURL = strURL
                                       let url = URL(string: strURL)
                                        self.imgItem.sd_setImage(with: url, placeholderImage: UIImage(named: "ReflectionBG"))
                                   }
                            }
                            else
                            {
                                 // question
                                var newIndex = currentInx
                                repeat{
                                    newIndex -= 1
                                    if(newIndex < 0){
                                        newIndex = currentInx + 1
                                    }
                                    if(newIndex > self.arrQuestionList.count){
                                        newIndex = 0
                                    }
                                }while(newIndex == currentInx && newIndex < self.arrQuestionList.count)
                                let questionItem = self.arrQuestionList[newIndex]
//                                self.lblQuestion.text = questionItem.question
                                
                                // current date with suffix :
                                let date = Date()
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "MMM dd"
                                let dateString = dateFormatter.string(from: date)
    
                                let dateFormatter1 = DateFormatter()
                                dateFormatter1.dateFormat = "yyyy"
                                let dateString1 = dateFormatter1.string(from: date)

                                //self.lbldate.text = String.init(format: "%@%@, %@", dateString,self.daySuffix(from: date), dateString1)
                                
                                
                                // image :
                                if let strURL = (questionItem.link)
                                   {
                                    
                                        self.imgURL = strURL
                                       let url = URL(string: strURL)
                                        self.imgItem.sd_setImage(with: url, placeholderImage: UIImage(named: "ReflectionBG"))
                                }
                            }
                            
                        }
                    }
                }
            }
        }
        
        func daySuffix(from date: Date) -> String {
            let calendar = Calendar.current
            let dayOfMonth = calendar.component(.day, from: date)
            switch dayOfMonth {
            case 1, 21, 31: return "st"
            case 2, 22: return "nd"
            case 3, 23: return "rd"
            default: return "th"
            }
        }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if txtcomment.textColor == UIColor.lightGray {
            txtcomment.text = nil
            txtcomment.textColor = UIColor.black
        }
        lblMinChar.isHidden = true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if txtcomment.text.isEmpty {
            txtcomment.text = "Write Here..."
            txtcomment.textColor = UIColor.lightGray
            lblMinChar.isHidden = false
        }else{
            if(txtcomment.text.count > 5){
                lblMinChar.isHidden = true
            }else{
                lblMinChar.isHidden = false
            }
            
        }
    }
    
    
    @IBAction func onclickforBack(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onclickforShowTime(_ sender: Any)
    {
        if(IsEditingOn){
            return
        }
        self.timeView.isHidden = false
        viewTime.isHidden = false
        viewDay.isHidden = true

    }
    
    @IBAction func onclickforShowDay(_ sender: Any)
    {
        if(IsEditingOn){
            return
        }
        self.timeView.isHidden = false
        viewTime.isHidden = true
        viewDay.isHidden = false
        
    }
    
    @IBAction func onclickforEveryDay(_ sender: Any)
    {
        self.timeView.isHidden = true
        viewTime.isHidden = true
        viewDay.isHidden = true
        
        selectedDay = "every day"
        updateTimeLabel()

    }
    
    @IBAction func onclickforEvery3Day(_ sender: Any)
    {
        self.timeView.isHidden = true
        viewTime.isHidden = true
        viewDay.isHidden = true
        
        selectedDay = "every 3 days"
        updateTimeLabel()

    }
    
    @IBAction func onclickforOnceWeekDay(_ sender: Any)
    {
        self.timeView.isHidden = true
        viewTime.isHidden = true
        viewDay.isHidden = true
        
        selectedDay = "once a week"
        updateTimeLabel()

    }
    @IBAction func onclickforDoneTime(_ sender: Any)
    {
        self.timeView.isHidden = true
        
        viewTime.isHidden = true
        viewDay.isHidden = true

    }
    
    @IBAction func onclickforCancelTime(_ sender: Any)
    {
        self.timeView.isHidden = true
        viewTime.isHidden = true
        viewDay.isHidden = true
    }
    
    @IBAction func timePickerChanged(_ sender: Any) {
        selectedDate = timePicker.date
        updateTimeLabel()
    }
    
    
    @IBAction func onclickforSubscribe(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "Enhancement", bundle: nil)
        let vcSubscri = storyboard.instantiateViewController(withIdentifier: "SubsciptionVc") as! SubsciptionVc
        vcSubscri.modalPresentationStyle = .fullScreen
        vcSubscri.modalTransitionStyle = .crossDissolve
        
        vcSubscri.fromEnhancement = true

        self.present(vcSubscri, animated: true, completion: nil)
    }
    
    @IBAction func onclickforStartFromFirst(_ sender: Any) {
        
        if(IsEditingOn){
            return
        }
        if self.isPlayfstTime == 0
        {
            
            self.isPlayfstTime = 1
            
            self.strtype = "1"
            self.lblMinit.text = "00:00 / 00:00"
            self.currentMin = 0.0
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            self.btnStartRecFirst.setImage(UIImage.init(named: "stop_record"), for: .normal)
           
            self.strAudiFileName = String.init(format: "%@.m4a", self.randomString(length: 4))
            setup_recorder()
            audioRecorder.record()
            self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
            isRecording = true
            self.btnpla.setImage(UIImage.init(named: "n_play"), for: .normal)
            self.progressbar.setProgress(0.0, animated: true)
            
            if self.audioPlayer != nil
            {
                self.timerPlaying?.invalidate()
                self.timerPlaying = nil
                self.audioPlayer.stop()
                self.progressbar.setProgress(0, animated: true)
            }
            
        }
        else
        {
            
            self.totalSecond = self.currentMin
            self.isPlayfstTime = 0
            // finish video
            finishAudioRecording(success: true)
            self.timer?.invalidate()
            self.timer = nil
            self.btnStartRecFirst.setImage(UIImage.init(named: "n_start_record"), for: .normal)
        }
    }
    
    
    @IBAction func onclickforSave(_ sender: Any)
    {
        if(IsEditingOn){
            return
        }
        
//        if self.txtcomment.text == "Write Here..."
//        {
//           self.view.makeToast("Please enter your answer!")
//            return
//        }
//        else
//        {
//           if self.txtcomment.text.count > 5
//           {
//               // save to another !
//               
//               self.savetoUserManifestEntry()
//           }
//           else
//           {
//                self.view.makeToast("Please enter atleast 5 characters!")
//                return
//           }
//        }
        self.savetoUserManifestEntry()

        if self.strtype == "1"
        {
            
            if self.currentMin > 0.0
            {
                self.totalSecond = self.currentMin
                   self.isPlayfstTime = 0
                   // finish video
                   finishAudioRecording(success: true)
                  
        
                if self.timer != nil
                {
                    self.timer?.invalidate()
                   self.timer = nil
                }
            
                if self.timerPlaying != nil
                {
                   self.timerPlaying?.invalidate()
                   self.timerPlaying = nil
                }
        
                if self.meterTimer != nil
                {
                   self.meterTimer.invalidate()
                   self.meterTimer = nil
                }
        
                   self.progressbar.setProgress(0, animated: true)
                   
                   self.btnStartRecFirst.setImage(UIImage.init(named: "n_start_record"), for: .normal)
                   
                   print("saved url :\(getFileUrl())")
                   
                   SVProgressHUD.show()
                   let db = Firestore.firestore()
                   
                   let final = String.init(format: "%@.m4a", self.randomString(length: 7))
                   let storageRef = Storage.storage().reference().child(final)
                   storageRef.putFile(from:getFileUrl(), metadata: nil) { (metadata, error) in
                                    
                            if error != nil {
                            //self.writeDatabaseCustomer()
                                print("error")
                                return
                            }
                            else
                            {
                               storageRef.downloadURL(completion: { (url, error) in
                                print("Audiofile URL: \((url?.absoluteString)!)")
                                self.firebaseaudioURL = "\((url?.absoluteString)!)"
                                SVProgressHUD.dismiss()
                                self.savetoUserManifestEntry()
                   })}}
                
            }
//            else
//            {
//
//                    self.view.makeToast("Please Record Audio!")
//            }
                        
        }
        
    }
    
    @IBAction func onclickforWrite(_ sender: Any)
    {
        
        
        self.txtcomment.isHidden = false
        
        self.strtype = "0"
        
        self.lblMinit.text = "00:00 / 00:00"

        self.timer?.invalidate()
        self.timer = nil
        
        if self.audioRecorder != nil
        {
            audioRecorder.stop()
            audioRecorder = nil
            meterTimer.invalidate()
            print("recorded successfully.")
            print("saved url :\(getFileUrl())")
        }
        
    }
    
    
    @IBAction func onclickforRetry(_ sender: Any)
    {
        
        strAudiFileName = nil
        firebaseaudioURL = ""
        
        self.isPlayFlag = 0
        self.btnpla.setImage(UIImage.init(named: "n_play"), for: .normal)
        
        if(audioPlayer != nil){
            audioPlayer.stop()
        }
        isPlaying = false
        
        self.timerPlaying?.invalidate()
        self.timerPlaying = nil
        self.timer?.invalidate()
        self.timer = nil

        self.lblMinit.text = "00:00 / 00:00"
        self.currentMin = 0.0
        self.totalSecond = 0.0
        
        self.strtype = "0"
        self.isPlayfstTime = 0

        self.progressbar.setProgress(0, animated: true)
        self.btnStartRecFirst.setImage(UIImage.init(named: "n_start_record"), for: .normal)

        
        
        
        // inital video : start video
//         self.isPlayfstTime = 1
//
//         self.strtype = "1"
//         self.lblMinit.text = "00:00 / 00:00"
//         self.currentMin = 0.0
//         self.timer?.invalidate()
//         self.timer = nil
//         self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
//         self.btnStartRecFirst.setImage(UIImage.init(named: "stop_record"), for: .normal)
//
//         self.strAudiFileName = String.init(format: "%@.m4a", self.randomString(length: 4))
//         setup_recorder()
//         audioRecorder.record()
//         self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
//         //record_btn_ref.setTitle("Stop", for: .normal)
//         //play_btn_ref.isEnabled = false
//         isRecording = true
//         self.btnpla.setImage(UIImage.init(named: "n_play"), for: .normal)
//         self.progressbar.setProgress(0.0, animated: true)
//
//        if self.audioPlayer != nil
//         {
//             self.timerPlaying?.invalidate()
//             self.timerPlaying = nil
//             self.audioPlayer.stop()
//             self.progressbar.setProgress(0, animated: true)
//         }
        
    }
    
    @IBAction func onclickforPlay(_ sender: Any) {
        
        if self.isPlayFlag == 0
        {
            if self.isPlayfstTime == 1
            {
                self.view.makeToast("Recording is working now! please wait..")
            }
            else
            {
                
                if self.strAudiFileName != nil
                {
                    if FileManager.default.fileExists(atPath: getFileUrl().path)
                    {
                        
                            self.isPlayFlag = 1
                            self.btnpla.setImage(UIImage.init(named: "n_pause"), for: .normal)
                            
                            //record_btn_ref.isEnabled = false
                            //play_btn_ref.setTitle("pause", for: .normal)
                            prepare_play()
                            audioPlayer.setVolume(3, fadeDuration: 1)
//                                audioPlayer.volume = 1
                            audioPlayer.play()
                            isPlaying = true
                            self.currentMin = 0.0
                            self.timerPlaying = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatePlaying), userInfo: nil, repeats: true)
                    }
                    else
                    {
                        self.view.makeToast("Audio is missing.")
                        
                        //display_alert(msg_title: "Error", msg_desc: "Audio is missing.", action_title: "OK")
                    }
                }
                else if self.firebaseaudioURL != ""{
//                   self.totalSecond
                    self.view.makeToast("Playing Audio!")
                    self.isPlayFlag = 1
                    self.btnpla.setImage(UIImage.init(named: "n_pause"), for: .normal)
                    do
                    {
                        if let url = URL(string: self.firebaseaudioURL!){
                            SVProgressHUD.show()
                            let data = try Data.init(contentsOf: url)
                            audioPlayer = try AVAudioPlayer(data: data)
                            audioPlayer.delegate = self
                            audioPlayer.prepareToPlay()
                        }else{
                            self.view.makeToast("Can't play audio.")
                        }
                    }
                    catch let error{
                        print("Error \(error)")
                    }
                    SVProgressHUD.dismiss()
                    audioPlayer.setVolume(3, fadeDuration: 1)
//                                audioPlayer.volume = 1
                    audioPlayer.play()
                    isPlaying = true
                    self.currentMin = 0.0
                    
//                    var ti = NSInteger(audioPlayer.duration)
//                    self.totalSecond = Float(ti % 60)

                    self.timerPlaying = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatePlaying), userInfo: nil, repeats: true)

                }
                else
                {
                    self.view.makeToast("Audio is missing.")
                }
            }
            
        }
        else
        {
            if audioPlayer != nil
            {
                self.isPlayFlag = 0
                self.btnpla.setImage(UIImage.init(named: "n_play"), for: .normal)
                audioPlayer.stop()
                //record_btn_ref.isEnabled = true
                //play_btn_ref.setTitle("Play", for: .normal)
                isPlaying = false
                
                self.timerPlaying?.invalidate()
                self.timerPlaying = nil
            }
        }
        
    }
    
    @IBAction func onclickforrecord(_ sender: Any) {
        
       
        self.txtcomment.isHidden = true
        
//        self.btnRecord.layer.cornerRadius = 5
//        self.btnRecord.clipsToBounds = true
//        self.btnRecord.backgroundColor = UIColor.init(red: 37/255, green: 250/255, blue: 168/255, alpha: 1)
//        self.btnRecord.setTitleColor(UIColor.white, for: .normal)
//
//
//        self.btnWrite.layer.cornerRadius = 5
//        self.btnWrite.clipsToBounds = true
//        self.btnWrite.backgroundColor = UIColor.clear
//        self.btnWrite.setTitleColor(UIColor.white, for: .normal)
        
//        self.recordingview.isHidden = false
        self.isPlayfstTime = 0

        self.strtype = "1"
        self.lblMinit.text = "00:00 / 00:00"
        self.currentMin = 0.0
//        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)

        
       
    }
    
    @objc func updateAudioMeter(timer: Timer)
    {
        if audioRecorder != nil
        {
            if audioRecorder.isRecording
            {
                //let hr = Int((audioRecorder.currentTime / 60) / 60)
                //let min = Int(audioRecorder.currentTime / 60)
                //let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
                //let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
                audioRecorder.updateMeters()
            }
        }
    }

    func finishAudioRecording(success: Bool)
    {
        if success
        {
            if audioRecorder != nil
            {
                audioRecorder.stop()
                audioRecorder = nil
                meterTimer.invalidate()
                print("recorded successfully.")
                print("saved url :\(getFileUrl())")
            }
        }
        else
        {
           // display_alert(msg_title: "Error", msg_desc: "Recording failed.", action_title: "OK")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool)
    {
        if !flag
        {
            finishAudioRecording(success: false)
        }
        //play_btn_ref.isEnabled = true
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        //record_btn_ref.isEnabled = true
    }

    @objc func updatePlaying()
    {
        if self.currentMin >= self.totalSecond
        {
            
            self.isPlayFlag = 0
            isPlaying = false
            
            self.timerPlaying?.invalidate()
            self.timerPlaying = nil
            print("call record things..")
            self.btnpla.setImage(UIImage.init(named: "n_play"), for: .normal)
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
            
            print("time :\(self.currentMin)")
        }
        lblMinit.text = String.init(format: "%.2f / %.2f", self.currentMin,self.totalSecond)

    }
    
    // @objc selector expected for Timer
    @objc func update()
    {
        if self.currentMin >= 1
        {
            self.totalSecond = 1.0
            self.timer?.invalidate()
            self.timer = nil
            print("call record things..")
            finishAudioRecording(success: true)
            self.isPlayfstTime = 0
            self.btnStartRecFirst.setImage(UIImage.init(named: "n_start_record"), for: .normal)
            
        }else
        {
            if self.currentMin > 0.59
            {
                self.currentMin = 1.0
            }
            else
            {
                self.currentMin = self.currentMin + 0.01
                //let currentprogress = self.currentMin * 1 / 0.60
                //self.progressbar.setProgress(currentprogress, animated: true)
                
            }
            lblMinit.text = String.init(format: "%.2f / 1.00", self.currentMin)
            print("time :\(self.currentMin)")
        }
            
    }
    
    //MARK:- save to user Journary Entry
    func savetoUserManifestEntry() -> Void {
        
        if !NetworkState.isConnected()
        {
            let alert = UIAlertController(title: Utilities.appName(), message: "Internet not connected", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        txtcomment.isEditable = false
        IsEditingOn = true
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: date)!
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let endDateString = dateFormatter1.string(from: endDate)
        
        let startDate = Date()
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let startDateString = dateFormatter2.string(from: startDate)


        if self.arrMyManifestEntry.count > 0
        {

            let searchPredicate = NSPredicate(format: "isActive == YES",true)
            let  arrrDict = self.arrMyManifestEntry.filter { searchPredicate.evaluate(with: $0) };
            let filterArray = NSMutableArray.init(array: arrrDict)
            if(filterArray.count > 0)
            {

                for i in (0..<self.arrMyManifestEntry.count)
                {

                    let dict = self.arrMyManifestEntry.object(at: i) as? NSDictionary
                    if dict?.value(forKey: "isActive") as? Bool ?? false
                    {
                        var comment = self.txtcomment.text
                        if comment == "Write Here..."{
                            comment = ""
                        }
                        
                        let timestamp = Date().currentTimeMillis()
                        let dictMutable = dict?.mutableCopy() as? NSMutableDictionary
//                        dictMutable!.setValue(self.lblQuestion.text, forKey: "question")
                        dictMutable!.setValue(comment, forKey: "answer")
                        dictMutable!.setValue(self.imgURL, forKey: "link")
                        dictMutable!.setValue("\(timestamp)", forKey: "timestamp")
                        dictMutable!.setValue("\(dateString)", forKey: "current_date")
                        dictMutable!.setValue("\(startDateString)", forKey: "startDate")
                        dictMutable!.setValue("\(endDateString)", forKey: "endDate")

                        dictMutable!.setValue("\(selectedDate)", forKey: "manifestTime")
                        dictMutable!.setValue(selectedDay, forKey: "manifestDay")
                        dictMutable!.setValue(true, forKey: "isActive")

                        //https://stackoverflow.com/questions/45061324/repeating-local-notifications-for-specific-days-of-week-swift-3-ios-10


                        if self.strtype == "1"
                        {
                            dictMutable!.setValue("7", forKey: "point")

                            dictMutable!.setValue(String.init(format: "%.2f", self.currentMin), forKey: "play_time")
                            dictMutable!.setValue(self.firebaseaudioURL, forKey: "audio_url")
                            dictMutable!.setValue("1", forKey: "type")
                        }
                        else
                        {
                            dictMutable!.setValue(self.firebaseaudioURL, forKey: "audio_url")
                            dictMutable!.setValue("5", forKey: "point")
                            dictMutable!.setValue("0", forKey: "type")
                        }
                        self.arrMyManifestEntry.replaceObject(at: i, with: dictMutable)
                    }
                }
                print("pass json :\(self.arrMyManifestEntry)")
                let d = ["ManifestEntry" : self.arrMyManifestEntry]

                var db: Firestore!
                db = Firestore.firestore()

                db.collection("users").document(self.myDocId!).updateData(d) { (error) in
                        if error != nil
                        {
                            print(error!.localizedDescription)
                        }

                        UserDefaults.standard.setValue(dateString, forKey: PREF_BOOKED_DATE)
                        self.view.makeToast("Answer Submit Successfully!")
                        self.dismiss(animated: true, completion: nil)
                    }

            }
            else
            {
                var comment = self.txtcomment.text
                if comment == "Write Here..."{
                    comment = ""
                }
                let timestamp = Date().currentTimeMillis()
                let dict = NSMutableDictionary.init()
//                dict.setValue(self.lblQuestion.text, forKey: "question")
                dict.setValue(comment, forKey: "answer")
                dict.setValue(self.imgURL, forKey: "link")
                dict.setValue("\(timestamp)", forKey: "timestamp")
                dict.setValue("\(dateString)", forKey: "current_date")
                dict.setValue("\(startDateString)", forKey: "startDate")
                dict.setValue("\(endDateString)", forKey: "endDate")
                
                dict.setValue("\(selectedDate)", forKey: "manifestTime")
                dict.setValue(selectedDay, forKey: "manifestDay")

                dict.setValue(true, forKey: "isActive")
                
                if self.strtype == "1"
                {
                    dict.setValue("7", forKey: "point")

                    dict.setValue(self.firebaseaudioURL, forKey: "audio_url")
                    dict.setValue("1", forKey: "type")
                    dict.setValue(String.init(format: "%.2f", self.currentMin), forKey: "play_time")
                }
                else
                {
                    dict.setValue("5", forKey: "point")

                    dict.setValue("0", forKey: "type")
                }
                
                self.arrMyManifestEntry.add(dict)
                
                print("pass json :\(self.arrMyManifestEntry)")
                
                let d = ["ManifestEntry" : self.arrMyManifestEntry]

                    var db: Firestore!
                    db = Firestore.firestore()

                db.collection("users").document(self.myDocId!).updateData(d) { (error) in
                        if error != nil
                        {
                            print(error!.localizedDescription)
                        }
                   
                       var str = ""
                    if(self.strtype == "1"){
                        str = String.init(format: "%d", self.currentPoint + 7)
                    }else{
                        str = String.init(format: "%d", self.currentPoint + 5)
                    }
                       let d1 = ["myPoint" : str]
                       var db1: Firestore!
                       db1 = Firestore.firestore()
                       db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
                           if error != nil
                           {
                               print(error!.localizedDescription)
                           }
                       }
                        UserDefaults.standard.setValue(dateString, forKey: PREF_BOOKED_DATE)
                        self.view.makeToast("Answer Submit Successfully!")
                        self.dismiss(animated: true, completion: nil)
                    }
                
                //
                //self.view.makeToast("Answer Submit Successfully!")
                
            }
            
        }
        else
        {
            var comment = self.txtcomment.text
            if comment == "Write Here..."{
                comment = ""
            }
            self.arrMyManifestEntry = NSMutableArray.init()

            let timestamp = Date().currentTimeMillis()
            let dict = NSMutableDictionary.init()
//            dict.setValue(self.lblQuestion.text, forKey: "question")
            dict.setValue(comment, forKey: "answer")
            dict.setValue(self.imgURL, forKey: "link")
            dict.setValue("\(timestamp)", forKey: "timestamp")
            dict.setValue("\(dateString)", forKey: "current_date")
            dict.setValue("\(startDateString)", forKey: "startDate")
            dict.setValue("\(endDateString)", forKey: "endDate")
            
            dict.setValue("\(selectedDate)", forKey: "manifestTime")
            dict.setValue(selectedDay, forKey: "manifestDay")
            dict.setValue(true, forKey: "isActive")
            
            if self.strtype == "1"
            {
                dict.setValue("7", forKey: "point")
                dict.setValue(self.firebaseaudioURL, forKey: "audio_url")
                dict.setValue("1", forKey: "type")
                dict.setValue(String.init(format: "%.2f", self.currentMin), forKey: "play_time")
            }
            else
            {
                dict.setValue("5", forKey: "point")
                dict.setValue("0", forKey: "type")
            }
            
            self.arrMyManifestEntry.add(dict)
            
            print("pass json :\(self.arrMyManifestEntry)")
            
            let d = ["ManifestEntry" : self.arrMyManifestEntry]

                var db: Firestore!
                db = Firestore.firestore()

            db.collection("users").document(self.myDocId!).updateData(d) { (error) in
                if error != nil
                {
                    print(error!.localizedDescription)
                }
                
            
//            let str = String.init(format: "%d", self.currentPoint + 5)
            var str = ""
             if(self.strtype == "1"){
                 str = String.init(format: "%d", self.currentPoint + 7)
             }else{
                 str = String.init(format: "%d", self.currentPoint + 5)
             }
            let d1 = ["myPoint" : str]
            var db1: Firestore!
            db1 = Firestore.firestore()
            db1.collection("users").document(self.myDocId!).updateData(d1) { (error) in
                if error != nil
                {
                    print(error!.localizedDescription)
                }
            }
            UserDefaults.standard.setValue(dateString, forKey: PREF_BOOKED_DATE)
            self.view.makeToast("Answer Submit Successfully!")
            self.dismiss(animated: true, completion: nil)
            
            }
            
        }
        
        let scheduler = DLNotificationScheduler()
        let title = "Manifestation"
        var message = self.txtcomment.text ?? ""

        scheduler.getScheduledNotifications { (request) in
            request?.forEach({ (item) in
                if(item.identifier.contains("manifest")){
                    scheduler.cancelNotification(identifier: item.identifier)
                }
            })
            //Setup new notification for manifestations
            if message == "Write Here..."{
                message = ""
            }
            let totalSecondsInDay = 24 * 60 * 60    //86400 //DayHour * HourMinute * MinuteSecond
            
            var newDate = self.selectedDate
            newDate = Calendar.current.date(bySettingHour: self.selectedDate.hour, minute: self.selectedDate.minute, second: 0, of: self.selectedDate)!

            print("Dinal J" + "\(newDate.hour):\(newDate.minute):\(newDate.second)")
            
            if(self.selectedDay == "every day"){
                let interval = Double(totalSecondsInDay)
                scheduler.repeatsFromToDate(identifier: "manifest", alertTitle: title, alertBody: message, fromDate: newDate, toDate: endDate, interval: interval, repeats: .none )
                scheduler.scheduleAllNotifications()
            }else if(self.selectedDay == "once a week"){
                let interval = Double(totalSecondsInDay * 7)
                scheduler.repeatsFromToDate(identifier: "manifest", alertTitle: title, alertBody: message, fromDate: newDate, toDate: endDate, interval: interval, repeats: .none )
                scheduler.scheduleAllNotifications()

            }else if(self.selectedDay == "every 3 days"){
                let interval = Double(totalSecondsInDay * 3)
                scheduler.repeatsFromToDate(identifier: "manifest", alertTitle: title, alertBody: message, fromDate: newDate, toDate: endDate, interval: interval, repeats: .none )
                scheduler.scheduleAllNotifications()
            }
            
            let scheduler1 = DLNotificationScheduler()
            scheduler1.getScheduledNotifications { (request) in
                request?.forEach({ (item) in
                    if(item.identifier.contains("journal")){
                        scheduler1.cancelNotification(identifier: item.identifier)
                    }
                })
            }
            
        }
        
        

        
    }
    
    
//    func getDayOfWeek(_ today:String) -> Int? {
//        let formatter  = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        guard let todayDate = formatter.date(from: today) else { return nil }
//        let myCalendar = Calendar(identifier: .gregorian)
//        let weekDay = myCalendar.component(.weekday, from: todayDate)
//        return weekDay
//    }

    
    // uer profile :
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
                            
                           self.strUID = Auth.auth().currentUser?.uid
                            self.myDocId = doc.documentID
                           if let strURL = (d["pic"] as? String)
                           {
                               let url = URL(string: strURL)
                              
                           }
                            
                            if let strURL = (d["profileImage"] as? String)
                            {
                                let url = URL(string: strURL)
                                self.imgProfile.sd_setImage(with: url, placeholderImage: UIImage(named: "profile-placeholder-big"))
                            }else{
                                 self.imgProfile.image = UIImage(named: "profile-placeholder-big")
                            }
                            
                            let subscription = d["Subscription"] as? String
                            if subscription != nil
                            {
                                if subscription == "0"
                                {
                                    self.IsSubscripted = false
                                }else
                                {
                                    self.IsSubscripted = true
                                    
                                }
                                self.updateUIForSubscription()
                            }
                            
                            let arr = d["ManifestEntry"] as? NSArray
                            if arr != nil
                            {
                                if arr!.count > 0
                                {
                                    self.arrMyManifestEntry = NSMutableArray.init(array: arr!)
                                    print("My Manifest :\(self.arrMyManifestEntry)")
                                    for i in (0..<self.arrMyManifestEntry.count)
                                    {
                                        let dict = self.arrMyManifestEntry.object(at: i) as? NSDictionary
                                        if dict?.object(forKey: "isActive") != nil
                                        {
                                            let active = dict?.value(forKey: "isActive") as? Bool ?? false
                                            self.IsEditingOn = active
                                            
                                        }else{
                                            self.IsEditingOn = false
                                            
                                        }
                                        
                                        if(self.IsEditingOn){
                                            self.btnsave.isHidden = true
                                            self.lblDisableInfo.isHidden = false
                                            if ((dict?.value(forKey: "answer") as? String) != nil)
                                            {
                                                self.txtcomment.text = String.init(format: "%@",(dict?.value(forKey: "answer") as? CVarArg)!)
                                                self.updateTextview()
                                            }
                                            if dict?.object(forKey: "type") != nil
                                            {
                                                if dict?.value(forKey: "type") as? String == "1"
                                                {
                                                    self.strtype = "1"
                                                }
                                                else
                                                {
                                                    self.strtype = "0"
                                                }
                                            }
                                            
                                            self.updateUIForSubscription()

                                            if dict?.object(forKey: "manifestDay") != nil
                                            {
                                                let dayType = dict?.value(forKey: "manifestDay") as? String ?? ""
                                                self.selectedDay = dayType
                                            }
                                            
                                            if dict?.object(forKey: "manifestTime") != nil
                                            {
                                                let manifestTime = dict?.value(forKey: "manifestTime") as? String ?? ""
                                                
                                                if(manifestTime != ""){
                                                    let dateFormatter = DateFormatter()
                                                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                                                    let date = dateFormatter.date(from:manifestTime)!

                                                    self.selectedDate = date
                                                }
                                                
                                                
                                            }
                                            
                                            self.updateTimeLabel()
                                            
                                            if dict?.object(forKey: "audio_url") != nil
                                            {
                                                if dict?.value(forKey: "audio_url") as? String  != ""
                                                {
                                                    self.firebaseaudioURL = dict?.value(forKey: "audio_url") as? String
                                                }
                                                else
                                                {
                                                    self.firebaseaudioURL = ""
                                                }
                                            }
                                            if dict?.object(forKey: "play_time") != nil
                                            {
                                                let play_time = dict?.value(forKey: "play_time") as? String ?? ""
                                                if play_time != "" && play_time != ""
                                                {
                                                    self.totalSecond = Float(play_time) ?? 0.0
                                                    self.lblMinit.text = String.init(format: "%.2f / %.2f", self.currentMin,self.totalSecond)
                                                }
                                                else
                                                {
                                                    self.totalSecond = 0.0
                                                    self.lblMinit.text = "00:00 / 00:00"
                                                }
                                            }
                                            self.updateUIForSubscription()
                                            break
                                        }
                                        
                                    }
                                }else{
                                    self.IsEditingOn = false
                                }
                            }
                            else
                            {
                                self.IsEditingOn = false
                                print("No ManifestEntry Object !")
                            }
                            
                            if(!self.IsEditingOn){
                                self.btnsave.isHidden = false
                                self.lblDisableInfo.isHidden = true
                                
                                self.txtcomment.text = ""
                                self.selectedDate = Date()
                                self.selectedDay = "every day"
                                
                                self.updateTextview()
                                self.updateTimeLabel()
                                
                                self.updateUIForSubscription()

                            }
                            
                             let mypoint = d["myPoint"] as? String
                             if mypoint != nil
                             {
                                let point = Int(mypoint!)
                                self.currentPoint = point
                             }
                             else
                             {
                                self.currentPoint = 0
                                
                            }
                        }
                    }
                    
                }
            }
        }
    
    
    func generateCurrentTimeStamp () -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd_hh_mm_ss"
        return (formatter.string(from: Date()) as NSString) as String
    }
    

}


