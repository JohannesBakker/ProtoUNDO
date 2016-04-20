//
//  MultiActionTableViewCell.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 12.08.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import UIKit
let kButtonsViewHeight:CGFloat = 60.0

class MultiActionTableViewCell: ProtoTableViewCell {
    
    var actionButtons: [BButton]! = []
    var actionViewControllers: [ButtonsViewController] = []
    var dict:NSDictionary? = nil
    override func getHeightWithDictionary(object:NSDictionary?) -> CGFloat{
        if (object != nil){
        let actions:[String]? = object![kActionDescription] as? [String]
        
        if (actions != nil){
            if( actions!.count>1 ){
                return cellSize + CGFloat(actions!.count - 1) * kButtonsViewHeight
            }
        }
        }
        return cellSize
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func didMoveToSuperview() {
        if (dict != nil){
            setup()
        }
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func  prepareForReuse() {
        removeAllActions()
    }
    func removeAllActions(){
        actionButtons.removeAll(keepCapacity: true)
        for controller in actionViewControllers{
            controller.view.removeFromSuperview()
        }
        actionViewControllers.removeAll(keepCapacity: true)
    }
    func loadDictionary (dict:NSDictionary, key:String) {
        self.dict = dict
        TypeName = key
        titleLabel.text = TypeName!.capitalizedString
        if (self.superview != nil){
            removeAllActions()
            setup()
        }
    }
    
    func addTargetForActions(target: AnyObject?, action: Selector, forControlEvents controlEvents: UIControlEvents){
        for btn in actionButtons{
            btn.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
            btn.addTarget(target, action: action, forControlEvents: controlEvents)
            btn.parentCell = self
        }
    }
    func addTargetForDetal(target: AnyObject?, action: Selector, forControlEvents controlEvents: UIControlEvents){
        for controler in actionViewControllers{
            let btn = controler.detailButton
            btn.tag = actionViewControllers.indexOf(controler)!
            btn.removeTarget(nil, action: nil, forControlEvents: UIControlEvents.AllEvents)
            btn.addTarget(target, action: action, forControlEvents: controlEvents)
            btn.parentCell = self
        }
    }
    private
    func setup(){
        actionViewControllers.removeAll(keepCapacity: true)
        actionButtons.removeAll(keepCapacity: true)
        let subDict:NSDictionary = (dict![TypeName!] as? NSDictionary)!
        let actions:[String]? = subDict[kActionDescription] as? [String]
        let actionKeys:[String]! = subDict[kActions] as! [String];
        if (actions != nil){
//            let _actions:[String] = actions!;
            var offset:CGFloat = 40 //self.contentView.frame.size.height - kButtonsViewHeight
//            var frame = CGRectMake(0, offset, self.contentView.frame.size.width, kButtonsViewHeight)
            
            for var i=0 ; i<actions!.count ; i++ {
                let controller:ButtonsViewController = ButtonsViewController(nibName: "ButtonsViewController", bundle: nil)
                controller.loadView()
                controller.viewDidLoad()
                contentView.addSubview(controller.view)
                var frame = controller.view.frame
                frame.origin.y = offset
                frame.origin.x = 0
                frame.size.width = self.contentView.frame.size.width
                frame.size.height = kButtonsViewHeight
                controller.view.frame = frame
                offset += kButtonsViewHeight
                
                actionViewControllers.append(controller)
                actionButtons.append(controller.actionButton)
                let actionName:String = LogEvent.getActionName(TypeName! , action: actionKeys[i])
                actionButtons[i].setTitle(actionName, forState: UIControlState.Normal)
            }
        }
    }
}
