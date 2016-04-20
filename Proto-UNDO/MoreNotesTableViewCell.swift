//
//  MoreNotesTableViewCell.swift
//  Proto-UNDO
//
//  Created by Yury on 27/09/15.
//  Copyright © 2015 Curly Brackets. All rights reserved.
//

import UIKit
import AVFoundation

class MoreNotesTableViewCell: MoreTableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var noteTextView: UITextView!
    
    @IBOutlet var photoImageViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        noteTextView.layer.borderColor = UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.0).CGColor
        noteTextView.clipsToBounds = true
        noteTextView.layer.cornerRadius = 5
        noteTextView.layer.borderWidth = 0.5
    }

    override func updateCell() {
        noteTextView.text = event.note
        if event.note == nil {
            noteTextView.text = "Notes"
            noteTextView.textColor = UIColor.grayColor()
        }
        photoImageView.image = event.image
    }
    
    @IBAction func photoButtonTapped() {
        selected = true
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let takePhotoAction = UIAlertAction(title: "Take a Photo", style: .Default){ (action) in self.getPicture(.Camera) }
        alertController.addAction(takePhotoAction)
        let choosePhotoAction = UIAlertAction(title: "Choose Existing", style: .Default){ (action) in self.getPicture(.PhotoLibrary) }
        alertController.addAction(choosePhotoAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Destructive){ (action) in }
        alertController.addAction(cancelAction)
        
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true){}
    }
    
    // MARK: photo
    func getPicture(sourceType: UIImagePickerControllerSourceType) {
        if !UIImagePickerController.isSourceTypeAvailable(sourceType)
        {
            let alertController = UIAlertController(title: "Camera", message: "Camera on your device is not available!", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .Cancel){ (action) in }
            alertController.addAction(cancelAction)
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true){}
        }
        else {
            let imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        picker.dismissViewControllerAnimated(true, completion: nil)
        let original = info[UIImagePickerControllerOriginalImage] as? UIImage
        photoImageView.image = original
        event.image = original
        if photoImageView.image != nil {
            if photoImageViewHeight.constant == 0 {
                tableView?.beginUpdates()
                self.photoImageViewHeight.constant = 210
                self.photoImageView.hidden = false
                tableView?.endUpdates()
            }
        }
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(textView: UITextView) {
        if event.note == nil { // first time editing
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
    }
    func textViewDidChange(textView: UITextView) {
        event.note = textView.text
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        endEditing(true)
    }
}
