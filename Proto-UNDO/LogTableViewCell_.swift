//
//  LogTableViewCell.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 27.07.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import UIKit

class LogTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var agoTimeLabel: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var noteLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setupCell(event:LogEvent){
        self.timeLabel.text = getTimeStringWithInterval(event.time)
        self.agoTimeLabel.text = getAgoStringWithInterval(event.time)
        titleLabel.text = event.title()
        event.getImage { (image, error) -> Void in
            self.photoView.image = image
        }
        noteLabel.text = event.note
    }
}
