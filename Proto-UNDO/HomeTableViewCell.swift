//
//  HomeTableViewCell.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 12.08.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import UIKit

class HomeTableViewCell: ProtoTableViewCell {
    @IBOutlet var actionLabels: [BButton]!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func loadDictionary (dict:NSDictionary, key:String) {
        TypeName = key
        titleLabel.text = TypeName!.capitalizedString
        let subDict:NSDictionary = (dict[key] as? NSDictionary)!
        let actions:[String]? = subDict[kActionDescription] as? [String]
        if (actions != nil){
            let _actions:[String] = actions!;
            for var i=0 ; i<actionLabels.count ; i++ {
                actionLabels[i].hidden = true
                if i<_actions.count {
                    actionLabels[i].hidden = false
                    actionLabels[i].setTitle(_actions[i], forState: UIControlState.Normal)
                }
                
            }
        }
    }
    
    func addTargetForActions(target: AnyObject?, action: Selector, forControlEvents controlEvents: UIControlEvents){
        for btn in actionLabels{
            btn.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
            btn.addTarget(target, action: action, forControlEvents: controlEvents)
            btn.parentCell = self
        }
    }
}
