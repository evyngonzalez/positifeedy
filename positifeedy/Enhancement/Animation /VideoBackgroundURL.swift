//
//  VideoBackground.swift
//  VideoBackground
//
//  Created by Ruvim Micsanschi on 2/15/17.
//  Copyright © 2017 com.codingroup. All rights reserved.
//

import UIKit
import AVKit
import Foundation
import AVFoundation

public struct VideoOptionsURL {
    let pathToVideo:String
    let pathToImage:String
    let volume:Float
    let shouldLoop:Bool
    
    public init(pathToVideo:String, pathToImage:String, volume:Float = 0.0, shouldLoop:Bool = true) {
        self.pathToVideo = pathToVideo
        self.pathToImage = pathToImage
        self.volume = volume
        self.shouldLoop = shouldLoop
    }
}

/**
 VideoBackground view
 */
final public class VideoBackgroundURL: UIView {
    
    private var imageView:UIImageView?
    private var videoView:VideoBackgroundViewURL?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// Default initializer
    ///
    /// - Parameters:
    ///   - frame: view frame
    ///   - options: VideoOptions struct
    convenience public init(frame: CGRect, options:VideoOptionsURL) {
        self.init(frame:frame)
        
        let placeholderImageView = UIImageView(frame: frame)
        placeholderImageView.contentMode = .scaleAspectFill
        placeholderImageView.image = loadImage(at: options.pathToImage)
        placeholderImageView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        addSubview(placeholderImageView)
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        placeholderImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        placeholderImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        placeholderImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        placeholderImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        let videoView = VideoBackgroundViewURL(frame: frame, options: options)
        videoView.readyForDisplay = readyToDisplay
        
        self.imageView = placeholderImageView
        self.videoView = videoView
    }
    
    private func readyToDisplay() {
        guard let videoView = videoView, let imageView = imageView else { return }
        UIView.transition(from: imageView, to: videoView, duration:0.25, options: .transitionCrossDissolve) { (_) in
            imageView.removeFromSuperview()
        }
    }
    
    private func loadImage(at path:String) -> UIImage? {
        guard let imageData = try? Data(contentsOf: URL(fileURLWithPath: path)), let image = UIImage(data:imageData) else {
            return nil
        }
        return image
    }
}


/**
 VideoBackgroundView - Private class
 */
final private class VideoBackgroundViewURL : UIView {
    
    private var timer: Timer?
    private var timerCount = 0
    var readyForDisplay:(() -> Void)?
    
    
    convenience init(frame: CGRect, options:VideoOptionsURL) {
        self.init(frame:frame)
        setupPlayer(with: options)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        invalidateTimer()
    }
    
    private func setupPlayer(with options:VideoOptionsURL) {

        let videoURL = URL(string: options.pathToVideo)
        videoPlayer.pause()
        videoPlayer = AVPlayer()
        
        
//        videoCacheManager = VideoCache(limit : 500)
//        if let manager = videoCacheManager, let url = videoURL {
//            videoPlayer = manager.setPlayer(with : url)
//        }
        
        videoPlayer = AVPlayer(url: videoURL!)    //working
        videoPlayer.actionAtItemEnd = .none
        videoPlayer.volume = options.volume


//        let player = AVPlayer(url:URL(fileURLWithPath: options.pathToVideo))
        
//        let playerLayer = AVPlayerLayer(player: player)
//        playerLayer.frame = view.frame
//        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//
//        let newView = UIView(frame: playerLayer.frame)
//        newView.layer.addSublayer(playerLayer)
//
//        view.insertSubview(newView, at: 0)
//
//        player.play()
        

        let playerLayer1 = AVPlayerLayer(player: videoPlayer)
        playerLayer1.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer1.frame = bounds
        
        playerLayer = playerLayer1
        
        layer.addSublayer(playerLayer!)
        
        timer = Timer.scheduledTimer(timeInterval:0.2, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        
        if options.shouldLoop {
            NotificationCenter.default.addObserver(self, selector: #selector(startFromBeginning), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(resumePlaying), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pausePlaying), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func startFromBeginning(notification:Notification) {
        guard let player = playerLayer?.player else { return }
        player.seek(to: CMTime.zero)
        player.play()
    }
    
    @objc func resumePlaying(notification:Notification) {
        guard let player = playerLayer?.player else { return }
        player.play()
    }
    
    @objc func pausePlaying(notification:Notification) {
        guard let player = playerLayer?.player else { return }
        player.pause()
    }
    
    @objc func timerFired() {
        
        guard let playerLayer = playerLayer, timerCount < 60 else {
            invalidateTimer()
            return
        }
        
        if playerLayer.isReadyForDisplay {
            playerLayer.player?.play()
            invalidateTimer()
            readyForDisplay?()
        }
        
        timerCount += 1
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
}


func getThumbnailImage(forUrl url: URL) -> UIImage? {
    let asset: AVAsset = AVAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)

    let imageData = UserDefaults.standard.object(forKey: url.absoluteString) as? Data ?? Data()
    if imageData.count > 0 {
        return UIImage(data: imageData)
    }
    
    do {
        let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
        let image = UIImage(cgImage: thumbnailImage)
        
        let dataImg = image.pngData()
        UserDefaults.standard.set(dataImg, forKey: url.absoluteString)
        UserDefaults.standard.synchronize()
        return image
    } catch let error {
        print(error)
    }

    return nil
}
