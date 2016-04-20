//
//  MoreStarTableViewCell.swift
//  Proto-UNDO
//
//  Created by Yury on 29/09/15.
//  Copyright © 2015 Curly Brackets. All rights reserved.
//

import UIKit

class MoreStarTableViewCell: MoreTableViewCell {

    @IBOutlet var starButton: UIButton!
    @IBOutlet var exclButton: UIButton!
    
    let nonSelectedColor = UIColor(red:0.52, green:0.55, blue:0.60, alpha:1.0)
    let selectedColor = UIColor.blackColor()
    
    @IBAction func starTapped(sender: UIButton) {
        selected = true
        updateButton(sender, selected: !sender.selected)
        event.starMark = sender.selected
    }
    
    @IBAction func exclTapped(sender: UIButton) {
        selected = true
        updateButton(sender, selected: !sender.selected)
        event.exclamationMark = sender.selected
    }
    
    override func updateCell() {
        updateButton(starButton, selected: event.starMark)
        updateButton(exclButton, selected: event.exclamationMark)
    }
    
    func updateButton(button: UIButton, selected: Bool) {
        button.selected = selected
        button.tintColor = selected ? selectedColor : nonSelectedColor
    }
}
