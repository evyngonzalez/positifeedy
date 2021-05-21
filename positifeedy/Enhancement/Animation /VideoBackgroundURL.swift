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
        
        
        let path = downloadTheme(theme: videoURL!.absoluteString)
        if(path == ""){
            videoPlayer = AVPlayer(url: videoURL!)    //working
        }else{
            let playerItem = AVPlayerItem(url: URL(fileURLWithPath: path.replacingOccurrences(of: "file://", with: "")))
            videoPlayer = AVPlayer(playerItem: playerItem)
        }
        
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
        let isVideo = UserDefaults.standard.bool(forKey: "IsVideo")
        if(isVideo){
            player.play()
        }
    }
    
    @objc func resumePlaying(notification:Notification) {
        guard let player = playerLayer?.player else { return }
        
        let isVideo = UserDefaults.standard.bool(forKey: "IsVideo")
        if(isVideo){
            player.play()
        }
        
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


func downloadTheme(theme: String, savingStatus : ((_ status:Bool) -> Void)? = nil) -> String{
    let videoUrl = URL(string: theme)!
    let session = URLSession(configuration: URLSessionConfiguration.default)

    let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let destinationUrl = docsUrl.appendingPathComponent("Themes").appendingPathComponent(videoUrl.lastPathComponent)
    if(FileManager().fileExists(atPath: destinationUrl.path)){
            print("\n\nfile already exists\n\n \(destinationUrl.absoluteString)")
            if let function = savingStatus{
                function(true)
               }
            return destinationUrl.absoluteString
        }
        else{
            DispatchQueue.global(qos: .background).async {
                do {
                    try FileManager.default.createDirectory(atPath: docsUrl.appendingPathComponent("Themes").path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription)
                }
            
                    var request = URLRequest(url: videoUrl)
                    request.httpMethod = "GET"
                    _ = session.dataTask(with: request, completionHandler: { (data, response, error) in
                        
                        if(error != nil){
                            print("\n\nsome error occured\n\n")
                            return
                        }
                        if let response = response as? HTTPURLResponse{
                        if response.statusCode == 200{
                            DispatchQueue.main.async {
                                if let data = data{
                                    if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic){
                                        print("\n\nurl data written\n\n \(destinationUrl)")
                                        if let function = savingStatus{
                                            function(true)
                                           }
                                    }
                                    else{
                                        print("\n\nerror again\n\n")
                                        if let function = savingStatus{
                                            function(false)
                                           }
                                    }
                                }//end if let data
                            }//end dispatch main
                        }//end if let response.status
                    }
                }).resume()
            }
            return ""
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

func hexStringFromColor(color: UIColor) -> String {
    let components = color.cgColor.components
    let r: CGFloat = components?[0] ?? 0.0
    let g: CGFloat = components?[1] ?? 0.0
    let b: CGFloat = components?[2] ?? 0.0

    let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    print(hexString)
    return hexString
 }

func colorWithHexString(hexString: String) -> UIColor {
    var colorString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
    colorString = colorString.replacingOccurrences(of: "#", with: "").uppercased()

    print(colorString)
    let alpha: CGFloat = 1.0
    let red: CGFloat = colorComponentFrom(colorString: colorString, start: 0, length: 2)
    let green: CGFloat = colorComponentFrom(colorString: colorString, start: 2, length: 2)
    let blue: CGFloat = colorComponentFrom(colorString: colorString, start: 4, length: 2)

    let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
    return color
}

func colorComponentFrom(colorString: String, start: Int, length: Int) -> CGFloat {

    let startIndex = colorString.index(colorString.startIndex, offsetBy: start)
    let endIndex = colorString.index(startIndex, offsetBy: length)
    let subString = colorString[startIndex..<endIndex]
    let fullHexString = length == 2 ? subString : "\(subString)\(subString)"
    var hexComponent: UInt32 = 0

    guard Scanner(string: String(fullHexString)).scanHexInt32(&hexComponent) else {
        return 0
    }
    let hexFloat: CGFloat = CGFloat(hexComponent)
    let floatValue: CGFloat = CGFloat(hexFloat / 255.0)
    print(floatValue)
    return floatValue
}
