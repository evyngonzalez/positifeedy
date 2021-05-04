//
//  FeedyCellUr.swift
//  positifeedy
//
//  Created by iMac on 19/04/21.
//  Copyright © 2021 Evyn Gonzalez . All rights reserved.
//

import UIKit
import LinkPresentation

class FeedyCellUr: UITableViewCell {

    
    @IBOutlet weak var viewlink: UIView!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnplay: UIButton!
    @IBOutlet weak var btnBookmark: UIButton!
    @IBOutlet weak var img: RoundableImageView!
    
    @IBOutlet weak var lblreadtime: UILabel!
    @IBOutlet weak var imgminilogo: RoundableImageView!
    @IBOutlet weak var lblminidiscription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
     func bindData(feed: PositifeedAllSet){
            
            if feed.timestamp != nil {
                let f = DateFormatter()
                let date = Date(timeIntervalSince1970: Double(feed.timestamp!)!)
                lblreadtime.text = date.getElapsedInterval(f.timeZone)
            }
            
            btnplay.cornerRadius(10)
            
            btnBookmark.setImage(UIImage(named: "book_mark_ic"), for: .normal)
            btnBookmark.setImage(UIImage(named: "bookmarkSelected"), for: .selected)
            
            let feed_type = feed.feed_type ?? "image"
            let feed_url = feed.feed_url ?? ""
            
            lblTitle.text = feed.title ?? ""
            lblminidiscription.text = feed.desc ?? ""
            
            //lblTitle.constant = 10.0
            
            if feed_type == "image" {
                
               // heightImg.constant = (UIScreen.main.bounds.width - 30.0) / 1.6
                
                if feed.feed_image != nil {
                    if let link = URL(string: feed.feed_image!)
                    {
                        imgminilogo.sd_setImage(with: link, placeholderImage: UIImage.init(named: "album_placeholder"), options: .highPriority, completed: nil)
                    } else {
                        imgminilogo.image = nil
                    }
                } else {
                    imgminilogo.image = nil
                }
                
                imgminilogo.isHidden = false
                btnplay.isHidden = true
                viewlink.isHidden = true
                
            } else if feed_type == "text" {
                
             //   heightImg.constant = 0.0
                imgminilogo.isHidden = true
                btnplay.isHidden = true
                viewlink.isHidden = true
                
            } else if feed_type == "video" {
                
              //  heightImg.constant = (UIScreen.main.bounds.width - 30.0) / 1.6
                
                if feed.feed_image != nil {
                    if let link = URL(string: feed.feed_image!)
                    {
                        imgminilogo.sd_setImage(with: link, placeholderImage: UIImage.init(named: "album_placeholder"), options: .highPriority, completed: nil)
                    } else {
                        imgminilogo.image = nil
                    }
                } else {
                    imgminilogo.image = nil
                }
                
                imgminilogo.isHidden = false
                btnplay.isHidden = false
                viewlink.isHidden = true
                
            } else if feed_type == "link" {
                
                //topLblTitle.constant = 20.0
                lblminidiscription.text = ""
                
               // heightImg.constant = (UIScreen.main.bounds.width - 30.0) / 1.6
                imgminilogo.isHidden = true
                btnplay.isHidden = true
                viewlink.isHidden = false
                viewlink.isUserInteractionEnabled = false
                
                if #available(iOS 13.0, *) {
                    
                    let frameLink = CGRect.init(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width - 30.0, height: (UIScreen.main.bounds.width - 30.0) / 1.6)
                    
                    var provider = LPMetadataProvider()
                    provider = LPMetadataProvider()
                    provider.timeout = 50
                    
                    if viewlink.viewWithTag(999) != nil {
                        
                        if let url = URL(string: feed_url) {
                            
                            var linkView = LPLinkView(url: url)

                            // 1. Check if the metadata exists
                            if let existingMetadata = MetadataCache.retrieve(urlString: url.absoluteString) {
                                
                                self.lblTitle.text = existingMetadata.title ?? ""
                                (self.viewlink.viewWithTag(999)! as! LPLinkView).metadata = existingMetadata

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
                                        
                                        (self.viewlink.viewWithTag(999)! as! LPLinkView).metadata = metadata
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
                                self.lblTitle.text = existingMetadata.title ??  ""
                                
                                if let imageProvider = existingMetadata.imageProvider {
                                                                       existingMetadata.iconProvider = imageProvider
                                    
                                                                   }
                                
                                
                                


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
                        self.viewlink.addSubview(linkView)

                    }

                } else {
                    self.img.sd_imageIndicator = nil
                    self.img.image = UIImage(named: "vlogo")
                }
                
            }
            
            self.layoutIfNeeded()
    //        viewLink.isHidden = false

        }
}
