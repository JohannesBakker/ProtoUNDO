//
//  CustomActionsViewController.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 10.09.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import UIKit

class CustomActionsViewController: BaseViewController, UITextFieldDelegate,UIActionSheetDelegate {
    var changed:Bool = false
    /// type of event
    var type:String = ""
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var typeTitle: UINavigationItem!
    @IBOutlet var inputFields: [TextField]!
    override func viewDidLoad() {
        super.viewDidLoad()
        typeTitle.title = type.capitalizedString
        saveButton.enabled = false

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        let eventDict:NSDictionary? = kEvents[type] as? NSDictionary
        if (eventDict != nil){
            let actionDescription:[String]? = eventDict![kActionDescription] as? [String]
            let actions:[String]? = eventDict![kActions] as? [String]
            if (actionDescription != nil && actions != nil){
                for var i = 0 ; i < inputFields.count; i++ {
                    let field = inputFields[i]
                    if (i<actions?.count){
                        setBorderForView(field, color: UIColor(white: 0.75, alpha: 1), width: 1, radius: 0)
                        field.placeholder = actionDescription![i]
                        field.rightView?.layer.sublayerTransform = CATransform3DMakeTranslation(-40.0, 0.0, 0.0)
                        field.text = LogEvent.getActionName(type, action: actions![i])
                        field.delegate = self
                    }
                    else{
                        field.hidden = true
                    }
                }
            }
        }
    }
    @IBAction func back(sender: AnyObject) {
        if !changed {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else{
            let confirm = UIActionSheet(title: "Are you sure to \"Cancel\"?", delegate: self, cancelButtonTitle: "No", destructiveButtonTitle: "Yes, cancel")
            confirm.tag = 100
            confirm.showInView(self.view)
            //confirm.showFromBarButtonItem(navigationItem.leftBarButtonItem, animated: true)
        }
    }
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet.tag == 100 {
            // Cancel dialog
            if buttonIndex != actionSheet.cancelButtonIndex{
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    @IBAction func saveAction(sender: AnyObject) {
        saveChanges()
    }
    func saveChanges(){
        saveButton.enabled = false
        let eventDict:NSDictionary? = kEvents[type] as? NSDictionary
        var updated = false
        if (eventDict != nil){
            let actionDescription:[String]? = eventDict![kActionDescription] as? [String]
            let actions:[String]? = eventDict![kActions] as? [String]
            if (actionDescription != nil && actions != nil){
                for var i = 0 ; i < inputFields.count; i++ {
                    let field = inputFields[i]
                    if (i<actions?.count){
                        if let fieldtext = field.text where !fieldtext.isEmpty {
                            let action = actions![i]
                            let text = LogEvent.getActionName(type, action: action)
                            if (text != field.text){
                                LogEvent.customLabels[action] = field.text
                                updated = true
                            }
                        }


                    }
                }
            }
        }
        if (updated) {
            DataSource.sharedDataSouce.saveCustomLabels(LogEvent.customLabels)
            NSUserDefaults.standardUserDefaults().setObject(LogEvent.customLabels, forKey: kActions)
            NSUserDefaults.standardUserDefaults().synchronize()
            NewDatasource.setCustomNames()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName(kEventsListChangedNotification, object: nil)
            })
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        cancelButton.tintColor = UIColor.redColor()
        saveButton.enabled = true
        textField.tag = -1 // means changed
        changed = true
        return true
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
