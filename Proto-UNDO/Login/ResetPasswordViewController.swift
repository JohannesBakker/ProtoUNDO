//
//  ResetPasswordViewController.swift
//  Proto-UNDO
//
//  Created by Tomasz on 10/17/15.
//  Copyright © 2015 Curly Brackets. All rights reserved.
//

import UIKit
import Parse

class ResetPasswordViewController: UIViewController, UITextFieldDelegate, UIAlertViewDelegate {

    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnReset: UIButton!
    
    var waitingView : UIView!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var waitingLabel : UILabel!
    
    var email : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onPressBack:"))
        
        // WaitingView
        waitingLabel = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 25)) as UILabel!
        waitingLabel.text = "Sending Request ..."
        waitingLabel.textAlignment = NSTextAlignment.Center
        waitingLabel.textColor = UIColor.blackColor()
        waitingLabel.font = UIFont.boldSystemFontOfSize(20)
        
        let waitingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        waitingIndicator.color = UIColor.darkGrayColor()
        waitingIndicator.startAnimating()
        
        waitingView = UIView(frame: UIScreen.mainScreen().bounds)
        waitingView.backgroundColor =  UIColor(white: 1.0, alpha: 0.9)
        
        waitingView.addSubview(waitingLabel)
        waitingView.addSubview(waitingIndicator)
        
        waitingIndicator.center = waitingView.center
        waitingLabel.center = CGPointMake(waitingView.center.x, waitingView.center.y - waitingIndicator.bounds.size.height / 2 - waitingLabel.bounds.size.height / 2 - 20)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController!.navigationBar.tintColor = UIColor.redColor()
        self.navigationController?.navigationBarHidden = false
        
        txtEmail.text = email
        setResetButtonEnabled(email)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBarHidden = true
        self.navigationController!.navigationBar.tintColor = UIColor(red: 0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Actions
    
    @IBAction func onPressReset(sender: AnyObject) {
        self.view.endEditing(true)
        
        appDelegate.window?.addSubview(waitingView)
        
        PFUser.requestPasswordResetForEmailInBackground(txtEmail.text!) { (success : Bool, error : NSError?) -> Void in
            
            self.waitingView.removeFromSuperview()
            
            if success
            {
                UIAlertView(title: "An Email has been sent.", message: "You will receive an email at \n " + self.txtEmail.text! + ". Please check your \n inbox.", delegate: self, cancelButtonTitle: "Dismiss", otherButtonTitles: "Log In").show()
                
                self.btnReset.hidden = true
            }
            else
            {
                self.showMessage("Password reset request Failed. Please Try again", message: "")
            }
        }
    }
    
    func onPressBack(sender: AnyObject)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - TextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var emailString : String
        
        if range.length > 0 && string == ""
        {
            emailString = (txtEmail.text?.substringToIndex((txtEmail.text?.endIndex.predecessor())!))!
        }
        else
        {
            emailString = txtEmail.text! + string
        }
        
        setResetButtonEnabled(emailString)
        
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        
        btnReset.enabled = false
        btnReset .setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        return true;
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text == ""
        {
            textField.clearButtonMode = UITextFieldViewMode.WhileEditing
        }
        else
        {
            textField.clearButtonMode = UITextFieldViewMode.Always
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField .resignFirstResponder()
        return true
    }
    
    // MARK: - General Methods
    
    func showMessage(title:String, message : String)
    {
        UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "Dismiss").show()
    }
    
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(candidate)
    }
    
    func setResetButtonEnabled(emailString : String)
    {
        if validateEmail(emailString)
        {
            btnReset.enabled = true
            btnReset .setTitleColor(UIColor(red: 0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0), forState: UIControlState.Normal)
        }
        else
        {
            btnReset.enabled = false
            btnReset .setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        }
    }
    
    // MARK: - AlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1
        {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

}
