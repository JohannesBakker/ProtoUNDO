//
//  UndoView.swift
//  Proto-UNDO
//
//  Created by Admin on 10/17/15.
//  Copyright © 2015 Curly Brackets. All rights reserved.
//

import UIKit

class UndoView: UIView {
    
    var view: UIView!
    
   
    @IBOutlet weak var lblEvent: UILabel!
    @IBOutlet weak var lblAction: UILabel!
    @IBOutlet weak var lblActionExt: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    
    @IBOutlet weak var image_width: NSLayoutConstraint!
    @IBOutlet weak var star_width: NSLayoutConstraint!
    @IBOutlet weak var exclaim_width: NSLayoutConstraint!
    @IBOutlet weak var baby_width: NSLayoutConstraint!
    @IBOutlet weak var doctor_width: NSLayoutConstraint!
    
    @IBOutlet weak var image_right: NSLayoutConstraint!
    @IBOutlet weak var star_right: NSLayoutConstraint!
    @IBOutlet weak var exclaim_right: NSLayoutConstraint!
    @IBOutlet weak var baby_right: NSLayoutConstraint!
    @IBOutlet weak var doctor_right: NSLayoutConstraint!
    
    let kImageWidth:CGFloat = 15
    let kImageRight:CGFloat = 4
    
    
    var event: LogEvent? = nil {
        didSet {
            guard let event = event else { return }
            
            lblTime.text = event.dateTimeString(event.time)
            lblNote.text = event.note
            
            lblEvent.text = event.name
            
            let szAction = event.getFullActionName()
            
            // breast process
            if event.type == "breast" {
                
                lblAction.text = szAction
                lblDuration.text = event.getDurationTimes()
                
                var szTime:String = ""
                
                szTime = event.dateTimeString(event.time)

                /*
                if event.action.isEqualToString("right") {
                    if event.timeRight == nil {
                        szTime = ""
                    }
                    else {
                        szTime = event.dateTimeStringFromDate(event.timeRight!)
                    }
                    
                }
                else  {
                    if event.timeLeft == nil {
                        szTime = ""
                    }
                    else {
                        szTime = event.dateTimeStringFromDate(event.timeLeft!)
                    }
                }
*/

                lblTime.text = szTime

                lblAction.hidden = false
                lblDuration.hidden = false
                lblActionExt.hidden = true
            }
            else {
                lblAction.hidden = true
                lblDuration.hidden = true
                lblActionExt.hidden = false
                
                lblActionExt.text = szAction
            }
            
            // display icons
            if (event.image != nil || event.imageFile != nil){
                image_width.constant = kImageWidth
                image_right.constant = kImageRight
            }
            else {
                image_width.constant = 0
                image_right.constant = 0
            }
            
            //
            if event.starMark == false {
                star_width.constant = 0
                star_right.constant = 0
            }
            else {
                star_width.constant = kImageWidth
                star_right.constant = kImageRight
            }
            
            if event.exclamationMark == false {
                exclaim_width.constant = 0
                exclaim_right.constant = 0
                
            }
            else {
                exclaim_width.constant = kImageWidth
                exclaim_right.constant = kImageRight
            }
            
            if event.doctorMark == false {
                doctor_width.constant = 0
                doctor_right.constant = 0
            }
            else {
                doctor_width.constant = kImageWidth
                doctor_right.constant = kImageRight
            }
            
            if event.babyMark == false {
                baby_width.constant = 0
                baby_right.constant = 0
            }
            else {
                baby_width.constant = kImageWidth
                baby_right.constant = kImageRight
            }
            
            view.updateConstraints()
            view.layoutIfNeeded()
        }
    }
    
    
    @IBAction func undoTapped() {
        EventsManager.sharedManager.undoLastEvent()
    }
    
    
    func xibSetup() {
        
        view = loadViewFromNib()
        
        view.frame = bounds
        
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "UndoView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        xibSetup()
    }

}
