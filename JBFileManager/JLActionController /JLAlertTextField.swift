//
//  JLAlertTextField.swift
//  JLActionController
//
//  Created by Jason Loewy on 5/18/16.
//  Copyright © 2016 Jason Loewy. All rights reserved.
//

import UIKit

class JLAlertTextField: UITextField, UITextFieldDelegate {
    
    fileprivate let bottomBorder         = CALayer()
    fileprivate let inactiveBottomBorder = CALayer()
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        delegate            = self
        font                = UIFont.systemFont(ofSize: 16.0)
        textColor           = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        bottomBorder.isHidden = true
        
        bottomBorder.backgroundColor         = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        inactiveBottomBorder.backgroundColor = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0).cgColor
        layer.addSublayer(bottomBorder)
        layer.addSublayer(inactiveBottomBorder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bottomBorder.frame         = CGRect(x: 0, y: bounds.height-2, width: bounds.width, height: 2)
        inactiveBottomBorder.frame = bottomBorder.frame
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        bottomBorder.isHidden         = false
        inactiveBottomBorder.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        bottomBorder.isHidden         = true
        inactiveBottomBorder.isHidden = false
    }

}
