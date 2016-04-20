//
//  MemoTableViewCell.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 06.09.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import UIKit

class MemoTableViewCell: BaseTableViewCell {
    @IBOutlet weak var typeHereButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var detailButton: UIButton!
    
    var item: EventItem!
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryView = nil
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func photoAction(sender: AnyObject) {
        viewController.showInput(self, isPhotoTapped: true)
    }

    @IBAction func typeAction(sender: AnyObject) {
        viewController.showInput(self, isPhotoTapped: false)
    }
    
    @IBAction func memoAction(sender: AnyObject) {
        selected = true
        viewController.onAccessoryButtonTapped(item!)
    }
}
