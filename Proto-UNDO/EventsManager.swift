//
//  EventsManager.swift
//  Proto-UNDO
//
//  Created by Yury on 24/09/15.
//  Copyright © 2015 Curly Brackets. All rights reserved.
//

import Foundation
import UIKit

class EventsManager {
    var undoCount = 0
    var undoIgnoredCount = 0
    
    static let sharedManager = EventsManager()

    private init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"eventAdded:", name: kLogObjectAddedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"eventRemoved:", name: kLogObjectRemovedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"eventsChanged:", name: kEventsListChangedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"eventsChanged:", name: kLogObjectUpdatedNotification, object: nil)
    }
    
    // MARK: - Notifications
    @objc func eventAdded(notification:NSNotification) {
        let userInfo:Dictionary<String,Int!> = notification.userInfo as! Dictionary<String,Int!>
        let index:Int = userInfo["index"]!
        if index >= 0 {
            if let event = DataSource.sharedDataSouce.EventAtIndex(index) {
                incrementBadge()
                
                // Marko
                viewController.undoView.event = event
                viewController.undoView.hidden = false
                
                undoCount++
                delay(4){
                    self.undoCount--
                    self.undoIgnoredCount = max(self.undoIgnoredCount - 1, 0)
                    self.updateUndoView()
                }
            }
        }
    }
    
    @objc func eventRemoved(notification:NSNotification){
        decrementBadge()
        viewController.view.userInteractionEnabled = true;
    }
    
    @objc func eventsChanged(notitication:NSNotification){
        viewController.reloadData()
    }
    
    // MARK:
    func addEvent(event: LogEvent) {
        print("Event \(event.type), \(event.action)")
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kLogObjectAddingNotification, object: event))
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        DataSource.sharedDataSouce.logEvent(event, block: { (success, error) -> Void in
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            if (!success){
                let av = UIAlertView(title: "Error", message: "Error:\(error?.localizedDescription)", delegate: nil, cancelButtonTitle: "OK")
                av.show()
            }
        })
    }
    
    func updateUndoView() {
        // Marko
        viewController.undoView.hidden = (undoCount == undoIgnoredCount)
    }
    
    func undoLastEvent() {
        DataSource.sharedDataSouce.deleteEventWithIndex(0)
        undoIgnoredCount = undoCount
        updateUndoView()
        viewController.view.userInteractionEnabled = false
    }
    
    // Badge
    func incrementBadge(){
        guard let tabBarController = UIApplication.sharedApplication().keyWindow?.rootViewController as? UITabBarController else { return }
        var conts:[UIViewController] = tabBarController.viewControllers!
        let logs:UIViewController? = conts[1]
        let bage:String? = logs?.tabBarItem.badgeValue
        if bage==nil{
            logs?.tabBarItem.setCustomBadgeValue("1")
        }
        else{
            let num:Int = Int(bage!)! + 1
            logs?.tabBarItem.setCustomBadgeValue("\(num)")
        }
        
    }
    func decrementBadge(){
        guard let tabBarController = UIApplication.sharedApplication().keyWindow?.rootViewController as? UITabBarController else { return }
        var conts:[UIViewController] = tabBarController.viewControllers!
        let logs:UIViewController? = conts[1]
        let bage:String? = logs?.tabBarItem.badgeValue
        if bage==nil{
            return
        }
        else{
            let num:Int = Int(bage!)! - 1
            if num > 0 {
                logs?.tabBarItem.setCustomBadgeValue("\(num)")
            }
            else{
                logs?.tabBarItem.setCustomBadgeValue(nil)
            }
        }
    }
}