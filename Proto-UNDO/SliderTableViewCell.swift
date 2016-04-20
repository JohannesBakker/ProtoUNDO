//
//  SliderTableViewCell.swift
//  ProtoUNDOTest
//
//  Created by Yury on 18/09/15.
//  Copyright © 2015 Yury. All rights reserved.
//

import UIKit

class SliderTableViewCell: BaseTableViewCell {

    @IBOutlet weak private var slider: UISlider!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var valueLabel: UILabel!
    @IBOutlet weak private var doneButton: UIButton!
    @IBOutlet private var valueTrailing: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var item : SliderEventItem!{
        didSet {
            descriptionLabel.text = item.actions[0].name
            valueLabel.text = String(format: item.infoText, Int(slider.value))
            doneButton.setTitle(item.buttonText, forState: .Normal)
        }
    }
    
    func adjustView() {
        let intValue = Int(slider.value)
        let showButton = intValue > 0
        doneButton.hidden = !showButton
        valueTrailing.active = showButton
        valueLabel.text = String(format: item!.infoText, intValue)
    }
    
    @IBAction func sliderValueChanged() {
        selected = true
        adjustView()
    }
    
    @IBAction func doneTapped() {
        EventsManager.sharedManager.addEvent(LogEvent(item: item, _action: 0, _value: slider.value))
        selected = false
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if !selected {
            slider.value = 0
            adjustView()
        }
    }
    
    override func onAccessoryButtonTapped() {
        super.onAccessoryButtonTapped()
        viewController.onAccessoryButtonTapped(item!)
    }
}
