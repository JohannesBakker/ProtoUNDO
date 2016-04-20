//
//  InviteViewController.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 25.07.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import UIKit
import Parse
import MessageUI

class InviteViewController: BaseViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var lblUserInfo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let userEmail = userDefaults.objectForKey("user_email") as! String
        
        lblUserInfo.text = "You are logged in as: \n" + userEmail
    }
    


    @IBAction func onPressLogOut(sender: AnyObject) {
        PFUser.logOut()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject("", forKey: "user_email")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func exportCSV(sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() == false
        {
            return
        }
        
        let mailController = MFMailComposeViewController()
        mailController.setSubject("Export CSV")
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let user_email = userDefaults.objectForKey("user_email")?.description ?? ""
        mailController.setToRecipients([user_email]);
        mailController.mailComposeDelegate = self
        if let url = logFileURL
        {
            if let data = NSData(contentsOfURL: url)
            {
                let mimeType = "text/csv"
                let fileName = url.lastPathComponent!
                mailController.addAttachmentData(data, mimeType: mimeType, fileName: fileName)
            }
        }
        self.presentViewController(mailController, animated: false, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?)
    {
        controller.dismissViewControllerAnimated( true, completion: nil)
    }
}

