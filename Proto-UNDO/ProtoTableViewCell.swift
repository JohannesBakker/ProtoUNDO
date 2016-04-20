//
//  ProtoTableViewCell.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 12.08.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//
let kEventCellChangedNotification = "kEventCellChanged"
import UIKit
let cellSize:CGFloat  = 108.0
class ProtoTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailButton: BButton!
    func getHeightWithDictionary(object:NSDictionary?) -> CGFloat{
        return cellSize
    }
    var TypeName:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func didMoveToSuperview() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changedCell:", name: kEventCellChangedNotification, object: nil)
    }
    override func removeFromSuperview() {
        super.removeFromSuperview()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    @objc func changedCell(notification:NSNotification){
        
    }

}
