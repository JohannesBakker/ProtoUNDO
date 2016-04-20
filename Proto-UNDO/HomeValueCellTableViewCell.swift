//
//  HomeValueCellTableViewCell.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 12.08.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import UIKit

class HomeValueCellTableViewCell: ProtoTableViewCell {

    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var valueSlider: UISlider!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var actionTitle: BButton!
    @IBOutlet weak var actionWitdth: NSLayoutConstraint!
    var actionActiveButtonWidth:CGFloat = 20
    var formatString = "%i oz"
    var _value:Float = 0.0
    var value:Float {
        set (newValue){
            if newValue == 0 {
                actionTitle.enabled=false
                if _value != newValue {
                    UIView.animateWithDuration(0.15, animations: { () -> Void in
                        self.actionWitdth.constant=0
                        self.actionTitle.enabled=false
                        
                        self.layoutSubviews()
                    })
                    
                }
                valueLabel.enabled = false
                setBorderForView(borderView, color: UIColor.clearColor(), width: 1, radius: 3)
            }
            else{
                actionTitle.enabled=true
                if (_value==0){
                    UIView.animateWithDuration(0.15, animations: { () -> Void in
                        self.actionWitdth.constant=self.actionActiveButtonWidth
                        self.actionTitle.enabled=true
                        
                        self.layoutSubviews()
                        
                    })
                }
                valueLabel.enabled = true
                setBorderForView(borderView, color: UIColor.greenColor(), width: 1, radius: 3)
            }
            _value = round(newValue)
            valueLabel.text = String(format: formatString, Int(_value))

        }
        get{
            return _value
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        actionTitle.setTitle(" ", forState: UIControlState.Normal)
        actionWitdth.constant = 0;
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func valueChanged(sender: UISlider) {
        self.value = sender.value
        
            NSNotificationCenter.defaultCenter().postNotificationName(kEventCellChangedNotification, object: self)

    }
    @objc override func changedCell(notification:NSNotification){
        super.changedCell(notification)
        let sender:AnyObject? = notification.object
        if (sender == nil){
            self.value = 0
            valueSlider.value = 0;
        }
        else if sender!.isEqual(self) == false {
            self.value = 0
            valueSlider.value = 0;
        }
    }
    func loadDictionary (dict:NSDictionary, key:String) {
        TypeName = key
        titleLabel.text = TypeName!.capitalizedString
        let desc:NSDictionary = (dict[key] as? NSDictionary)!
        let actions:[String] = desc[kActionDescription] as! [String]
        actionTitle.setTitle(actions.first?.lowercaseString, forState: UIControlState.Normal)
        let rsize:CGSize = actionTitle.sizeThatFits(CGSize(width: 100, height: actionTitle.frame.size.height))
        actionActiveButtonWidth = rsize.width 
        actionWitdth.constant = 0;
        valueSlider.value = 0
        formatString = (desc[kValueFormat] as? String)!
        self.value=0
    }
}
