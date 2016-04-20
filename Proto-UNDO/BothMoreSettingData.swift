//
//  BothMoreData.swift
//  BothMore
//
//  Created by Lee Xiaoxiao on 9/26/15.
//  Copyright © 2015 Lee Xiaoxiao. All rights reserved.
//

import UIKit

class BothMoreSettingData {
    
    var bIsNotJustNow:Bool = false
    var timeLeft:NSDate? = NSDate.init()
    var timeRight:NSDate? = NSDate.init()
    var bDisplayDescription:Bool = false

    var nLeftDurationHours:Int = 0
    var nLeftDurationMinutes:Int = 0
    var nRightDurationHours:Int = 0
    var nRightDurationMinutes:Int = 0
    
    var bIsSelectedStar:Bool = false
    var bIsSelectedExclamation:Bool = false
    
    var strNoteText = ""
    var breastImage : UIImage?
    
    enum BreastActions: Int {
        case ActLeft    = 1
        case ActRight   = 2
        case ActBoth    = 3
    }
    
    var optAction:BreastActions! = .ActLeft
    
    init () {
    }
}
