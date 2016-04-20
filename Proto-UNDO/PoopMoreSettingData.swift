//
//  PoopMoreData.swift
//  PoopMore
//
//  Created by Lee Xiaoxiao on 9/26/15.
//  Copyright © 2015 Lee Xiaoxiao. All rights reserved.
//

import UIKit

class PoopMoreSettingData {
    
    var bIsNotJustNow:Bool = false
    var timePoop:NSDate? = NSDate.init()
    var bDisplayDescription:Bool = false
    
    var bIsSelectedStar:Bool = false
    var bIsSelectedExclamation:Bool = false
    
    enum PoopOptions:Int {
        case None = -1      // No select
        
        case Just = 0
        case Newborn = 1
        case Breastfed = 2
        case Formularfed = 3
        case Solidsfed = 4
        case Diarrhea = 5
    }
    
    var optPoop:PoopOptions! = .Just
    
    var strNoteText = ""    
    var memoImage : UIImage?
    
    
    init () {
    }
}
