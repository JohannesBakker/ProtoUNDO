//
//  MoreQuantityTableViewCell.swift
//  Proto-UNDO
//
//  Created by Yury on 28/09/15.
//  Copyright © 2015 Curly Brackets. All rights reserved.
//

import UIKit

class MoreQuantityTableViewCell: MoreTableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var pickerViewHeight: NSLayoutConstraint!
    
    override func selectCell(selected: Bool) {
        if selected {
            tableView?.beginUpdates()
            pickerViewHeight.constant = pickerViewHeight.constant == 0 ? 180 : 0
            pickerView.hidden = pickerViewHeight.constant == 0
            tableView?.endUpdates()
        }
    }

    override func updateCell() {
        pickerView.hidden = pickerViewHeight.constant == 0
        let quantity = event.quantity ?? 1
        event.quantity = quantity
        pickerView.selectRow(quantity, inComponent: 0, animated: false)
        quantityLabel.text = "\(quantity)"
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 100
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        event.quantity = row
        quantityLabel.text = "\(row)"
    }
}
