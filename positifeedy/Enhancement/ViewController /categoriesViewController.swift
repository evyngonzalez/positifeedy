//
//  categoriesViewController.swift
//  positifeedy
//
//  Created by iMac on 24/04/21.
//  Copyright © 2021 Evyn Gonzalez . All rights reserved.
//

import UIKit

class categoriesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func categoris(_ sender : UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
}
