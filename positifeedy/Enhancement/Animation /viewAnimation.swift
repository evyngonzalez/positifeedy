//
//  viewAnimation.swift
//  positifeedy
//
//  Created by iMac on 19/04/21.
//  Copyright © 2021 Evyn Gonzalez . All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class BoxView: UIView {

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        layer.borderColor = borderColor?.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
    }

    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
            setNeedsLayout()
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
            setNeedsLayout()
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            setNeedsLayout()
        }
    }
}


@IBDesignable
class BoxViewShadow: UIView {

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        layer.borderColor = borderColor?.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
    }

    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
            setNeedsLayout()
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
            setNeedsLayout()
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            setNeedsLayout()
        }
    }
    @IBInspectable var addShadow:Bool = true{

            didSet(newValue) {
                if(newValue == true){
                    //self.layer.masksToBounds = false
                    self.layer.masksToBounds = true
                    self.layer.shadowColor = UIColor.black.cgColor
                    self.layer.shadowOpacity = 0.5
                    self.layer.shadowOffset = CGSize(width: 2, height: 3)
                    self.layer.shadowRadius = 3

                    self.layer.shadowPath = UIBezierPath(rect: bounds).cgPath
                    self.layer.shouldRasterize = true
                    self.layer.rasterizationScale =  UIScreen.main.scale
                    print("trying to use shadow")
                }
            }

        }
}
