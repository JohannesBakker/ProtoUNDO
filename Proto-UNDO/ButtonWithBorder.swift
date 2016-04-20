//
//  ButtonWithBorder.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 29.07.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import UIKit

class BButton: UIButton {
    var parentCell:UITableViewCell? = nil
    override var highlighted: Bool {
        get {
            
            return super.highlighted
            
        }
        set {
            if newValue {
                setBorderForView(self, color: UIColor.greenColor(), width: 1, radius: 3)
            }
            else{
                setBorderForView(self, color: UIColor.clearColor(), width: 1, radius: 3)
            }
            
            super.highlighted = newValue
        }
    }
}