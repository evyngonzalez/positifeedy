//
//  PositifeedyCell.swift
//  positifeedy
//
//  Created by iMac on 13/10/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import UIKit

class PositifeedyCell: UICollectionViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBookmark: UIButton!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var viewMain: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewMain.layer.cornerRadius = 10.0
        viewMain.layer.shadowColor = UIColor.lightGray.cgColor
        viewMain.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        viewMain.layer.shadowRadius = 4.0
        viewMain.layer.shadowOpacity = 1.0
    }

}
