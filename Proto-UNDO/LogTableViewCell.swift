//
//  LogTableViewCell.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 27.07.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import UIKit 

class LogTableViewCell: UITableViewCell {

    @IBOutlet weak var headLine: UILabel!
    @IBOutlet weak var subHeadLine: UILabel!
    @IBOutlet weak var logDetail: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bodyCopy: UILabel!
    @IBOutlet weak var detailButton: UIButton!

    @IBOutlet weak var picture_log_width: NSLayoutConstraint!
    @IBOutlet weak var star_width: NSLayoutConstraint!
    @IBOutlet weak var parent_width: NSLayoutConstraint!
    @IBOutlet weak var exclamation_width: NSLayoutConstraint!
    @IBOutlet weak var doctor_width: NSLayoutConstraint!
    @IBOutlet weak var baby_width: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        resetIcons()
        resetLabels()
        
        self.updateConstraintsIfNeeded()
    }

    func setupCell(event:LogEvent){

        self.timeLabel.text = event.dateTimeString(event.time)

        subHeadLine.text = event.title()
        bodyCopy.text = event.note
        
        logDetail.text = event.getDurationTimes()
        
        
        
        // Marko
        // change breast title
        headLine.text = event.name
        
        subHeadLine.text = event.getFullActionName()
        
        if event.type.isEqualToString("breast") {
            var szTime:String = ""
            
            szTime = event.dateTimeString(event.time)

            self.timeLabel.text = szTime
        }
        
        
        
        if let _ = event.imageFile {
            picture_log_width.constant = 30
        }
        else {
            picture_log_width.constant = 0
        }
        
        if event.starMark == false {
            star_width.constant = 0
        }
        else {
            star_width.constant = 30
        }
        
        if event.exclamationMark == false {
            exclamation_width.constant = 0
        }
        else {
            exclamation_width.constant = 30
        }
        
        if event.doctorMark == false {
            doctor_width.constant = 0
        }
        else {
            doctor_width.constant = 30
        }
        
        if event.babyMark == false {
            baby_width.constant = 0
        }
        else {
            baby_width.constant = 30
        }
        
        self.updateConstraintsIfNeeded()
    }

    func resetIcons(){

        parent_width.constant = 0
        picture_log_width.constant = 0
        star_width.constant = 0
        exclamation_width.constant = 0
        doctor_width.constant = 0
        baby_width.constant = 0
    }
    func resetLabels(){
        headLine.text = nil
        subHeadLine.text = nil
        logDetail.text = nil
        timeLabel.text = nil
        bodyCopy.text = nil
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func getDateFormat(timeInterval:NSTimeInterval) -> String
    {
        let date:NSDate = NSDate(timeIntervalSinceReferenceDate: timeInterval)
        let dateFormatter = NSDateFormatter()
        var text : String = ""
        
        if NSCalendar.currentCalendar().isDateInToday(date) {
            dateFormatter.dateFormat = "h:mm a"
            text = "Today " + dateFormatter.stringFromDate(date).lowercaseString
        }else if NSCalendar.currentCalendar().isDateInTomorrow(date) {
            dateFormatter.dateFormat = "h:mm a"
            text = "Tomorrow " + dateFormatter.stringFromDate(date).lowercaseString
        }else if NSCalendar.currentCalendar().isDateInYesterday(date) {
            dateFormatter.dateFormat = "h:mm a"
            text = "Yesterday " + dateFormatter.stringFromDate(date).lowercaseString
        }else {
            dateFormatter.dateFormat = "MM/dd/yy h:mm a"
            text = dateFormatter.stringFromDate(date).lowercaseString
        }
        
        return text
    }
}
