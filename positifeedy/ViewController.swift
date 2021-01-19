//
//  ViewController.swift
//  positifeedy
//
//  Created by Evyn Gonzalez  on 9/11/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import UIKit
import VideoBackground

class ViewController: UIViewController {

    @IBOutlet weak var btnsignup: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.design()
        self.setupVideoView()
        
    }
   
    func design() -> Void {
        
        self.btnsignup.layer.cornerRadius = 5
        self.btnsignup.clipsToBounds = true
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
    
    @IBAction func btnSignUp(_ sender: Any) {
        
        let vc = storyBoard.instantiateViewController(withIdentifier: "signUpViewController") as! signUpViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "logInViewController") as! logInViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

