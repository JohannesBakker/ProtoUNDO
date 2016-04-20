//
//  MemoInputViewController.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 06.09.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import UIKit
let kMAXInputHeight:CGFloat = 300
func showPhotoChooseController() -> ChoosePictureSourceViewController{
    let chooseController:ChoosePictureSourceViewController!  = ChoosePictureSourceViewController(nibName: "ChoosePictureSourceViewController", bundle: nil)
    chooseController!.loadView()
    chooseController!.viewDidLoad()
    var frame:CGRect = chooseController!.view.frame
    // add to window instead view
    let window:UIWindow = UIApplication.sharedApplication().windows.first!
    frame.size.width = window.frame.size.width
    frame.origin = CGPointMake(0, window.frame.size.height);
    chooseController!.view.frame = frame;
    
    let bgView = UIView(frame: window.frame);
    bgView.backgroundColor = UIColor(white: 0.0, alpha: 0.5);
    let gr = UITapGestureRecognizer(target: chooseController!, action: "cancelAction:")
    bgView.addGestureRecognizer(gr)
    window.addSubview(bgView)
    window.addSubview(chooseController!.view)
    chooseController!.backgroundView = bgView
    bgView.alpha = 0;
    frame.origin.y = window.frame.size.height - frame.size.height;
    UIView.animateWithDuration(0.2, animations: { () -> Void in
        bgView.alpha = 0.5
        chooseController!.view.frame = frame
    })
    return chooseController
}
class MemoInputViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var line: UITextField!
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    
    weak var backgroundView:UIView? = nil
    var chooseController:ChoosePictureSourceViewController? = nil
    var image:UIImage? = nil
    var kbSize:CGSize = CGSize(width: 0,height: 216)
    override func viewDidLoad() {
        super.viewDidLoad()
        setBorderForView(textField, color: UIColor.lightGrayColor(), width: 1, radius: 5);
        textField.clipsToBounds = true;
        setBorderForView(line, color: UIColor.lightGrayColor(), width: 1, radius: 0)
        textField.font = UIFont.systemFontOfSize(17)
        textField.attributedText = NSAttributedString(string: "", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(17) ])
         textField.font = UIFont.systemFontOfSize(17)
        textField.typingAttributes = [NSFontAttributeName : UIFont.systemFontOfSize(17) ]
        textViewDidChange(textField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "photoSelectionCancelled:", name: "photoSelectionCancelled", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "photoSelectionDone:", name: "photoSelectionDone", object: nil)
    }
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    func close(){
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.backgroundView!.alpha = 0
            self.view.alpha = 0
            }, completion: { (finished:Bool) -> Void in
                self.backgroundView!.removeFromSuperview()
                self.view.removeFromSuperview()
        })
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    @IBAction func cancelAction(sender: AnyObject) {
        if textField.attributedText.length == 0 {
            close()
        }
        else{
            askClose()
        }
    }
    func askClose(){
        let alertVC = UIAlertController(title: nil, message: "Are you sure want to \"Cancel\"?\nThis memo will be deleted.", preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Yes, cancel and delete", style:.Destructive){ (action) in self.close()}
        alertVC.addAction(cancelAction)
        let okAction = UIAlertAction(title: "No, don't delete", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        viewController.presentViewController(alertVC, animated: true, completion: nil)
    }

    @IBAction func postAction(sender: AnyObject) {
        if textField.attributedText.length != 0 {
//            let event:LogEvent = LogEvent(_type: kMemo,_action: nil)
            let event:LogEvent = LogEvent(_type: "note",_action: nil)
            let charactersToRemove = NSCharacterSet.alphanumericCharacterSet().invertedSet
            self.view.endEditing(true)
            event.note = textField.attributedText.string.stringByTrimmingCharactersInSet(charactersToRemove)
            event.image = image
            
            let bgView = UIView(frame: self.view.superview!.frame);
            bgView.backgroundColor = UIColor(white: 0.0, alpha: 0.8);
            
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
            activityIndicator.color = UIColor.whiteColor()
            self.view.superview!.addSubview(bgView)
            self.view.superview!.addSubview(activityIndicator)
            
            activityIndicator.center = CGPointMake(CGRectGetMidX(self.view.superview!.frame), CGRectGetMidY(self.view.superview!.frame))
            
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            DataSource.sharedDataSouce.logEvent(event, block: { (success, error) -> Void in
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                activityIndicator.stopAnimating()
                bgView.removeFromSuperview()
                if (success){
                    self.close()
                }
                else{
                    let av = UIAlertView(title: "Error", message: "Error:\(error?.localizedDescription)", delegate: nil, cancelButtonTitle: "OK")
                    av.show()
                    
                }
            })
        }
    }
    @objc func photoSelectionCancelled(notification:NSNotification){
        chooseController = nil;
        textField.becomeFirstResponder();
    }
    @objc func photoSelectionDone(notification:NSNotification){
        chooseController = nil;
        textField.becomeFirstResponder();
        let userInfo:NSDictionary = notification.userInfo!
        let image: UIImage? = (userInfo["image"] as? UIImage)
        if (image != nil){
            addImage(image!)
        }
    }
    @IBAction func photoAction(sender: AnyObject) {
        self.view.endEditing(true);
        chooseController = showPhotoChooseController()
    }
    func addImage(_image:UIImage){
        self.image = _image
        let attributedString = NSMutableAttributedString()
        let textAttachment = NSTextAttachment()
        textAttachment.image = _image
        
        let oldWidth = textAttachment.image!.size.width;
        
        let scaleFactor = oldWidth / (textField.frame.size.width*0.66);
        textAttachment.image = UIImage(CGImage: textAttachment.image!.CGImage!, scale: scaleFactor, orientation: _image.imageOrientation)
        
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        var replaced = false
        if (textField.attributedText.length>0){
            textField.attributedText.enumerateAttribute(
                NSAttachmentAttributeName,
                inRange: NSMakeRange(0, textField.attributedText.length),
                options: NSAttributedStringEnumerationOptions(rawValue: 0),
                usingBlock: { (object:AnyObject?, range:NSRange,  stop:UnsafeMutablePointer<ObjCBool>) -> Void in
                if (object != nil){
                    let atts = NSMutableAttributedString(attributedString: self.textField.attributedText)
                    atts.replaceCharactersInRange(range, withAttributedString: attrStringWithImage)
                    
                    self.textField.attributedText = atts
                    replaced = true
                    stop.memory = true
                    
                }
            })
        }
        if (!replaced){
            attributedString.appendAttributedString(attrStringWithImage);
            if textField.attributedText.length != 0 {
                attributedString.appendAttributedString(NSAttributedString(string: "\n"));
                attributedString.appendAttributedString(textField.attributedText);
            }
            else{
                attributedString.appendAttributedString(NSAttributedString(string: "\n", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(17) ]))
            }
            textField.attributedText = attributedString;
        }
        textViewDidChange(textField)
        
    }
    // MARK: - text
    func textViewDidChange(textView: UITextView) {
        var size:CGSize = textField.sizeThatFits(CGSizeMake(textField.frame.size.width, kMAXInputHeight));
        var scrolling:Bool = false
        if size.height > kMAXInputHeight{
            size.height = kMAXInputHeight
            scrolling = true
        }
        let heightOfView:CGFloat = size.height + bottomSpace.constant + topSpace.constant
        
        var frame:CGRect = self.view.frame
        let offset:CGFloat = heightOfView - self.view.frame.size.height;
        
        frame.size.height = heightOfView
        frame.origin.y -= offset
        self.view.frame = frame
        textField.layoutManager.allowsNonContiguousLayout = false;
        if (scrolling){
            //textField.scrollEnabled=false;
            //textField.scrollRangeToVisible(NSMakeRange(count(textField.text), 0));
            
            textField.scrollEnabled=true;
        }
    }
    func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
        if textAttachment.image != nil{
            textAttachment.image = nil
        }
        return true
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text.isEmpty){
            // delete
            let replaced = textView.attributedText.attributedSubstringFromRange(range)
            var found = false
            replaced.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, replaced.length), options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired, usingBlock: { (object:AnyObject?, rande:NSRange,  stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                if (object != nil ) {
                   found = true
                }
            })
            if (found){
                image = nil
            }
            
            
            
        }
        return true
    }
    // MARK: keyboard
    var prevOffset:CGFloat = 0
    @objc func keyboardWillShow(notification:NSNotification){
        let userInfo:NSDictionary = notification.userInfo!
        kbSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)!.CGRectValue().size
        let time:Double =  userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        var curve:Int = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.integerValue;
        curve = curve << 16;
        
        let neededOffset:CGFloat = self.view.superview!.frame.size.height - ( self.view.frame.size.height + kbSize.height);
        if (self.view.frame.origin.y != neededOffset) {
            prevOffset = self.view.frame.origin.y
            UIView.animateWithDuration(time, animations: { () -> Void in
                var frame = self.view.frame
                frame.origin.y = neededOffset
                self.view.frame = frame
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
            var frame = self.view.frame
            frame.origin.y = self.view.superview!.frame.size.height -  self.view.frame.size.height
            self.view.frame = frame
            }) { (finished:Bool) -> Void in
                
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
