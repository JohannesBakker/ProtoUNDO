//
//  BarItemCustomBage.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 29.07.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import UIKit

let CUSTOM_BADGE_TAG = 99
let OFFSET = 0.6

extension UITabBarItem{

    func setCustomBadgeValue(value:String?)
    {
        
        let myAppFont:UIFont = UIFont.systemFontOfSize(11);
        let myAppFontColor = UIColor.whiteColor()
        let myAppBackColor:UIColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1)
        
        setCustomBadgeValue(value, font: myAppFont, color: myAppFontColor, backColor: myAppBackColor)
    }
    func setCustomBadgeValue(value:String?, font:UIFont, color:UIColor, backColor:UIColor)
    {
        self.badgeValue = value;
        let v:UIView = (self.valueForKey("view") as? UIView)!;
        
        
        
        
        for sv:UIView in v.subviews 
        {
            
            let str:String = NSStringFromClass(sv.classForCoder) as String;
            
            if(str == "_UIBadgeView")
            {
                for ssv:UIView in sv.subviews 
                {
                    // REMOVE PREVIOUS IF EXIST
                    if ssv.tag == CUSTOM_BADGE_TAG
                    {
                        ssv.removeFromSuperview();
                    }
                }
                if value != nil {
                    var frame:CGRect = sv.frame
                    frame.offsetInPlace(dx: frame.size.width*0.15, dy: frame.size.height*0.2)
                    frame.size.width = frame.size.width*0.85
                    frame.size.height = frame.size.height*0.85
                    sv.frame = frame
                    let l:UILabel = UILabel(frame: CGRectMake(-sv.frame.size.width*0.08, -sv.frame.size.height*0.13, sv.frame.size.width*1.2, sv.frame.size.height*1.2));
                    l.font = font
                    l.text = value
                    l.backgroundColor = backColor
                    l.textColor = color
                    l.textAlignment = NSTextAlignment.Center
                    
                    // Fix for border
                    sv.layer.borderWidth = 1;
                    sv.layer.borderColor = backColor.CGColor;
                    sv.layer.cornerRadius = sv.frame.size.height/2;
                    sv.layer.masksToBounds = true;
                    sv.backgroundColor = backColor
                    sv.addSubview(l)
                    l.tag = CUSTOM_BADGE_TAG;
                }
            }
        }
    }
}