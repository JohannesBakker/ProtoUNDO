//
//  UIViewBorderSet.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 25.07.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import UIKit

func setBorderForView(view:UIView, color:UIColor, width:CGFloat, radius:CGFloat){
    view.layer.borderColor = color.CGColor
    view.layer.borderWidth = width
    view.layer.cornerRadius = radius
    view.layer.masksToBounds = true
    
}