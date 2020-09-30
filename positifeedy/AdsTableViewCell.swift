//
//  AdsTableViewCell.swift
//  positifeedy
//
//  Created by iMac on 25/09/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import UIKit
import GoogleMobileAds





class AdsTableViewCell: UITableViewCell, GADUnifiedNativeAdLoaderDelegate, GADUnifiedNativeAdDelegate {
    
    var adLoader: GADAdLoader!
    
    lazy var mainView: GoogleAdBannerView = {
        let view = GoogleAdBannerView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var controller  : UIViewController? {
        didSet{
            if let _ = controller{
                fetchAds()
            }
        }
    }
    
    func fetchAds ()  {
        adLoader = GADAdLoader(adUnitID: "ca-app-pub-3940256099942544/3986624511", rootViewController: controller, adTypes: [GADAdLoaderAdType.unifiedNative], options: nil)
        adLoader.delegate = self
        
        let adRequest = GADRequest()
        adLoader.load(adRequest)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .gray
        
        addSubview(mainView)
        
        mainView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        mainView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        mainView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        mainView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        mainView.refreshBtn.addTarget(self, action: #selector(refreshFieldAds(_:)), for: .touchUpInside)
        
        mainView.refreshBtn.isHidden = true
        
        fetchAds ()
        
    }
    
    @objc func refreshFieldAds( _ sender : UIButton) {
        
        fetchAds()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        
        mainView.nativeAd = nativeAd
        nativeAd.delegate = self
        
        print("Ad has been received.")
        
        mainView.mediaView?.mediaContent = nativeAd.mediaContent
        
        (mainView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        
        (mainView.headlineView as? UILabel)?.text = nativeAd.headline
        
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("Failed Ad Request: ", error)
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
