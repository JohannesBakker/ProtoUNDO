//
//  AppDefaultButton.swift
//  ProtoUNDOTest
//
//  Created by Yury on 19/09/15.
//  Copyright © 2015 Yury. All rights reserved.
//

import UIKit

class AppDefaultButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setStyle()
    }
    
    override var selected: Bool {
        didSet {
            backgroundColor = selected ? UIColor.whiteColor() : UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        }
    }
    
    func setStyle() {
        setTitleColor(UIColor(red:0.91, green:0.25, blue:0.20, alpha:1.0), forState: .Normal)
        backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        layer.cornerRadius = 15
        layer.borderColor = UIColor(red:0.77, green:0.77, blue:0.77, alpha:1.0).CGColor
        layer.borderWidth = 1
        titleLabel!.numberOfLines = 0
        titleLabel!.textAlignment = .Center
    }
}
