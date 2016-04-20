//
//  PhotoCollectionViewCell.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 08.09.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var checkMark: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "tapNotification:", name: "cellPhotoTaped", object: nil)
        let gr = UITapGestureRecognizer(target: self, action: "tapAction:")
        imageView.addGestureRecognizer(gr)
        imageView.userInteractionEnabled = true
    }
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    @objc func tapAction(sender: AnyObject) {
        checkMark.selected = !checkMark.selected;
        NSNotificationCenter.defaultCenter().postNotificationName("cellPhotoTaped",
            object: nil,
            userInfo:
            ["sender": self ,
            "value": NSNumber(bool: checkMark.selected) ]);
    }
    @objc func tapNotification(notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo!
        let sender: PhotoCollectionViewCell? = userInfo.valueForKey("sender") as? PhotoCollectionViewCell
        if (sender != nil){
            if sender != self {
                checkMark.selected = false;
            }
        }
        else{
            checkMark.selected = false;
        }
    }
    override func  prepareForReuse() {
        checkMark.selected = false
        imageView.image = nil
    }
}
