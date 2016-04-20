//
//  PeeMoreData.swift
//  PeeMore
//
//  Created by Lee Xiaoxiao on 9/26/15.
//  Copyright © 2015 Lee Xiaoxiao. All rights reserved.
//

import UIKit

class PeeMoreSettingData {
    
    var bIsNotJustNow:Bool = false
    var timePee:NSDate? = NSDate.init()
    var bDisplayDescription:Bool = false
    
    var bIsSelectedStar:Bool = false
    var bIsSelectedExclamation:Bool = false
    
    enum PeeOptions:Int {
        case None = -1      // No select
        
        case Just = 0
        case Orange = 1
        case LighterOrange = 2
        case BrightYellowToOrange = 3
        case BrightLemony = 4
        case PaleYello = 5
    }
    
    var optPee:PeeOptions! = .Just
    
    var strNoteText = ""
    var memoImage : UIImage?
    
    init () {
    }
}
