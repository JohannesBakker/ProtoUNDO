//
//  LogEvent.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 03.08.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import Foundation
import Parse

let kValue = "value"
let kName = "name"
let kType = "type"
let kActionType = "action_type"
let kQuantity = "quantity"
let kStarMark = "star"
let kExclamationMark = "exclamation"

// added by Marko
let kBabySitterMark = "babysitter"
let kDoctorMark = "doctor"
let kIsJustNow = "isjustnow"
let kNoteDate = "notedate"

let kImage = "image"
let kNote = "note"
let kMemo = "memo"
let kActions = "actions"
let kActionDescription = "act_desc"
let kActionFullDescrition = "full_desc"
let kValueFormat = "value_format"
let kOrder = "order"
let kValueUsed = "value_used"
let kButtons = "buttons"
let kInput = "input"
let kInputEvent = "input_event"
let kCustomizable = "customizable"
let kUndefined = "undefined"
let kEvents:NSMutableDictionary = NSMutableDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Events", ofType: "plist")!)!
let kDisplayDescription = "display_desc"
let koptValue = "optvalue"
let kTimeLeft = "timeleft"
let kTimeRight = "timeright"
let kLeftHours = "lefthours"
let kLeftMins = "leftmins"
let kRightHours = "righthours"
let kRightMins = "rightmins"
let kDetailName = "detail_name"
let kDetailColor = "detail_color"
let kDetailTexture = "detail_texture"
let kDetailAnalogy = "detail_analogy"
let kDetailStink = "detail_stink"


class LogEvent: CSVExport {

    var item:EventItem? = nil
    var isCustomEvent = false
    var type:NSString = kUndefined
    var action:NSString = kUndefined
    var value:Float = 0.0
    var quantity: Int? = nil
    var time:NSTimeInterval = 0.0
    var parentMark: Bool = false
    var starMark:Bool = false
    var exclamationMark:Bool = false
    
    // added by Marko
    var babyMark:Bool = false
    var doctorMark:Bool = false
    var bIsJustNow:Bool = false
    var noteTime:NSDate? = nil
    
    var inputField:Bool = false
    var image:UIImage?
    var imageFile:PFFile?
    var note:String?
    
    var displayDesc:Bool = false
    var optValue:Int? = nil
    
    var timeLeft:NSDate? = nil
    var timeRight:NSDate? = nil
    var leftHours:Int? = nil
    var leftMins:Int? = nil
    var rightHours:Int? = nil
    var rightMins:Int? = nil
    
    var detailName:NSString? = nil
    var detailColor:NSString? = nil
    var detailTexture:NSString? = nil
    var detailAnalogy:NSString? = nil
    var detailStink:Int? = nil
    
    static var customLabels:[String:String] =  [String:String]()
    var objectId:String? // for parse referense
    
    var name:String {
        get {
            return type.capitalizedString
        }
    }
    
    init (){
        
    }
    

    static func loadCustomLabels(){
        let labels:[String:String]? = NSUserDefaults.standardUserDefaults().valueForKey(kActions) as? [String:String]
        if (labels != nil){
            self.customLabels = labels!
        }
        DataSource.sharedDataSouce.getCustomLabels { (plabels:[String : String]?, error:NSError?) -> Void in
            if (error == nil){
                if (labels != nil){
                    if (labels?.count > 0 && plabels == nil ){
                        /// save labels to parse
                        DataSource.sharedDataSouce.saveCustomLabels(labels)
                        self.customLabels = labels!
                    }
                    else if (plabels != nil){
                        // if we have more labels then at parse save it too
                        if (labels?.count > plabels?.count){
                            DataSource.sharedDataSouce.saveCustomLabels(labels)
                            self.customLabels = labels!
                        }
                    }
                }
                else{
                    if (plabels != nil){
                        // load this labels
                        self.customLabels = plabels!
                        NSUserDefaults.standardUserDefaults().setObject(plabels, forKey: kActions)
                        NSUserDefaults.standardUserDefaults().synchronize()
                    }
                }
            }
            NewDatasource.setCustomNames()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName(kEventsListChangedNotification, object: nil)
            })
        }
    }
    static func isActionCustom(action:String) -> Bool{

            if (LogEvent.customLabels.count>0){
                let value:String? = LogEvent.customLabels[action]
                if (value != nil) {
                    return true
                }
            }
        return false
    }
    static func isEventCustomized(type:String) -> Bool{
        let eventDict:NSDictionary! = kEvents[type] as! NSDictionary
        let customizable:NSNumber? = eventDict[kCustomizable] as? NSNumber
        
        if (customizable != nil && customizable!.boolValue){
            let intialLabels:[String] = eventDict[kActionDescription] as! [String]
            let actions:[String] = eventDict[kActions] as! [String]
            for var i = 0; i<intialLabels.count ; i++ {
                let action:String = actions[i] as String
                let saved:String? = LogEvent.customLabels[action]
                if (saved != nil){
                    let initial:String = intialLabels[i] as String
                    if (saved != initial) {
                        return true
                    }
                }
            }
        }
        return false
    }
    static func getActionName(type:String, action:String) -> String{
        if (LogEvent.customLabels.count>0){
            let value:String? = LogEvent.customLabels[action]
            if (value != nil) {
                return value!
            }
        }
        if (type != kUndefined){
            let eventDesc: NSDictionary? =  kEvents[type] as? NSDictionary
            if (eventDesc != nil){
                let actions: NSArray? = eventDesc![kActions as String] as? NSArray
                if (actions != nil){
                    let index:NSInteger =  actions!.indexOfObject(action)
                    if (index != NSNotFound){
                        let desc: NSArray? = eventDesc![kActionDescription as String] as? NSArray
                        if (desc != nil) {
                            return desc![index] as! String
                        }
                    }
                    else {
                        return type + " " + action
                    }
                }
            }
        }
        return kUndefined
    }
    
    convenience init(customItem: EventItem, _action:Int = 0, _value:Float = 0, _time:NSTimeInterval = CFAbsoluteTimeGetCurrent()){
        self.init(item: customItem, _action: _action, _value: _value, _time: _time)
        isCustomEvent = true
    }
    
    convenience init(item: EventItem, _action:Int = 0, _value:Float = 0, _time:NSTimeInterval = CFAbsoluteTimeGetCurrent()){
        self.init(_type: item.type, _action: item.actions[_action].actionID, _value: _value, _time: _time)
        self.item = item
    }
    
    init(_type:String, _action:String?, _value:Float = 0, _time:NSTimeInterval = CFAbsoluteTimeGetCurrent()){
        self.type = _type
        if (_action != nil){
            self.action = _action!
        }
        else {
            self.action = kUndefined
        }
        self.value = _value
        self.time = _time
    }
    func getParseEvent() -> PFObject{
        let eventObject = PFObject(className: kLog)
        objectId = eventObject.objectId
        if kEvents[type] != nil {
            eventObject[kTime] = NSDate(timeIntervalSinceReferenceDate: time)
            eventObject[kStarMark] = NSNumber(bool: starMark)
            eventObject[kExclamationMark] = NSNumber(bool: exclamationMark)
            eventObject[kType] = type
            eventObject[kActionType] = action
            
            // added by Marko
            eventObject[kBabySitterMark] = NSNumber(bool: babyMark)
            eventObject[kDoctorMark] = NSNumber(bool: doctorMark)
            eventObject[kIsJustNow] = NSNumber(bool: bIsJustNow)
            if noteTime != nil {
                eventObject[kNoteDate] = noteTime
            }
            
            if quantity != nil {
                eventObject[kQuantity] = quantity
            }
            if note != nil {
                eventObject[kNote] = note
            }
            let dict:NSDictionary! = kEvents[type]! as! NSDictionary
            if dict[kValueUsed]!.boolValue == true{
                eventObject[kValue] = NSNumber(float: value)
            }
            if image != nil{
                let file = PFFile(data: UIImageJPEGRepresentation(image!, 0.5)!, contentType: "image/jpeg")
                eventObject[kImage] = file
            }
            
            eventObject[kDisplayDescription] = NSNumber(bool: displayDesc)
            
            if optValue != nil {
                eventObject[koptValue] = optValue
            }
            
            if timeLeft != nil {
                eventObject[kTimeLeft] = timeLeft
            }
            
            if timeRight != nil {
                eventObject[kTimeRight] = timeRight
            }
            
            if leftHours != nil {
                eventObject[kLeftHours] = leftHours
            }
            
            if leftMins != nil {
                eventObject[kLeftMins] = leftMins
            }

            if rightHours != nil {
                eventObject[kRightHours] = rightHours
            }
            
            if rightMins != nil {
                eventObject[kRightMins] = rightMins
            }
            
            if detailName != nil {
                eventObject[kDetailName] = detailName
            }
            
            if detailColor != nil {
                eventObject[kDetailColor] = detailColor
            }
            
            if detailTexture != nil {
                eventObject[kDetailTexture] = detailTexture
            }
            
            if detailAnalogy != nil {
                eventObject[kDetailAnalogy] = detailAnalogy
            }
            
            if detailStink != nil {
                eventObject[kDetailStink] = detailStink
            }

            
        }
        return eventObject
    }
    init(eventObject:PFObject!){
        objectId = eventObject.objectId
        var _time:CFAbsoluteTime? = eventObject[kTime]?.timeIntervalSinceReferenceDate
        if _time == nil {
            _time = eventObject.updatedAt?.timeIntervalSinceReferenceDate
        }
        value = 0;
        time = _time!
        starMark = false
        let sm:NSNumber? = eventObject[kStarMark] as? NSNumber
        if sm != nil {
            starMark = sm!.boolValue
        }
        exclamationMark = false
        let em:NSNumber? = eventObject[kExclamationMark] as? NSNumber
        if em != nil {
            exclamationMark = em!.boolValue
        }
        
        // added by Marko
        babyMark = false
        let bm:NSNumber? = eventObject[kBabySitterMark] as? NSNumber
        if bm != nil {
            babyMark = bm!.boolValue
        }
        
        doctorMark = false
        let dm:NSNumber? = eventObject[kDoctorMark] as? NSNumber
        if dm != nil {
            doctorMark = dm!.boolValue
        }
        
        bIsJustNow = false
        if let jn = eventObject[kIsJustNow] as? NSNumber {
            bIsJustNow = jn.boolValue
        }
        
        
        noteTime = nil
        if let time = eventObject[kNoteDate] as? NSDate {
            noteTime = time
        }
        
        displayDesc = false
        let dd:NSNumber? = eventObject[kDisplayDescription] as? NSNumber
        if  dd != nil {
            displayDesc = dd!.boolValue
        }
        
        optValue = nil
        let szOptValue:NSNumber? = eventObject[koptValue] as? NSNumber
        if  szOptValue != nil {
            optValue = szOptValue!.integerValue
        }
        
        timeLeft = nil
        if let tmpTimeLeft = eventObject[kTimeLeft] as? NSDate {
            timeLeft = tmpTimeLeft
        }

        timeRight = nil
        if let tmpTimeRight = eventObject[kTimeRight] as? NSDate {
            timeRight = tmpTimeRight
        }
        
        leftHours = nil
        let szLeftHours:NSNumber? = eventObject[kLeftHours] as? NSNumber
        if  szLeftHours != nil {
            leftHours = szLeftHours!.integerValue
        }

        leftMins = nil
        let szLeftMins:NSNumber? = eventObject[kLeftMins] as? NSNumber
        if  szLeftMins != nil {
            leftMins = szLeftMins!.integerValue
        }
        
        rightHours = nil
        let szRightHours:NSNumber? = eventObject[kRightHours] as? NSNumber
        if  szRightHours != nil {
            rightHours = szRightHours!.integerValue
        }
        
        rightMins = nil
        let szRightMins:NSNumber? = eventObject[kRightMins] as? NSNumber
        if  szRightMins != nil {
            rightMins = szRightMins!.integerValue
        }
        
        detailName = nil
        let szDetailName:NSString? = eventObject[kDetailName] as? NSString
        if szDetailName != nil {
            detailName = szDetailName
        }
        
        detailColor = nil
        let szDetailColor:NSString? = eventObject[kDetailColor] as? NSString
        if szDetailColor != nil {
            detailColor = szDetailColor
        }
        
        detailTexture = nil
        let szDetailTexture:NSString? = eventObject[kDetailTexture] as? NSString
        if szDetailTexture != nil {
            detailTexture = szDetailTexture
        }
        
        detailAnalogy = nil
        let szDetailAnalogy:NSString? = eventObject[kDetailAnalogy] as? NSString
        if szDetailAnalogy != nil {
            detailAnalogy = szDetailAnalogy
        }
        
        detailStink = nil
        let nDetailStink:NSNumber? = eventObject[kDetailStink] as? NSNumber
        if  nDetailStink != nil {
            detailStink = nDetailStink!.integerValue
        }

        //////////////////////////////
        
        note = eventObject[kNote] as? String
        image = nil
        imageFile = eventObject[kImage] as? PFFile
        if (eventObject[kType] != nil){
            type = eventObject[kType] as! NSString
        }
        else{
            type = kUndefined
        }
        value = 0;
        if eventObject[kValue] != nil {
            value = (eventObject[kValue] as! NSNumber).floatValue
        }
        action = kUndefined
        if eventObject[kActionType] != nil {
            action = eventObject[kActionType] as! String
        }
        // setup input flag (for memo)
        inputField = false
        
        if kEvents[type] != nil {
            let info: NSDictionary =  kEvents[type] as! NSDictionary;
            if (info[kInputEvent] != nil){
                inputField = info[kInputEvent]!.boolValue
            }
        }
    }
    
    func getImage(block:(UIImage?, NSError?) -> Void){
        if image != nil{
            block(image,nil)
        }
        else if imageFile != nil{
//            let imf = imageFile!
            
            imageFile?.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if (error == nil && data != nil){
                    self.image = UIImage(data: data!)
                    block (self.image,nil)
                }
                else {
                    block (nil,error)
                }
            })
        }
        else {
            block(nil,nil)
        }
    }
    func title() -> String{
        var result = self.name
        if kEvents[type] != nil {
            let info:NSDictionary = kEvents[type] as! NSDictionary
            if info[kValueUsed]!.boolValue == true {
                if (value>0){
                    result = result + formatedValue()
                }
            }
            else if ((info[kInputEvent] != nil) && (info[kInputEvent])!.boolValue == true) {
                // do nothing
            }
            else{
                let indexOfAction = (info[kActions] as! [String]).indexOf(action as String)
                let fulldesc:[String]? = info[kActionFullDescrition] as? [String]
                if (fulldesc != nil && indexOfAction != nil){
                    result = fulldesc![indexOfAction!]
                }
                else{
//                    let desc:[String] = info[kActionDescription] as! [String]
//                    result = desc[indexOfAction!]
                    result = LogEvent.getActionName(type as String, action: action as String)
                }
            }
            
            // remove star/exclamation mark by Marko
            /*
            if starMark {
                result = result + " ★"
            }
            if exclamationMark {
                result = result + " !"
            }
	    */
        }
        return result
    }
    func formatedValue() -> String{
        var result:String = "\(value)"
        if kEvents[type] != nil {
            let info:NSDictionary = kEvents[type] as! NSDictionary
            if info[kValueUsed]!.boolValue == true {
                let value_formated = NSString(format: info[kValueFormat] as! NSString, Int(value))
                result =  (value_formated as String)
            }
        }
        return result

    }
    
    func subtitle() -> String
    {
        var result = self.name
        if kEvents[type] != nil {
            let info:NSDictionary = kEvents[type] as! NSDictionary
            if ((info[kInputEvent] != nil) && (info[kInputEvent])!.boolValue == true) {
                // do nothing
            }
            else
            {
                let indexOfAction = (info[kActions] as! [String]).indexOf(action as String)
                let fulldesc:[String]? = info[kActionFullDescrition] as? [String]
                if (fulldesc != nil && indexOfAction != nil){
                    result = fulldesc![indexOfAction!]
                }
                else{
                    //                    let desc:[String] = info[kActionDescription] as! [String]
                    //                    result = desc[indexOfAction!]
                    result = LogEvent.getActionName(type as String, action: action as String)
                }
            }
        }
        return result
    }
    
    
    ///////////////////////////////////////////////////////////////
    func toCSVFieldArray() ->[String]
    {
        var imageStringData = ""
        if let image = self.image
        {
            if let imageData = UIImagePNGRepresentation(image)
            {
                imageStringData = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            }
        }
        
        var csvArray : [String] = [
            isCustomEvent.description,
            (type as String),
            (action as String),
            value.description,  //Float = 0.0
            (quantity ?? 0).description, //Int? = nil
            time.description, //NSTimeInterval = 0.0
            parentMark.description, // Bool = false
            starMark.description, // Bool = false
            exclamationMark.description, // Bool = false
            
            // added by Marko
            babyMark.description,//Bool = false
            doctorMark.description,//Bool = false
            bIsJustNow.description,//Bool = false
            (noteTime?.description ?? ""),//NSDate? = nil
            
            inputField.description,//Bool = false
            
            imageStringData, //        image, + :UIImage?
            //        imageFile, + :PFFile?
            (note ?? ""),// :String?
            
            displayDesc.description,//:Bool = false
            (optValue?.description ?? ""),// :Int? = nil
            
            (timeLeft?.description ?? ""),// :NSDate? = nil
            (timeRight?.description ?? ""),// :NSDate? = nil
            (leftHours?.description ?? ""),// :Int? = nil
            (leftMins?.description ?? ""),// :Int? = nil
            (rightHours ?? 0).description,// :Int? = nil
            (rightMins ?? 0).description,// :Int? = nil
            (objectId ?? ""), // :String? // for parse referense
            name]
        
        if let eventItem = self.item
        {
            csvArray.appendContentsOf(eventItem.toCSVFieldArray())
        }
        return csvArray
    }
    
    func toCSVRecordString() ->String
    {
        let cvsArray = self.toCSVFieldArray()
        let comma = ","
        let csvString = cvsArray.joinWithSeparator(comma)
        return csvString
    }
    
    func timeString(hours: Int?, mins: Int?) ->String {
        var ret:String = ""
        var szMins:String = ""
        
        if hours != nil && hours > 0 {
            if hours == 1 {
                ret = String(format: "%d hr", hours!)
            }
            else {
                ret = String(format: "%d hrs", hours!)
            }
            
        }
        
        if mins != nil && mins > 0 {
            szMins = String(format: "%d min", mins!)
            
            if ret == "" {
                ret = szMins
            }
            else {
                ret = ret + " " + szMins
            }
        }
        
        return ret
    }
    
    func dateTimeString(timeInterval:NSTimeInterval) -> String {
        let selectedTime = NSDate(timeIntervalSinceReferenceDate: timeInterval)
        
        let dateFormatter = NSDateFormatter()
        var text : String = ""
        if NSCalendar.currentCalendar().isDateInToday(selectedTime) {
            dateFormatter.dateFormat = "h:mm a"
            text = "Today " + dateFormatter.stringFromDate(selectedTime)
//            text = dateFormatter.stringFromDate(selectedTime).lowercaseString
        }else if NSCalendar.currentCalendar().isDateInTomorrow(selectedTime) {
            dateFormatter.dateFormat = "h:mm a"
            text = "Tomorrow " + dateFormatter.stringFromDate(selectedTime).lowercaseString
        }else if NSCalendar.currentCalendar().isDateInYesterday(selectedTime) {
            dateFormatter.dateFormat = "h:mm a"
            text = "Yesterday " + dateFormatter.stringFromDate(selectedTime).lowercaseString
        }else {
            dateFormatter.dateFormat = "MM/dd/yy h:mm a"
            text = dateFormatter.stringFromDate(selectedTime).lowercaseString
        }
        return text
    }
    
    func dateTimeStringFromDate(selectedTime:NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        var text : String = ""
        if NSCalendar.currentCalendar().isDateInToday(selectedTime) {
            dateFormatter.dateFormat = "h:mm a"
            text = "Today " + dateFormatter.stringFromDate(selectedTime)
//            text = dateFormatter.stringFromDate(selectedTime).lowercaseString
        }else if NSCalendar.currentCalendar().isDateInTomorrow(selectedTime) {
            dateFormatter.dateFormat = "h:mm a"
            text = "Tomorrow " + dateFormatter.stringFromDate(selectedTime).lowercaseString
        }else if NSCalendar.currentCalendar().isDateInYesterday(selectedTime) {
            dateFormatter.dateFormat = "h:mm a"
            text = "Yesterday " + dateFormatter.stringFromDate(selectedTime).lowercaseString
        }else {
            dateFormatter.dateFormat = "MM/dd/yy h:mm a"
            text = dateFormatter.stringFromDate(selectedTime).lowercaseString
        }
        return text
    }
    
    func getDurationTimes() -> String {
        var szDuration:String = ""
        
        let szLeft = timeString(leftHours, mins: leftMins)
        let szRight = timeString(rightHours, mins: rightMins)
        
        if szLeft != "" && szRight == "" {
            szDuration = String(format:"L: %@", szLeft)
        } else if szLeft == "" && szRight != "" {
            szDuration = String(format:"R: %@", szRight)
        }
        else if szLeft != "" && szRight != "" {
            szDuration = String(format: "L: %@, R: %@", szLeft, szRight)
        }
        
        return szDuration
    }
    
    func getFullActionName() -> String {
        var szAction = subtitle()
        
        if type.isEqualToString("breast") {
            
            let szDuration = getDurationTimes()
            
            szAction = LogEvent.getActionName(type as String, action: action as String)
            
            if szDuration != "" {
                szAction = szAction + ","
            }
        }
        else if type.isEqualToString("pee") {
            if optValue != nil && optValue == PeeMoreSettingData.PeeOptions.None.rawValue {
                szAction = String(format: "%@", "Not Set")
            }
            else if detailName != nil {
                szAction = String(format: "%@", detailName!)
            }
        }
        else if type.isEqualToString("poop") {
            if optValue != nil && optValue == PoopMoreSettingData.PoopOptions.None.rawValue {
                szAction = String(format: "%@", "Not Set")
            }
            else if detailName != nil {
                szAction = String(format: "%@", detailName!)
            }
            else if action.isEqualToString("diarrhea") {
                optValue = PoopMoreSettingData.PoopOptions.Diarrhea.rawValue
                szAction = String(format: "%@", "Diarrhea")
                detailName = String(format: "%@", "Diarrhea")
            }
        }
        
        return szAction
    }
    
    
}