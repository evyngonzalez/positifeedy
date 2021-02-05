//
//  TblFeedTextCell.swift
//  positifeedy
//
//  Created by Hiren Dhamecha on 30/01/21.
//  Copyright © 2021 Evyn Gonzalez . All rights reserved.
//

import UIKit

class TblFeedTextCell: UITableViewCell {

    @IBOutlet weak var img : UIImageView!
      
    
    //@IBOutlet weak var topLblTitle: NSLayoutConstraint!
      @IBOutlet weak var lblTitle : UILabel!
      @IBOutlet weak var lblDesc : UILabel!
    
      
      @IBOutlet weak var lblTime : UILabel!
      @IBOutlet weak var btnBookMark : UIButton!
      @IBOutlet weak var btnShare: UIButton!
      
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
