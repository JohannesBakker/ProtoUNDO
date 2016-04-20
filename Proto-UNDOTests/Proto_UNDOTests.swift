//
//  Proto_UNDOTests.swift
//  Proto-UNDOTests
//
//  Created by Vlad Konon on 25.07.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import UIKit
import XCTest
import Parse
class Proto_UNDOTests: XCTestCase {
    var downloadComplete:Bool = false
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testEventInit(){
        var event:LogEvent  = LogEvent()
        for (key,value) in kEvents{
            let dict:NSDictionary = value as! NSDictionary
            let actions:[String]? = dict[kActions] as? [String]
            if (actions != nil) { // test for actions
                for action in actions!{
                    event = LogEvent(_type: key as! String, _action: action, _value: 10, _time: 101)
                    XCTAssert(event.type == key as! String && event.action == action && event.value == 10 && event.time == 101, "\(key) passed")
                }
            }
            else{
                // test input
                let input:NSNumber? = dict[kInputEvent] as? NSNumber
                if (input != nil){
                    event = LogEvent(_type: key as! String, _action: nil, _value: 0, _time: 101)
                    event.note = "note"
                    XCTAssert(event.type == (key as! String) && event.action == kUndefined && event.note == "note" && event.time == 101, "\(key) passed")
                }
            }
            
        }
    }
    func testParseFromEvent(){
        var event:LogEvent  = LogEvent()
        for (key,value) in kEvents{
            let dict:NSDictionary = value as! NSDictionary
            let actions:[String]? = dict[kActions] as? [String]
            if (actions != nil) { // test for actions
                for action in actions!{
                    event = LogEvent(_type: key as! String, _action: action, _value: 10, _time: 101)
                    event.starMark = true
                    event.exclamationMark = true
                    event.note = "note"
                    let eventObject = event.getParseEvent()
                    XCTAssert(eventObject[kType]!.isEqualToString(key as! String), "type \(key) parse passed")
                    XCTAssert(eventObject[kTime]!.isEqualToDate(NSDate(timeIntervalSinceReferenceDate: 101)), "date parse passed")
                    XCTAssert(eventObject[kNote]!.isEqualToString("note"), "note parse passed")
                    XCTAssert(eventObject[kStarMark]!.isEqual(true as NSNumber), "Star parse passed")
                    XCTAssert(eventObject[kExclamationMark]!.isEqual(true as NSNumber), "Exclamation parse passed")
                    if dict[kValueUsed]!.boolValue == true{
                        XCTAssert(eventObject[kValue]!.isEqual(10 as NSNumber), "value parse passed")
                    }
                }
            }
            
        }
    }
    
    func testAddEvent() {
        var result:Bool = false
       let theRL:NSRunLoop = NSRunLoop.currentRunLoop()
        while (DataSource.sharedDataSouce.dataLoaded == false && theRL.runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture() )){
            
        }
        let key: String! = kEvents.allKeys.first as! String
        let dict:NSDictionary = kEvents[key] as! NSDictionary
        let actions:[String] = (dict[kActions] as? [String])!
        let event:LogEvent = LogEvent(_type: key, _action: actions.first!, _value: 10, _time: 101)
        DataSource.sharedDataSouce.logEvent(event, block: { (success, error) -> Void in
            if (success){
                result = true
            }
            self.downloadComplete=true
        })
        // Begin a run loop terminated when the downloadComplete it set to true
        while (downloadComplete == false && theRL.runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture() )){
        
        }
        XCTAssert(result, "Adding passed")
    }

    func testDeleteEvent() {
        var result:Bool = false
        let theRL:NSRunLoop = NSRunLoop.currentRunLoop()
        while (DataSource.sharedDataSouce.dataLoaded == false && theRL.runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture() )){
            
        }
        let startCount:Int = DataSource.sharedDataSouce.count()
        if startCount>0{
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "deleteDone:", name: kLogObjectRemovedNotification, object: nil)
            DataSource.sharedDataSouce.deleteEventWithIndex(0)
        }
        else{
            XCTAssert(false, "not added any event")
            return
        }
        DataSource.sharedDataSouce.deleteEventWithIndex(0)
        // Begin a run loop terminated when the downloadComplete it set to true
        while (downloadComplete == false && theRL.runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture() )){
            
        }
        result = startCount == DataSource.sharedDataSouce.count()+1
        
        XCTAssert(result, "Adding passed")
    }
    @objc func deleteDone (notification:NSNotification){
        downloadComplete=true
    }
    func testAgo(){
        let now = CFAbsoluteTimeGetCurrent()
        let day:CFAbsoluteTime = 60*60*24
        
        XCTAssert(getAgoStringWithInterval(now) == nil, "now passed")
        XCTAssert(getAgoStringWithInterval(now - day) == "yesterday", "yesterday passed")
        for var i = 2; i < 8; i++
        {
            XCTAssert(getAgoStringWithInterval(now - (Double(i)*day)) == "\(i) days ago", "\(i) days passed")
        }
        let date:NSDate = NSDate(timeIntervalSinceReferenceDate: now - (8.0 * day))
        let formater = NSDateFormatter()
        formater.timeStyle = NSDateFormatterStyle.NoStyle
        formater.dateStyle = NSDateFormatterStyle.ShortStyle
        let str =  formater.stringFromDate(date).lowercaseString
        
        XCTAssert(getAgoStringWithInterval(now - (8.0 * day)) == str, "\(str) passed")
    }

}
