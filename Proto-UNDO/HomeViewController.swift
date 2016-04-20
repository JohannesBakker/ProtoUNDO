//
//  HomeViewController.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 25.07.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    // undo view
    @IBOutlet weak var undoView: UIView!
    @IBOutlet weak var undoEventLabel: UILabel!
    @IBOutlet weak var undoTimeLabel: UILabel!
    @IBOutlet weak var undoNoteLabel: UILabel!
    @IBOutlet weak var undoImageView: UIImageView!
    @IBOutlet weak var undoImageWidth: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    var memoInput:MemoInputViewController?  = nil
    var timer:NSTimer? = nil
    var lastMoreButton:BButton?
    var lastEvent:LogEvent?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"eventRemoved:", name: kLogObjectRemovedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"eventAdded:", name: kLogObjectAddedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"eventsChanged:", name: kEventsListChangedNotification, object: nil)
        
        tableView.registerNib(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: "eventCell")
        tableView.registerNib(UINib(nibName: "HomeValueCellTableViewCell", bundle: nil), forCellReuseIdentifier: "valueCell")
        tableView.registerNib(UINib(nibName: "MemoTableViewCell", bundle: nil), forCellReuseIdentifier: "memoCell")
        tableView.registerNib(UINib(nibName: "MultiActionTableViewCell", bundle: nil), forCellReuseIdentifier: "multiCell")
        
    }
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden=true;
        tableView.reloadData()
    }
    // MARK: table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataSource.sharedDataSouce.activeEvents.count+1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < DataSource.sharedDataSouce.activeEvents.count {
            let eventKey:String = DataSource.sharedDataSouce.activeEvents[indexPath.row]
            let dict:NSDictionary = kEvents[eventKey] as! NSDictionary
            // cell with value
            if (dict[kValueUsed]!.boolValue == true){
                let cell:HomeValueCellTableViewCell! = tableView.dequeueReusableCellWithIdentifier("valueCell") as! HomeValueCellTableViewCell
                cell!.loadDictionary(kEvents, key: eventKey)
                cell.actionTitle.removeTarget(nil, action: nil , forControlEvents: UIControlEvents.AllEvents)
                cell.actionTitle.addTarget(self, action: "logValueAction:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.actionTitle.parentCell = cell
                cell.detailButton.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
                cell.detailButton.addTarget(self, action: "detailAction:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.detailButton.parentCell = cell
                return cell!
            }
                //cell with memo
            else if ((dict[kInputEvent] != nil) && (dict[kInputEvent])!.boolValue == true) {
                let cell:MemoTableViewCell! = tableView.dequeueReusableCellWithIdentifier("memoCell") as! MemoTableViewCell
//                cell!.loadDictionary(kEvents, key: eventKey);
//                cell.detailButton.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
//                cell.detailButton.addTarget(self, action: "detailAction:", forControlEvents: UIControlEvents.TouchUpInside)
//                cell.detailButton.parentCell = cell
//                cell.typeHereButton.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
//                cell.typeHereButton.addTarget(self, action: "showInput:", forControlEvents: UIControlEvents.TouchUpInside)
//                cell.photoButton.removeTarget(nil, action: nil , forControlEvents: UIControlEvents.AllEvents)
//                cell.photoButton.addTarget(self, action: "showInput:", forControlEvents: UIControlEvents.TouchUpInside)
                
                return cell
            }
                // cell with multiply values and customizable
            else if (dict[kCustomizable] != nil || (dict[kCustomizable] != nil && dict[kCustomizable]!.boolValue == true)){
                let cell:MultiActionTableViewCell! = tableView.dequeueReusableCellWithIdentifier("multiCell") as! MultiActionTableViewCell
//                cell!.loadDictionary(kEvents, key: eventKey)
//                cell.addTargetForDetal(self, action:  "detailAction:", forControlEvents: UIControlEvents.TouchUpInside)
//                cell.addTargetForActions(self, action: "logMultiAction:", forControlEvents: UIControlEvents.TouchUpInside)
                
                return cell!
            }
            else {
                // ordinary even cell
                let cell:HomeTableViewCell! = tableView.dequeueReusableCellWithIdentifier("eventCell") as! HomeTableViewCell
                cell!.loadDictionary(kEvents, key: eventKey)
                cell.detailButton.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
                cell.detailButton.addTarget(self, action: "detailAction:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.addTargetForActions(self, action: "logSimpleAction:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.detailButton.parentCell = cell
                return cell!
            }
            
        }
        // customize cell
        let cell:UITableViewCell =  tableView.dequeueReusableCellWithIdentifier("menuCell")!
        let gr = UITapGestureRecognizer(target: self, action: "editEvents:")
        cell.contentView.gestureRecognizers?.removeAll()
        cell.contentView.addGestureRecognizer(gr)
        return cell
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row < DataSource.sharedDataSouce.activeEvents.count){
            let eventKey:String = DataSource.sharedDataSouce.activeEvents[indexPath.row]
            let dict:NSDictionary = kEvents[eventKey] as! NSDictionary
            
            if (dict[kCustomizable] != nil || (dict[kCustomizable] != nil && dict[kCustomizable]!.boolValue == true)){
                let _cell:MultiActionTableViewCell! = cell as! MultiActionTableViewCell
                _cell!.loadDictionary(kEvents, key: eventKey)
                _cell.addTargetForDetal(self, action:  "detailAction:", forControlEvents: UIControlEvents.TouchUpInside)
                _cell.addTargetForActions(self, action: "logMultiAction:", forControlEvents: UIControlEvents.TouchUpInside)
                
            }
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row < DataSource.sharedDataSouce.activeEvents.count {
            let eventKey:String = DataSource.sharedDataSouce.activeEvents[indexPath.row]
            let dict:NSDictionary = kEvents[eventKey] as! NSDictionary
            if (dict[kCustomizable] != nil || (dict[kCustomizable] != nil && dict[kCustomizable]!.boolValue == true)){
                return MultiActionTableViewCell().getHeightWithDictionary(dict)
            }
            else {
                return ProtoTableViewCell().getHeightWithDictionary(nil)
            }
        }
        return 60
    }
    @objc func eventsChanged(notitication:NSNotification){
        tableView.reloadData()
    }
    @objc func eventRemoved(notification:NSNotification){
//        let userInfo:Dictionary<String,Int!> = notification.userInfo as! Dictionary<String,Int!>
//        let index:Int = userInfo["index"]!
        self.view.userInteractionEnabled=true;
    }
    func incrementBadge(){
        var conts:[UIViewController] = self.tabBarController!.viewControllers!
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
        var conts:[UIViewController] = self.tabBarController!.viewControllers!
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
    var eventAddedInternaly = true
    func addLogEvent(event:LogEvent!){
        eventAddedInternaly = true
        DataSource.sharedDataSouce.logEvent(event, block: { (success, error) -> Void in
            if (success){

            }
            self.eventAddedInternaly=false
        })
        NSNotificationCenter.defaultCenter().postNotificationName(kEventCellChangedNotification, object: self)
    }
    @objc func timerEnds(timer:NSTimer){
        if (timer==self.timer){
            undoView.hidden=true
            self.timer=nil;
        }
    }
    @objc func eventAdded(notification:NSNotification){
        
        let userInfo:Dictionary<String,Int!> = notification.userInfo as! Dictionary<String,Int!>
        let index:Int = userInfo["index"]!
        if index>=0 {
            let event:LogEvent? = DataSource.sharedDataSouce.EventAtIndex(index)
            if (event != nil) {
                self.incrementBadge()
                if self.timer != nil {
                    self.timer?.invalidate()
                }
                self.timer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: "timerEnds:", userInfo: nil, repeats: false)
                setupUndoViewWithEvent(event!)
                if !eventAddedInternaly {
                    // show green box
                    if lastMoreButton != nil {
                    delay(0.35, closure: { () -> () in
                        self.lastMoreButton!.highlighted=true
                        delay(0.5, closure: { () -> () in
                            self.lastMoreButton!.highlighted=false
                            self.lastMoreButton = nil
                        })
                    })
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName(kEventCellChangedNotification, object: nil)
                }
            }
        }

    }
    func setupUndoViewWithEvent(event:LogEvent){
        undoTimeLabel.text = getTimeStringWithInterval(event.time)
        undoNoteLabel.text = event.note
        undoEventLabel.text = event.title()
        
        if (event.image != nil || event.imageFile != nil){
            event.getImage { (image, error) -> Void in
                self.undoImageView.image = image
                UIView.animateWithDuration(0.15, animations: { () -> Void in
                    self.undoImageWidth.constant=50
                    self.view.layoutSubviews()
                })
            }
        }else{
            self.undoImageWidth.constant=0
        }
        undoView.hidden=false
    }
    @IBAction func logValueAction(sender: BButton) {
        
        let cell:HomeValueCellTableViewCell = sender.parentCell as! HomeValueCellTableViewCell
        let value = cell.value
        
        if (value != 0.0 ){
            let type = cell.TypeName?.lowercaseString
            let desc: NSDictionary! = kEvents[type!] as! NSDictionary
            let actions: [String]? = desc[kActions] as? [String]
            addLogEvent(LogEvent(_type: type!, _action: actions!.first!, _value: value))
        }
        cell.value = 0
        cell.valueSlider.value = 0
        
        
    }

    @IBAction func logSimpleAction(sender: BButton) {
        let cell:HomeTableViewCell = sender.parentCell as! HomeTableViewCell
        let type = cell.TypeName?.lowercaseString
        let desc: NSDictionary! = kEvents[type!] as! NSDictionary
        let actions: [String]! = desc[kActions] as! [String]
        let actionIndex = cell.actionLabels.indexOf(sender)
        
        addLogEvent(LogEvent(_type: type!, _action: actions[actionIndex!]))
        
    }
    @IBAction func logMultiAction(sender: BButton) {
        let cell:MultiActionTableViewCell = sender.parentCell as! MultiActionTableViewCell
        let type = cell.TypeName?.lowercaseString
        let desc: NSDictionary! = kEvents[type!] as! NSDictionary
        let actions: [String]! = desc[kActions] as! [String]
        let actionIndex = cell.actionButtons.indexOf(sender)
        
        addLogEvent(LogEvent(_type: type!, _action: actions[actionIndex!]))
        
    }


    @IBAction func undoAction(sender: AnyObject) {
        
        DataSource.sharedDataSouce.deleteEventWithIndex(0)
        undoView.hidden=true;
        decrementBadge()
        if timer != nil {
            timer?.invalidate()
            self.timer=nil
        }
        self.view.userInteractionEnabled=false
    }
    @IBAction func showInput(sender: UIButton) {
        let tag = sender.tag
        if memoInput != nil {
            memoInput?.view.removeFromSuperview()
            memoInput = nil
        }
        memoInput  = MemoInputViewController(nibName: "MemoInputViewController", bundle: nil);
        memoInput!.loadView()
        memoInput!.viewDidLoad()
        let cell:UITableViewCell = sender.superview!.superview  as! UITableViewCell;
        var frame:CGRect = cell.frame
        //frame.origin =  cell.convertPoint(frame.origin, toView: self.view);
        frame.size.height = memoInput!.view.frame.size.height
        frame =  CGRectOffset(frame, -tableView.contentOffset.x, -tableView.contentOffset.y);
        frame =  CGRectOffset(frame, tableView.frame.origin.x, tableView.frame.origin.y + 13);
        memoInput!.view.frame = frame
        let window:UIWindow = UIApplication.sharedApplication().windows.first!
        // backgound view
        let bgView = UIView(frame: window.frame);
        bgView.backgroundColor = UIColor(white: 0.0, alpha: 0.5);
        let gr = UITapGestureRecognizer(target: memoInput!, action: "cancelAction:")
        bgView.addGestureRecognizer(gr)
        window.addSubview(bgView)
        window.addSubview(memoInput!.view)
        if (tag == 2){
            memoInput!.textField.becomeFirstResponder()
        }
        else {
            memoInput!.photoAction(sender)
        }
        memoInput!.backgroundView = bgView
    
        bgView.alpha = 0;
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            bgView.alpha = 0.5
        })
    }
    
    @IBAction func tapOutside(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(kEventsListChangedNotification, object: nil)
    }
    @IBAction func detailAction(sender: BButton) {
        eventAddedInternaly=false
        lastMoreButton = sender
//        let object:UIView? = sender.superview?.superview
        let cell:ProtoTableViewCell = sender.parentCell as! ProtoTableViewCell
        let desc: NSDictionary! = kEvents[cell.TypeName!] as! NSDictionary

        
        if (desc[kInputEvent] != nil && desc[kInputEvent]!.boolValue == true){
//            var value:Float = 0
            let segueName = "showMemo"
            lastEvent = LogEvent(_type: cell.TypeName!, _action:nil)
            self.performSegueWithIdentifier(segueName, sender: self)
        }
        else{
            let actions:[String] = desc[kActions] as! [String]
            var action = actions.first!
            let value:Float = 0
            var segueName = "showSimple"
            if (desc[kValueUsed] as! NSNumber).boolValue {
                segueName = "showValued"
            }
            let custom:NSNumber? = desc[kCustomizable] as? NSNumber
            if (custom != nil && custom!.boolValue == true) {
                segueName = "showMulti"
                action = actions[sender.tag]
            }
            lastEvent = LogEvent(_type: cell.TypeName!, _action: action, _value: value)
            self.performSegueWithIdentifier(segueName, sender: self)
        }
    }
    @IBAction func editEvents(sender: UIGestureRecognizer) {
        self.performSegueWithIdentifier("showCustomize", sender: self)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showValued" || segue.identifier == "showSimple" || segue.identifier == "showMemo" || segue.identifier == "showMulti" {
            eventAddedInternaly=false
            let  controller:EventDetailViewController = segue.destinationViewController as! EventDetailViewController
            controller.event = lastEvent!
        }
        if segue.identifier == "showCustomize" {

        }
    }

}

