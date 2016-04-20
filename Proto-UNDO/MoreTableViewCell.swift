//
//  MoreTableViewCell.swift
//  Proto-UNDO
//
//  Created by Yury on 28/09/15.
//  Copyright © 2015 Curly Brackets. All rights reserved.
//

import UIKit

let kMoreSelectionChangedNotification = "kMoreSelectionChangedNotification"

class MoreTableViewCell: UITableViewCell {

    var tableView: UITableView! // Is required to allow cells to change their height
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NSNotificationCenter.defaultCenter().addObserverForName( kMoreSelectionChangedNotification,
            object: nil,
            queue: NSOperationQueue.mainQueue())
            {
                (notification) -> Void in
                if notification.object !== self {
                    self.selected = false
                }
        }
    }

    var event: LogEvent! {
        didSet{
            updateCell()
        }
    }
    
    func updateCell() {
    }
    
    // This is used to bypass a UITableView bug (or feature) - UITableView calls setSelected: for cells during creation/getting from reuse-cells-queue if they were selected before even if cell.selected is previously explicitly set to false in setSelected method with super.setSelected(false, animated: false). This cause a constraints error and bad layout.
    func selectCell(selected: Bool) {
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            NSNotificationCenter.defaultCenter().postNotificationName(kMoreSelectionChangedNotification, object: self)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
