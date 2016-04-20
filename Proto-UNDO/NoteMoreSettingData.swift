//
//  NoteMoreData.swift
//  NoteMore
//
//  Created by Curly Brackets on 9/26/15.
//  Copyright © 2015 Curly Brackets. All rights reserved.
//

import UIKit

class NoteMoreSettingData {
    
    var bIsNotJustNow:Bool = false
    var time:NSDate? = NSDate.init()
    var bDisplayDescription:Bool = false
    var bBabysitter:Bool = false
    var bDoctor:Bool = false
    
    var bIsSelectedStar:Bool = false
    var bIsSelectedExclamation:Bool = false
    
    var strNoteText = ""
    
    var memoImage : UIImage?
    
    init () {
    }
}
