//
//  AdsTableViewNew.swift
//  positifeedy
//
//  Created by iMac on 30/04/21.
//  Copyright © 2021 Evyn Gonzalez . All rights reserved.
//

import UIKit
import GoogleMobileAds

class AdsTableViewNew: UITableViewCell, GADUnifiedNativeAdDelegate, GADUnifiedNativeAdLoaderDelegate {
    
    @IBOutlet weak var nativeAdView: GADUnifiedNativeAdView!
    
    
    var adLoader: GADAdLoader!
    
//    lazy var mainView: GoogleAdBannerView = {
//        let view = GoogleAdBannerView()
//        view.backgroundColor = .white
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
    var controller : UIViewController? {
        didSet{
            if let _ = controller{
              //fetchAds()
            }
        }
    }
    
    func fetchAds ()  {
        
        
        // local : ca-app-pub-3940256099942544/3986624511
        
        
        
        adLoader = GADAdLoader(adUnitID: "ca-app-pub-5392374810652881/4568120220", rootViewController: controller, adTypes: [GADAdLoaderAdType.unifiedNative], options: nil)
        adLoader.delegate = self
        
        let adRequest = GADRequest()
        adLoader.load(adRequest)
    }
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        backgroundColor = .gray
        
//        addSubview(mainView)
//
//        mainView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
//        mainView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
//        mainView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        mainView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        mainView.refreshBtn.addTarget(self, action: #selector(refreshFieldAds(_:)), for: .touchUpInside)
//
//        mainView.refreshBtn.isHidden = true
        
        fetchAds ()

    }
    
    @objc func refreshFieldAds( _ sender : UIButton) {
        
//       fetchAds()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        
        nativeAdView.nativeAd = nativeAd
        nativeAd.delegate = self
        
        print("Ad has been received.")
        
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        
        (nativeAdView.iconView as? UIImageView)?.layer.cornerRadius = 10
        (nativeAdView.iconView as? UIImageView)?.clipsToBounds = true
        
        UserDefaults.standard.setValue("1", forKey:PREF_AD_HEIGHT)
        
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("Failed Ad Request: ", error)
        
        UserDefaults.standard.setValue("0", forKey:PREF_AD_HEIGHT)
    }
    
    func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd)
    {
        print("nativeAdDidRecordClick")
    }
    
    func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd)
    {
        print("nativeAdDidRecordImpression called")
    }
    
    func nativeAdWillPresentScreen(_ nativeAd: GADUnifiedNativeAd)
    {
        print("nativeAdWillPresentScreen called")
    }
    
    func nativeAdWillDismissScreen(_ nativeAd: GADUnifiedNativeAd)
    {
        print("nativeAdWillPresentScreen called")
    }
    
    func nativeAdDidDismissScreen(_ nativeAd: GADUnifiedNativeAd)
    {
        print("nativeAdDidDismissScreen called")
    }
    
    func nativeAdWillLeaveApplication(_ nativeAd: GADUnifiedNativeAd)
    {
        print("nativeAdWillLeaveApplication called")
    }
    

}






