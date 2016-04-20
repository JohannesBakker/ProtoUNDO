//
//  MoreParentTableViewCell.swift
//  Proto-UNDO
//
//  Created by Yury on 29/09/15.
//  Copyright © 2015 Curly Brackets. All rights reserved.
//

import UIKit

class MoreParentTableViewCell: MoreTableViewCell {

    @IBOutlet var parentButton: UIButton!
    
    let nonSelectedColor = UIColor(red:0.52, green:0.55, blue:0.60, alpha:1.0)
    let selectedColor = UIColor.blackColor()
    
    @IBAction func parentTapped(sender: UIButton) {
        selected = true
        updateButton(sender, selected: !sender.selected)
        event.parentMark = sender.selected
    }
    
    override func updateCell() {
        updateButton(parentButton, selected: event.parentMark)
    }
    
    func updateButton(button: UIButton, selected: Bool) {
        button.selected = selected
        button.tintColor = selected ? selectedColor : nonSelectedColor
    }

}
