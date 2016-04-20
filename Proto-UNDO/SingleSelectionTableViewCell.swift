//
//  SingleSelectionTableViewCell.swift
//  ProtoUNDOTest
//
//  Created by Yury on 19/09/15.
//  Copyright © 2015 Yury. All rights reserved.
//

import UIKit
let kSelectionChangedNotification = "kSelectionChangedNotification"

class SingleSelectionTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        NSNotificationCenter.defaultCenter().addObserverForName( kSelectionChangedNotification,
            object: nil,
            queue: NSOperationQueue.mainQueue())
            {
                (notification) -> Void in
                if notification.object !== self {
                    self.selected = false
                }
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            NSNotificationCenter.defaultCenter().postNotificationName(kSelectionChangedNotification, object: self)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
