//
//  SelectViewController.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 13.08.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import UIKit

class CustomizeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightOfTable: NSLayoutConstraint!
    var prevState:[Bool] = []
    var changed:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        for var i = 0; i < DataSource.sharedDataSouce.allEvents.count; i++ {
            prevState.append(DataSource.sharedDataSouce.isEventIndexActive(i))
        }
        var tableHeight:CGFloat =  44 * CGFloat( DataSource.sharedDataSouce.allEvents.count)
        if (tableHeight > self.view.frame.size.height){
            tableHeight = self.view.frame.size.height
        }
        else {
            tableView.scrollEnabled = false
        }
        heightOfTable.constant = tableHeight
        saveButton.enabled = false
        
        
        self.view.setNeedsUpdateConstraints()
        self.view.updateConstraints()
        
//        var saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveAction:")
//        navigationItem.rightBarButtonItem = saveButton
//        
//        var backButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Done, target: self, action: "back:")
//        navigationItem.leftBarButtonItem = backButton
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //let window:UIWindow = UIApplication.sharedApplication().keyWindow!
        //self.backgroundImage.image = window.getBlur()
        tableView.reloadData()
    }
    @IBAction func saveAction(sender: AnyObject) {

        NSLog("save");
        DataSource.sharedDataSouce.updateActiveEvents()
        self.back(sender)
    
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(kEventsListChangedNotification, object: nil)
        })
    }
    @IBAction func back(sender: AnyObject) {
        if !changed {
            
            for var i = 0; i < DataSource.sharedDataSouce.allEvents.count; i++ {
                DataSource.sharedDataSouce.setEventWithIndexActive(i, active: prevState[i])
            }
            DataSource.sharedDataSouce.updateActiveEvents()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else{
            self.dismissViewControllerAnimated(true, completion: nil)
            /*
            let confirm = UIActionSheet(title: "Are you sure to \"Cancel\"?\nThe event will be deleted", delegate: self, cancelButtonTitle: "No, don't delete", destructiveButtonTitle: "Yes, cancel and delete")
            confirm.tag = 100
            confirm.showInView(self.view)
            */
            //confirm.showFromBarButtonItem(navigationItem.leftBarButtonItem, animated: true)
        }
    }
    var titleForCustomize:String? = nil
    @IBAction func renameAction(sender: UIButton) {
        titleForCustomize = sender.titleForState(UIControlState.Disabled)
        self.performSegueWithIdentifier("renamePopover", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "renamePopover"){
            let controller:CustomActionsViewController = segue.destinationViewController as! CustomActionsViewController
            controller.type = titleForCustomize!
        }
    }

    //MARK: table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataSource.sharedDataSouce.allEvents.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("selectCell")!
        let button:UIButton = cell.contentView.viewWithTag(1) as! UIButton
        let title:String = DataSource.sharedDataSouce.allEvents[indexPath.row]
        button.setTitle(title.capitalizedString, forState: UIControlState.Normal)
        button.selected = DataSource.sharedDataSouce.isEventIndexActive(indexPath.row)
        
        button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Selected)
        
        let renameButton:UIButton = cell.contentView.viewWithTag(2) as! UIButton
        
        let eventDict:NSDictionary! = kEvents[title] as! NSDictionary
        let customizable:NSNumber? = eventDict[kCustomizable] as? NSNumber
        
        if (customizable != nil && customizable!.boolValue){
            renameButton.hidden = false
            renameButton.removeTarget(nil, action:nil, forControlEvents: UIControlEvents.AllEvents);
            renameButton.addTarget(self, action: "renameAction:", forControlEvents: UIControlEvents.TouchUpInside)
            renameButton.setTitle(title, forState: UIControlState.Disabled)
            if LogEvent.isEventCustomized(title){
                button.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
                button.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Selected)
            }
            
        }
        else{
            renameButton.hidden = true

        }
        return cell
    }
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        changed = true
        saveButton.enabled = true
        cancelButton?.tintColor = UIColor.redColor()
        let value = !DataSource.sharedDataSouce.isEventIndexActive(indexPath.row)
        DataSource.sharedDataSouce.setEventWithIndexActive(indexPath.row, active: value)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
        return indexPath
    }

}
