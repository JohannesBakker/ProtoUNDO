//
//  MoreDateTableViewCell.swift
//  Proto-UNDO
//
//  Created by Yury on 28/09/15.
//  Copyright © 2015 Curly Brackets. All rights reserved.
//

import UIKit
import Foundation

class MoreDateTableViewCell: MoreTableViewCell {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet var datePickerHeight: NSLayoutConstraint!
    @IBOutlet var dateLabel: UILabel!
    
    override func selectCell(selected: Bool) {
        if selected {
            tableView?.beginUpdates()
            datePickerHeight.constant = datePickerHeight.constant == 0 ? 180 : 0
            datePicker.hidden = datePickerHeight.constant == 0
            tableView?.endUpdates()
        }
    }
    
    override func updateCell() {
        datePicker.hidden = datePickerHeight.constant == 0
        datePicker.date = NSDate(timeIntervalSinceReferenceDate: event.time)
    }

    lazy var dateFormatter : NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()
    
    @IBAction func dateChanged() {
        let date = datePicker.date
        event.time = date.timeIntervalSinceReferenceDate
        dateLabel.text = dateFormatter.stringFromDate(date)
    }
}
