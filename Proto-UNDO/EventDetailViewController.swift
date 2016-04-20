
//
//  EventDetailViewController.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 02.08.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import UIKit
import AVFoundation
class EventDetailViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var heightOfContentView: NSLayoutConstraint!
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    var event:LogEvent = LogEvent()
    var _eventValue:Float = 0
    var eventValue:Float {
        get{
            return _eventValue
        }
        set (newValue){
            _eventValue = round(newValue)
            eatLabel.text = String(format: formatString, Int(eventValue))
        }
    }
    var eventTime:NSDate?
    var Star:Bool = false
    var Exclamation:Bool = false
    var image:UIImage?
    var note:NSString?
    var changed:Bool = false
    var formatString = "(%i of oz)"
    weak var saveButton:UIBarButtonItem?
    weak var cancelButton:UIBarButtonItem?
    @IBOutlet weak var datepickerHeight: NSLayoutConstraint!
    @IBOutlet weak var photoViewHeight: NSLayoutConstraint!
    @IBOutlet weak var notesText: UITextView!
    @IBOutlet weak var eatSlider: UISlider!
    @IBOutlet weak var eatLabel: UILabel!
    @IBOutlet weak var starButton: BButton!
    @IBOutlet weak var exlamaionButton: BButton!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var actionButtons: [BButton]?
    
    
    var kbSize:CGSize = CGSize(width: 0,height: 216)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.datepickerHeight.constant = 0
        self.photoViewHeight.constant = 0
        photoImageView.hidden=true
        self.navigationController?.navigationBarHidden=false;
        self.view.setNeedsUpdateConstraints()
        self.view.updateConstraints()
        setBorderForView(notesText, color: UIColor.lightGrayColor(), width: 1, radius: 3)
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveAction:")
        navigationItem.rightBarButtonItem = saveButton
        saveButton.enabled = false
        self.saveButton = saveButton
        
        let backButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Done, target: self, action: "back:")
        navigationItem.leftBarButtonItem = backButton
        self.cancelButton = backButton
        event.time = datePicker.date.timeIntervalSinceReferenceDate
        datePicker.minimumDate = NSDate(timeIntervalSinceNow: -60*60*12) // halfday before
        datePicker.maximumDate = NSDate(timeIntervalSinceNow: +60*60*12) // halfday after
        dateLabel.text = getTimeStringWithInterval(event.time)
        title = "More \(event.name.capitalizedString)"
        
        let desc:NSDictionary! = kEvents[event.type] as! NSDictionary

        if (desc[kValueUsed] as! NSNumber).boolValue {
            formatString = (desc[kValueFormat] as? String)!
        }
        else {
            let custom:NSNumber? = desc[kCustomizable] as? NSNumber
            if (custom != nil && custom!.boolValue == true) {
                let btn = actionButtons![0]
                btn.setTitle(LogEvent.getActionName(event.type as String, action: event.action as String), forState: UIControlState.Normal)
                btn.enabled = true
                btn.highlighted = false
            }
            else if (desc[kActionDescription] != nil) {
                let titles:[String] = desc[kActionDescription] as! [String]
                for btn in actionButtons!{
                    btn.setTitle("", forState: UIControlState.Normal)
                    btn.enabled = false
                    btn.highlighted = false
                }
                for var i = 0; i < titles.count; i++ {
                    if i<actionButtons!.count{
                        actionButtons![i].setTitle(titles[i], forState: UIControlState.Normal)
                        actionButtons![i].enabled = true
                    }
                }
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden=false;
    }
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: - save / cancel
    @objc func saveAction(sender: AnyObject){
        NSLog("save");
        event.note = notesText.text != "Notes" ? notesText.text : nil
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        DataSource.sharedDataSouce.logEvent(self.event, block: { (success, error) -> Void in
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            self.activityIndicator.stopAnimating()
            if (success){
                self.changed=false
                self.navigationController?.popToRootViewControllerAnimated(true);
            }
            else{
                let av = UIAlertView(title: "Error", message: "Error:\(error?.localizedDescription)", delegate: nil, cancelButtonTitle: "OK")
                av.show()
                
            }
        })
    }
    @objc func back(sender: AnyObject){
        if !changed {
            self.navigationController?.popToRootViewControllerAnimated(true);
        }
        else{
            let alertController = UIAlertController(title: nil, message: "Are you sure to \"Cancel\"?\nThe event will be deleted", preferredStyle: .ActionSheet)

            let deleteAction = UIAlertAction(title: "Yes, cancel and delete", style: .Destructive){ (action) in
                self.navigationController?.popToRootViewControllerAnimated(true);
            }
            alertController.addAction(deleteAction)

            let cancelAction = UIAlertAction(title: "No, don't delete", style: .Cancel){ (action) in
            }
            alertController.addAction(cancelAction)
            
            presentViewController(alertController, animated: true){}
        }
    }
    // MARK: - time
    @IBAction func timeAction(sender: AnyObject) {
        notesText.resignFirstResponder()
        var constant:CGFloat = 0
        var hidden:Bool = true
        if (self.datepickerHeight.constant == 0){
            constant = 162.0
            hidden = false
        }
        else{
            constant = 0
            hidden = true
        }
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.datepickerHeight.constant = constant
            self.datePicker.hidden = hidden
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
    @IBAction func datePickerAction(sender: UIDatePicker) {
        notesText.resignFirstResponder()
        dateLabel.text = getTimeStringWithInterval(sender.date.timeIntervalSinceReferenceDate)
        event.time = sender.date.timeIntervalSinceReferenceDate
        changed=true
        saveButton?.enabled=true
        cancelButton?.tintColor = UIColor.redColor()
    }
    // MARK: - value
    
    @IBAction func valueChangedAction(sender: UISlider) {
        notesText.resignFirstResponder()
        event.value = roundf(sender.value)
        self.eventValue  = event.value
        changed=true
        saveButton?.enabled=true
        cancelButton?.tintColor = UIColor.redColor()
    }
   // MARK: - simple events
    @IBAction func eventAction(sender: BButton) {
        notesText.resignFirstResponder()
        changed = true
        saveButton?.enabled=true
        cancelButton?.tintColor = UIColor.redColor()
        let desc:NSDictionary = kEvents[event.type] as! NSDictionary
        let actions:[String] = desc[kActions] as! [String]
        let custom:NSNumber? = desc[kCustomizable] as? NSNumber
        if (custom == nil || (custom != nil && custom!.boolValue == false)) {
            let index = actionButtons?.indexOf(sender)
            event.action = actions[index!]
        }
        delay(0.1, closure: { () -> () in
            sender.highlighted=true
            for btn in self.actionButtons! {
                if btn != sender {
                    btn.highlighted=false
                }
            }
        })
    }
    // MARK: - marks
    @IBAction func starMarkAction(sender: UIButton) {
        notesText.resignFirstResponder()
        event.starMark = !event.starMark
        sender.selected = event.starMark
        changed=true
        saveButton?.enabled=true
        cancelButton?.tintColor = UIColor.redColor()
    }
    @IBAction func exclamaionMarkAction(sender: UIButton) {
        notesText.resignFirstResponder()
        event.exclamationMark = !event.exclamationMark
        sender.selected = event.exclamationMark
        changed=true
        saveButton?.enabled=true
        cancelButton?.tintColor = UIColor.redColor()
    }

    //MARK: - text
    func textViewDidChange(textView: UITextView) {
        if event.type == kMemo{
            var size:CGSize = textView.sizeThatFits(CGSizeMake(textView.frame.size.width, kMAXInputHeight));
            var scrolling:Bool = false
            if size.height > kMAXInputHeight{
                size.height = kMAXInputHeight
                scrolling = true
            }
            let heightOfView:CGFloat = size.height + bottomSpace.constant + topSpace.constant
            
//            var frame:CGRect = self.view.frame
//            var offset:CGFloat = heightOfView - self.view.frame.size.height;
            heightOfContentView.constant = heightOfView
            textView.layoutManager.allowsNonContiguousLayout = false;
            if (scrolling){
                textView.scrollEnabled=true;
            }
            if (!textView.text.isEmpty){
                changed = true;
                saveButton?.enabled=true
                cancelButton?.tintColor = UIColor.redColor()
            }
            else{
                if (event.exclamationMark == false && event.starMark == false && event.image == nil){
                    changed = false
                    saveButton?.enabled=false
                    cancelButton?.tintColor = UIColor.blueColor()
                }
            }
        } else {
            if (!textView.text.isEmpty){
                changed = true;
                saveButton?.enabled=true
                cancelButton?.tintColor = UIColor.redColor()
            }
            else{
                if (event.exclamationMark == false && event.starMark == false && event.image == nil){
                    changed = false
                    saveButton?.enabled=false
                    cancelButton?.tintColor = UIColor.blueColor()
                }
            }
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "Notes" {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
    }
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        event.note = textView.text
        if textView.text!.isEmpty == false {
            changed=true
            saveButton?.enabled=true
            cancelButton?.tintColor = UIColor.redColor()
        }
        return true
    }
    @IBAction func anytouch(sender: AnyObject) {
        notesText.resignFirstResponder()
    }
    // MARK:  set text view other keyboard
    var prevOffset:CGFloat = 0
    @objc func keyboardWillShow(notification:NSNotification){
        let userInfo:NSDictionary = notification.userInfo!
        kbSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)!.CGRectValue().size
        let time:Double =  userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        var curve:Int = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.integerValue;
        curve = curve << 16;
        let neededOffset:CGFloat = scrollView.frame.size.height - kbSize.height;
        let bottomOfText = notesText.frame.size.height + notesText.frame.origin.y;
        if (bottomOfText > neededOffset && scrollView.contentOffset.y < neededOffset) {
            prevOffset = scrollView.contentOffset.y
            UIView.animateWithDuration(time, animations: { () -> Void in
                self.scrollView.contentOffset = CGPointMake(0, bottomOfText-neededOffset)
                }) { (finished:Bool) -> Void in
                    
            }
        }
    }
    @objc func keyboardWillHide(notification:NSNotification){
        let userInfo:NSDictionary = notification.userInfo!
        let time:Double =  userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        var curve:Int = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.integerValue;
        curve = curve << 16;
        UIView.animateWithDuration(time, animations: { () -> Void in
            self.scrollView.contentOffset = CGPointMake(0, self.prevOffset)
            }) { (finished:Bool) -> Void in
                
        }
    }
    // MARK: photo
    @IBAction func addPhoto(sender: AnyObject) {
        notesText.resignFirstResponder()
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let photoAction = UIAlertAction(title: "Take a Photo", style:.Default){ (action) in self.takePhoto()}
        alertVC.addAction(photoAction)
        let chooseAction = UIAlertAction(title: "Choose Existing", style:.Default){ (action) in self.getExisting()}
        alertVC.addAction(chooseAction)
        let cancelAction = UIAlertAction(title: "Cancel", style:.Destructive){ (action) in}
        alertVC.addAction(cancelAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }

    func checkCameraAccess(){
        
        let authStatus:AVAuthorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch authStatus{
        case .Authorized:
            askPhotoOrLibrary()
        case .Denied:
            showDeniedMessage()
        case .NotDetermined:
            askAccessToCameraAndLibrary()
        case .Restricted:
            showRestrictedMessage()
        }
    }
    func askAccessToCameraAndLibrary(){
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted) -> Void in
            if granted {
                
            }
        })
    }
    func takePhoto(){
        getPicture(.Camera)
    }
    func getExisting(){
        getPicture(.PhotoLibrary)
    }
    func getPicture(sourceType: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) == false
        {
            let alert = UIAlertView(title: "Camera", message: "Camera on your device is not available!", delegate: nil, cancelButtonTitle: "OK");
            alert.show()
            return
        }
        let imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        picker.dismissViewControllerAnimated(true, completion: nil)
        let original = info[UIImagePickerControllerOriginalImage] as? UIImage
        photoImageView.image = original
        if photoImageView.image != nil {
            changed=true
            saveButton?.enabled=true
            cancelButton?.tintColor = UIColor.redColor()
            event.image = photoImageView.image
            if photoImageView.hidden == true{
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.photoViewHeight.constant = 210
                    self.photoImageView.hidden = false
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func askPhotoOrLibrary(){
        
    }
    func showDeniedMessage(){
        
    }
    func showRestrictedMessage(){
        
    }

}
