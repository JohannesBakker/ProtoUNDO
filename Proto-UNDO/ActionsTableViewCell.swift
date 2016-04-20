//
//  ActionsTableViewCell.swift
//  ProtoUNDOTest
//
//  Created by Yury on 20/09/15.
//  Copyright © 2015 Yury. All rights reserved.
//

import Parse

import UIKit

class ActionsTableViewCell: BaseTableViewCell {

    @IBOutlet weak private var firstButton: AppDefaultButton!
    @IBOutlet weak private var secondButton: AppDefaultButton!
    var accessoryButton: AppDefaultButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryButton = accessoryView as! AppDefaultButton
        
        NSNotificationCenter.defaultCenter().addObserverForName( kLogObjectAddingNotification,
            object: nil,
            queue: NSOperationQueue.mainQueue())
            {
                (notification) -> Void in
                guard let event = notification.object as? LogEvent, item = event.item where item.type == self.item.type && item.type == "medicine" else { return }
                if self.item !== item {
                    self.item?.selectedActionIndex = nil
                } else if event.isCustomEvent {
                    self.item?.selectedActionIndex = 0
                } else if event.action == self.item.actions[0].actionID {
                    self.item?.selectedActionIndex = 1
                } else {
                    self.item?.selectedActionIndex = 2
                }
                self.updateSelection()
        }
    }

    var item : EventItem!{
        didSet {
            let actions = item.actions
            firstButton?.hidden = actions.count < 1
            secondButton?.hidden = actions.count < 2
            if actions.count > 0 {
                firstButton?.setTitle(actions[0].name, forState: .Normal)
            }
            if actions.count > 1 {
                secondButton?.setTitle(actions[1].name, forState: .Normal)
            }
            updateSelection()
        }
    }
    
    @IBAction func buttonOneTapped(sender: AppDefaultButton) {
        selected = true
        
        // Marko
        // check PF Login User
        let currUser = PFUser.currentUser()
        if currUser == nil {
            return
        }
        
        EventsManager.sharedManager.addEvent(LogEvent(item: item!, _action:0))
        
    }
    
    @IBAction func buttonTwoTapped(sender: AppDefaultButton) {
        selected = true
        EventsManager.sharedManager.addEvent(LogEvent(item: item!, _action:1))
    }
    
    func updateSelection() {
        accessoryButton.selected = (item!.selectedActionIndex == 0)
        firstButton.selected = (item!.selectedActionIndex == 1)
        secondButton.selected = (item!.selectedActionIndex == 2)
    }
    
    override func onAccessoryButtonTapped() {
        super.onAccessoryButtonTapped()
        viewController.onAccessoryButtonTapped(item!)
    }
}
