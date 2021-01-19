//
//  tblJournalCell.swift
//  positifeedy
//
//  Created by Hiren Dhamecha on 11/12/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import UIKit

class tblJournalCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var imgItem: UIImageView!
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var bgview: UIView!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
