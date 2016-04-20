//
//  DataSource.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 27.07.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//
import Parse
import Foundation


typealias BooleanResultBlock = (Bool, NSError?) -> Void
typealias DictionaryResultBlock = ([String: String]?, NSError?) -> Void

let kLogObjectAddingNotification = "log_object_adding"
let kLogObjectAddedNotification = "log_object_added"
let kLogObjectRemovedNotification = "log_object_removed"
let kLogObjectUpdatedNotification = "log_object_updated"
let kEventsListChangedNotification = "kEventsListChangedNotification"
let kLog = "event_log"
let kUser = "user"
let kUserName = "username"
let kPassword = "password"
let kTime = "time"
enum EventSortOrder : Int{
    case TimeDescending = 0
    case TimeAscending = 1
    case Updated = 2
}
// MARK: helpers functions
// TODO: move to dedicated file
func getTimeStringWithInterval(timeInterval:NSTimeInterval) -> String{
    let date:NSDate = NSDate(timeIntervalSinceReferenceDate: timeInterval)
    let formater = NSDateFormatter()
    formater.timeStyle = NSDateFormatterStyle.ShortStyle
    formater.dateStyle = NSDateFormatterStyle.NoStyle
    return formater.stringFromDate(date).lowercaseString
}
func getAgoStringWithInterval(timeInterval:NSTimeInterval) -> String?{
    let agoInterval:CFAbsoluteTime = fabs(CFAbsoluteTimeGetCurrent() - timeInterval)
    let dayInterval:CFAbsoluteTime = 60*60*24
    if (agoInterval < dayInterval) {
        return getTimeStringWithInterval(timeInterval)
    }
    if (agoInterval < 2.0 * dayInterval){
        return "yesterday"
    }
    if (agoInterval < 8.0 * dayInterval) {
        let days = Int(floor(agoInterval / dayInterval))
        return "\(days) days ago"
    }
    let date:NSDate = NSDate(timeIntervalSinceReferenceDate: timeInterval)
    let formater = NSDateFormatter()
    formater.timeStyle = NSDateFormatterStyle.NoStyle
    formater.dateStyle = NSDateFormatterStyle.ShortStyle
    return formater.stringFromDate(date).lowercaseString
}
func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}
func UIColorFromRGB(rgbValue:Int32) -> UIColor
{
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >>  8) / 255.0,
        blue: CGFloat((rgbValue & 0x0000FF) >>  0) / 255.0,
        alpha: 1)
}

class DataSource {
    static let sharedDataSouce = DataSource()
    var currentUser:String?
    var loggedIn:Bool = false
    var eventsLog:[LogEvent] = []
    var dataLoaded:Bool = false
    var loading:Bool = false
    var maximumCount:Int = 0
    var loadPageSize:Int = 5
    var sortOrder:EventSortOrder = .TimeDescending
    /// metadata
    /// event's kinds what selected
    var activeEvents:[String] = []
    /// event's kinds
    var allEvents:[String] = []
    
    init () {
        currentUser = NSUserDefaults.standardUserDefaults().stringForKey(kUserName)
        initEvents()
        if (currentUser == nil){
            currentUser = CFUUIDCreateString(kCFAllocatorDefault, CFUUIDCreate(kCFAllocatorDefault)) as String
            let password =  CFUUIDCreateString(kCFAllocatorDefault, CFUUIDCreate(kCFAllocatorDefault)) as String
            let user:PFUser = PFUser()
            user.username = currentUser
            user.password = password
            user.signUpInBackgroundWithBlock({ (success,  error) -> Void in
                if (success==true){
                    NSUserDefaults.standardUserDefaults().setObject(self.currentUser, forKey: kUserName)
                    NSUserDefaults.standardUserDefaults().setObject(password, forKey: kPassword)
                    NSUserDefaults.standardUserDefaults().synchronize()
                    self.login()
                }
                else{
                    NSLog("Error signup:%@", error!)
                }
            })
        }
        else{
            login()
        }
    }
    func login(){
        let password = NSUserDefaults.standardUserDefaults().stringForKey(kPassword)
        PFUser.logInWithUsernameInBackground(currentUser!, password: password!) { (user, error) -> Void in
            if (user != nil && error == nil){
                self.loggedIn=true
                if (!self.dataLoaded) {
                   self.loadData(self.loadPageSize)
                }
            }
            else if (error != nil){
                 NSLog("Error login:%@", error!)
            }
        }
    }
    func queryForData() ->PFQuery{
        let query = PFQuery(className: kLog)
        query.whereKey(kUser, equalTo: PFUser.currentUser()!)
        switch sortOrder{
        case .TimeDescending:
            query.orderByDescending("time")
        case .TimeAscending:
            query.orderByAscending("time")
        case .Updated:
            query.orderByDescending("updatedAt")
        }
        return query
    }
    func reloadData(){
        if (loading){
            return
        }
        var count = self.eventsLog.count
        if count < loadPageSize {
            count = loadPageSize
        }
        self.eventsLog.removeAll(keepCapacity: true)
        loadData(count)
    }
    func loadData(count:Int){
        if loading {
            return
        }
        if loggedIn{
            loading=true
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                let query = self.queryForData()
                self.maximumCount =  query.countObjects()
                if (self.maximumCount > 0){
                    let q = self.queryForData()
                    q.limit = count
                    q.skip = self.eventsLog.count
                    let objects:[PFObject]? = q.findObjects() as? [PFObject]
                    if (objects != nil){
                        self.fillDataFromArray(objects!)
                    }
                }
                self.dataLoaded=true
                // need update controls
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let indexDict: Dictionary<String,Int>! = [
                        "index": -1,
                    ]
                    NSNotificationCenter.defaultCenter().postNotificationName(kLogObjectAddedNotification, object: nil, userInfo: indexDict)
                })
                self.loading=false;
            })
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                LogEvent.loadCustomLabels()
            })

        }
    }
    func fillDataFromArray(array:NSArray){
        for object in array{
            eventsLog.append(LogEvent(eventObject: object as! PFObject) )
        }
    }

     func logEvent(event:LogEvent ,block:BooleanResultBlock?){
        let eventObject = event.getParseEvent();
        
        eventObject[kUser] = PFUser.currentUser()
        eventObject.saveInBackgroundWithBlock { (success, error) -> Void in
            if (success){
                event.objectId = eventObject.objectId
                self.eventsLog.insert(event, atIndex: 0)
                let indexDict: Dictionary<String,Int>! = [
                    "index": 0,
                ]
                
            // Jacenty added 20151019
            ////////////////////////////////////
//            if fileManager.fileExistsAtPath(path: logFileURL.)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let outStream = NSOutputStream(URL: logFileURL!, append: true)
                    var csvString = event.toCSVRecordString()
                    csvString += "\n"
                    let data: NSData = csvString.dataUsingEncoding(NSUTF8StringEncoding)!
                    outStream!.open()
                    let w = outStream!.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
                    //            outStream!.write("\n", maxLength:1)
                    outStream!.close()
                    print(csvString)
                    
                })
            
            ////////////////////////////////////
                
            NSNotificationCenter.defaultCenter().postNotificationName(kLogObjectAddedNotification, object: nil, userInfo: indexDict)
                
                if eventObject[kImage] != nil{
                    let file:PFFile = eventObject[kImage] as! PFFile
                    file.saveInBackgroundWithBlock(nil)
                }
            
            }
            block?(success,error)
        }
    }
    
    func updateEventWithIndex(index:Int, logEvent:LogEvent!){
        if (eventsLog.count>0){
            let object:LogEvent? = EventAtIndex(index)
            
            eventsLog.removeAtIndex(index)
            eventsLog.insert(logEvent!, atIndex: index)
            
            if (object != nil){
                let query = PFQuery(className: kLog)
                let objectId:String? = object!.objectId
                if objectId != nil {
                    query.getObjectInBackgroundWithId(objectId!, block: { (pobject:PFObject?, error:NSError?) -> Void in

                        if (pobject != nil){
                            pobject?[kTime] = NSDate(timeIntervalSinceReferenceDate: logEvent.time)
                           
                            if logEvent.noteTime == nil {
                                pobject?[kNoteDate] = NSDate()
                            }
                            else {
                                 pobject?[kNoteDate] = logEvent.noteTime
                            }
                            
                            pobject?[kStarMark] = NSNumber(bool: logEvent.starMark)
                            pobject?[kExclamationMark] = NSNumber(bool: logEvent.exclamationMark)
                            pobject?[kBabySitterMark] = NSNumber(bool: logEvent.babyMark)
                            pobject?[kDoctorMark] = NSNumber(bool: logEvent.doctorMark)
                            pobject?[kIsJustNow] = NSNumber(bool: logEvent.bIsJustNow)
                            pobject?[kNote] = logEvent.note
                            pobject?[kValue] = logEvent.value
                            
                            
                            // Marko
                            pobject?[kActionType] = logEvent.action

                            pobject?[kDisplayDescription] = NSNumber(bool: logEvent.displayDesc)
                            
                            if logEvent.timeLeft != nil {
                                pobject?[kTimeLeft] = NSDate(timeInterval: 0, sinceDate: logEvent.timeLeft!)
                            }
                            
                            if logEvent.timeRight != nil {
                                pobject?[kTimeRight] = NSDate(timeInterval: 0, sinceDate: logEvent.timeRight!)
                            }
                            
                            if logEvent.leftHours != nil {
                                pobject?[kLeftHours] = logEvent.leftHours
                            }
                            
                            if logEvent.leftHours != nil {
                                pobject?[kLeftMins] = logEvent.leftMins
                            }
                            
                            if logEvent.rightHours != nil {
                                pobject?[kRightHours] = logEvent.rightHours
                            }
                            
                            if logEvent.rightMins != nil {
                                pobject?[kRightMins] = logEvent.rightMins
                            }
                            
                            if logEvent.optValue != nil {
                                pobject?[koptValue] = logEvent.optValue
                            }
                            
                            if logEvent.detailName != nil {
                                pobject?[kDetailName] = logEvent.detailName
                            }
                            
                            if logEvent.detailAnalogy != nil {
                                pobject?[kDetailAnalogy] = logEvent.detailAnalogy
                            }

                            if logEvent.detailColor != nil {
                                pobject?[kDetailColor] = logEvent.detailColor
                            }

                            if logEvent.detailTexture != nil {
                                pobject?[kDetailTexture] = logEvent.detailTexture
                            }
                            
                            if logEvent.detailStink != nil {
                                pobject?[kDetailStink] = logEvent.detailStink
                            }
                            
                            if logEvent.image != nil{
                                let file = PFFile(data: UIImageJPEGRepresentation(logEvent.image!, 0.5)!, contentType: "image/jpeg")
                                pobject?[kImage] = file
                            }                            
                            
                            pobject?.saveInBackgroundWithBlock({ (success, error) -> Void in
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    NSNotificationCenter.defaultCenter().postNotificationName(kLogObjectUpdatedNotification, object: nil, userInfo: nil)
                                })
                            })
                        }
                    })
                }
            }
        }
    }

    
    func deleteLastEvent(){
        deleteEventWithIndex(0)
    }
    func deleteEventWithIndex(index:Int){
        if (eventsLog.count>0){
            let object:LogEvent? = EventAtIndex(index)
            if (object != nil){
                let query = PFQuery(className: kLog)
                let objectId:String? = object!.objectId
                if objectId != nil {
                    query.getObjectInBackgroundWithId(objectId!, block: { (pobject:PFObject?, error:NSError?) -> Void in
                        if (pobject != nil){
                            pobject?.deleteInBackgroundWithBlock({ (success, error) -> Void in
                                // negative index for unsuccessed deletion
                                let indexDict: Dictionary<String,Int>! = [
                                    "index": success == true ? index : -1,
                                ]
                                if success {
                                    if self.eventsLog.count > 0
                                    {
                                        self.eventsLog.removeAtIndex(index)
                                    }
                                }
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    NSNotificationCenter.defaultCenter().postNotificationName(kLogObjectRemovedNotification, object: nil, userInfo: indexDict)
                                })
                            })
                        }
                    })
                }
                else{
                    let indexDict: Dictionary<String,Int>! = [
                        "index":  -1,
                    ]
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        NSNotificationCenter.defaultCenter().postNotificationName(kLogObjectRemovedNotification, object: nil, userInfo: indexDict)
                    })
                }
            }
        }
    }
    func count () -> Int {
        if !dataLoaded {
            loadData(loadPageSize)
        }
        return eventsLog.count
    }
    func EventAtIndex(index:Int) -> LogEvent?{
        if loggedIn{
            if eventsLog.count > index{
               return eventsLog[index]; 
            }
        }
        if !dataLoaded{
            loadData(loadPageSize)
        }
        return nil
    }
    func canLoadMore() -> Bool{
        return eventsLog.count<maximumCount
    }
    /// events type support
    func initEvents(){
        allEvents  = [String](count: kEvents.count, repeatedValue: "")
        for (key, dict) in kEvents {
            let d = dict as! [String: AnyObject]
            let n = d[kOrder] as! NSNumber
            let index = n.integerValue
            //let index:NSNumber = dict[kOrder] as! NSNumber
            allEvents[index] = key as! String

        }
        updateActiveEvents()

        
    }
    func updateActiveEvents(){
        activeEvents = [String]()
        for key in allEvents {
            let udKey = "NoEvent_\(key)"
            let ovalue:NSNumber? = NSUserDefaults.standardUserDefaults().objectForKey(udKey) as? NSNumber
            if  ovalue != nil {
                if ovalue!.boolValue == true{
                    activeEvents.append(key)
                }
            }
            else {
                activeEvents.append(key)
            }
        }
    }
    func setEventWithIndexActive(index:Int, active:Bool){
        let udKey = "NoEvent_\(allEvents[index])"
        NSUserDefaults.standardUserDefaults().setBool(active, forKey: udKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        updateActiveEvents()
    }
    func isEventIndexActive(index:Int) -> Bool{
        let udKey = "NoEvent_\(allEvents[index])"
        let ovalue:NSNumber? = NSUserDefaults.standardUserDefaults().objectForKey(udKey) as? NSNumber
        if  ovalue != nil {
            if ovalue!.boolValue == true{
                return true
            }
        }
        else {
            return true
        }
        return false
    }
    //MARK: custom labels
    func getCustomLabels(block:DictionaryResultBlock?){
        let query = PFQuery(className: kActions)
        query.whereKey(kUser, equalTo: PFUser.currentUser()!)
        query.getFirstObjectInBackgroundWithBlock { (actions:PFObject?, error:NSError?) -> Void in
            if (error == nil && actions != nil){
                let excludeKeys:[String] = ["objectId",kUser,"createdAll","ACL"]
                let keys:[String] = (actions?.allKeys()) as! [String]
                var effectiveKeys:[String] = []
                // stripe keys
                for key in keys{
                    if excludeKeys.contains(key) == false {
                        effectiveKeys.append(key)
                    }
                }
                if !effectiveKeys.isEmpty{
                    var result:[String:String] = [String:String]()
                    for key in effectiveKeys {
                        let value:String? = actions?.valueForKey(key) as? String
                        if value != nil {
                            result[key] = value!
                        }
                    }
                    if (result.count>0 && block != nil){
                        block! (result,nil)
                    }
                }
                else{
                    if (block != nil){
                        block!(nil,nil)
                    }
                }
                
               
            }
            else {
                if (block != nil){
                    block!(nil,error)
                }
                
            }
        }
    }
    func saveCustomLabels(labels:[String:String]!){
        let query = PFQuery(className: kActions)
        query.whereKey(kUser, equalTo: PFUser.currentUser()!)
        query.getFirstObjectInBackgroundWithBlock { (object:PFObject?, error:NSError?) -> Void in
            if ((error !=  nil && error!.code == 101) || (error == nil)){
                var outObject:PFObject? = object
                if (outObject == nil) {
                    outObject = PFObject(className: kActions)
                    outObject?.setObject(PFUser.currentUser() as! AnyObject, forKey: kUser)
                }
                for (key,label) in labels {
                    outObject?.setObject(label as String, forKey: key)
                }
                outObject?.saveInBackgroundWithBlock(nil)
            }
        }
    }
    func saveCustomLabel(label:String, forKey key:String){
        let query = PFQuery(className: kActions)
        query.whereKey(kUser, equalTo: PFUser.currentUser()!)
        query.getFirstObjectInBackgroundWithBlock { (object:PFObject?, error:NSError?) -> Void in
            if ((error !=  nil && error!.code == 101) || (error == nil)){
                var outObject:PFObject? = object
                if (outObject == nil) {
                    outObject = PFObject(className: kActions)
                    outObject?.setObject(PFUser.currentUser() as! AnyObject, forKey: kUser)
                }
                
                outObject?.setObject(label as String, forKey: key)
                
                outObject?.saveInBackgroundWithBlock(nil)
            }
        }
    }
    

}

