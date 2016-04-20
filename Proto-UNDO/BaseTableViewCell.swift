//
//  BaseTableViewCell.swift
//  ProtoUNDOTest
//
//  Created by Yury on 19/09/15.
//  Copyright © 2015 Yury. All rights reserved.
//

import UIKit

class BaseTableViewCell: SingleSelectionTableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let button = AppDefaultButton(frame: CGRectMake(0, 0, 73, 73))
        button.setTitle("\u{25CF}\u{25CF}\u{25CF}", forState: .Normal)
        button.addTarget(self, action: Selector("onAccessoryButtonTapped"), forControlEvents: UIControlEvents.TouchUpInside)
        accessoryView = button
        
        selectionStyle = .None
    }

    func onAccessoryButtonTapped() {
        selected = true
    }
}
