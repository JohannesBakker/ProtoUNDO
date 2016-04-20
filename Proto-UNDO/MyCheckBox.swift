//
//  MyCheckBox.swift
//  layout
//
//  Created by Lee Xiaoxiao on 9/24/15.
//  Copyright © 2015 Lee Xiaoxiao. All rights reserved.
//

import UIKit

class MyCheckBox: UIButton {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
    let checkedImage = UIImage(named: "knob_checked")
    let unCheckedImage = UIImage(named: "knob_empty")
    
    var isChecked:Bool = false {
        didSet {
            if isChecked == true {
                self.setImage(checkedImage, forState: .Normal)
                
            }
            else
            {
                self.setImage(unCheckedImage, forState: .Normal)
                
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        isChecked = false
    }
    
    func buttonClicked(sender:UIButton) {
        if isChecked == true {
            isChecked = false
        }
        else
        {
            isChecked = true
        }
    }
}
