//
//  FeedyCell.swift
//  positifeedy
//
//  Created by iMac on 27/10/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import UIKit
import LinkPresentation

class FeedyCell: UITableViewCell {
    
    @IBOutlet weak var img : UIImageView!
    
    @IBOutlet weak var topLblTitle: NSLayoutConstraint!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblDesc : UILabel!
    @IBOutlet weak var imgView : UIImageView!
    
    @IBOutlet weak var lblTime : UILabel!
    @IBOutlet weak var btnBookMark : UIButton!
    @IBOutlet weak var btnShare: UIButton!
    
    @IBOutlet weak var btnPlay: UIButton!
    
    @IBOutlet weak var heightImg: NSLayoutConstraint!
    
    @IBOutlet weak var viewLink: UIView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        img.layer.cornerRadius = 20.0
        img.clipsToBounds = true
        
        imgView.layer.cornerRadius = 10.0
        imgView.layer.shadowColor = UIColor.lightGray.cgColor
        imgView.layer.shadowOffset = CGSize.zero
        imgView.layer.shadowRadius = 2.0
        imgView.layer.shadowOpacity = 1.0
        
        viewLink.layer.cornerRadius = 10.0
        viewLink.layer.shadowColor = UIColor.lightGray.cgColor
        viewLink.layer.shadowOffset = CGSize.zero
        viewLink.layer.shadowRadius = 2.0
        viewLink.layer.shadowOpacity = 1.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func bindData(feed: Positifeedy) {
        
        if feed.timestamp != nil {
            let f = DateFormatter()
            let date = Date(timeIntervalSince1970: Double(feed.timestamp!)!)
            lblTime.text = date.getElapsedInterval(f.timeZone)
        }
        
        btnPlay.cornerRadius(10)
        
        btnBookMark.setImage(UIImage(named: "book_mark_ic"), for: .normal)
        btnBookMark.setImage(UIImage(named: "bookmarkSelected"), for: .selected)
        
        let feed_type = feed.feed_type ?? "image"
        let feed_url = feed.feed_url ?? ""
        
        lblTitle.text = feed.title ?? ""
        lblDesc.text = feed.desc ?? ""
        
        topLblTitle.constant = 10.0
        
        if feed_type == "image" {
            
            heightImg.constant = (UIScreen.main.bounds.width - 30.0) / 1.6
            
            if feed.feed_image != nil {
                if let link = URL(string: feed.feed_image!)
                {
                    imgView.sd_setImage(with: link, placeholderImage: UIImage.init(named: "album_placeholder"), options: .highPriority, completed: nil)
                } else {
                    imgView.image = nil
                }
            } else {
                imgView.image = nil
            }
            
            imgView.isHidden = false
            btnPlay.isHidden = true
            viewLink.isHidden = true
            
        } else if feed_type == "text" {
            
            heightImg.constant = 0.0
            imgView.isHidden = true
            btnPlay.isHidden = true
            viewLink.isHidden = true
            
        } else if feed_type == "video" {
            
            heightImg.constant = (UIScreen.main.bounds.width - 30.0) / 1.6
            
            if feed.feed_image != nil {
                if let link = URL(string: feed.feed_image!)
                {
                    imgView.sd_setImage(with: link, placeholderImage: UIImage.init(named: "album_placeholder"), options: .highPriority, completed: nil)
                } else {
                    imgView.image = nil
                }
            } else {
                imgView.image = nil
            }
            
            imgView.isHidden = false
            btnPlay.isHidden = false
            viewLink.isHidden = true
            
        } else if feed_type == "link" {
            
            topLblTitle.constant = 20.0
            lblDesc.text = ""
            
            heightImg.constant = (UIScreen.main.bounds.width - 30.0) / 1.6
            imgView.isHidden = true
            btnPlay.isHidden = true
            viewLink.isHidden = false
            viewLink.isUserInteractionEnabled = false
            
            if #available(iOS 13.0, *) {
                
                let frameLink = CGRect.init(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width - 30.0, height: (UIScreen.main.bounds.width - 30.0) / 1.6)
                
                var provider = LPMetadataProvider()
                provider = LPMetadataProvider()
                provider.timeout = 50
                
                if viewLink.viewWithTag(999) != nil {
                    
                    if let url = URL(string: feed_url) {
                        
                        var linkView = LPLinkView(url: url)

                        // 1. Check if the metadata exists
                        if let existingMetadata = MetadataCache.retrieve(urlString: url.absoluteString) {
                            
                            self.lblTitle.text = existingMetadata.title ?? ""
                            (self.viewLink.viewWithTag(999)! as! LPLinkView).metadata = existingMetadata

//                            viewLink.viewWithTag(999)?.removeFromSuperview()
//
//                            linkView = LPLinkView(metadata: existingMetadata)
//                            linkView.tag = 999
//                            linkView.frame = viewLink.bounds
//                            viewLink.addSubview(linkView)

                        } else {

                            // 2. If it doesn't start the fetch
                            provider.startFetchingMetadata(for: url) { [weak self] metadata, error in
                                guard let self = self else { return }
                                
                                guard let metadata = metadata, error == nil else {
                                    return
                                }

                                // 3. And cache the new metadata once you have it
                                if let imageProvider = metadata.imageProvider {
                                    metadata.iconProvider = imageProvider
                                }
                                MetadataCache.cache(metadata: metadata)
                                
                                // 4. Use the metadata
                                DispatchQueue.main.async { [weak self] in
                                    guard let self = self else { return }
                                    
                                    (self.viewLink.viewWithTag(999)! as! LPLinkView).metadata = metadata
                                    self.lblTitle.text = metadata.title ?? ""
                                }
                            }
                        }
                    }
                } else {
                    
                    var linkView = LPLinkView()

                    if let url = URL(string: feed_url) {
                        
                        linkView = LPLinkView(url: url)

                        // 1. Check if the metadata exists
                        if let existingMetadata = MetadataCache.retrieve(urlString: url.absoluteString) {

                            linkView = LPLinkView(metadata: existingMetadata)
                            self.lblTitle.text = existingMetadata.title ?? ""


                        } else {
                            // 2. If it doesn't start the fetch
                            provider.startFetchingMetadata(for: url) { [weak self] metadata, error in
                                guard let self = self else { return }
                                
                                guard let metadata = metadata, error == nil else {
                                    return
                                }
                                
                                // 3. And cache the new metadata once you have it
                                if let imageProvider = metadata.imageProvider {
                                    metadata.iconProvider = imageProvider
                                }
                                MetadataCache.cache(metadata: metadata)
                                
                                // 4. Use the metadata
                                DispatchQueue.main.async { [weak self] in
                                    linkView.metadata = metadata
                                    self!.lblTitle.text = metadata.title ?? ""
                                }
                            }
                        }
                    }
                    
                    linkView.tag = 999
                    linkView.frame = frameLink
                    self.viewLink.addSubview(linkView)

                }

            } else {
                
            }
            
        }
        
        self.layoutIfNeeded()
//        viewLink.isHidden = false

    }
}
