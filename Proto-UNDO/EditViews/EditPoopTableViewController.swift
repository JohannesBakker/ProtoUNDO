//
//  EditPoopTableViewController.swift
//  EditPoop
//
//  Created by Marko on 10/22/15.
//  Copyright © 2015 Marko. All rights reserved.
//

import UIKit

enum kEditPoopContentCell : Int {
    case SeperateStart = 0
    case Time               // 1
    case DateTimePicker     // 2
    case SeperateDesription // 3
    case DisplayDescription // 4
    case SeperateOptions    // 5
    case OptionsJustPoop    // 6
    case OptionsNewbornPoop // 7
    case OptionsBreastfedPoop // 8
    case OptionsFomulafedPoop // 9
    case OptionsSolidsfedPoop // 10
    case OptionsDiarrheaPoop  // 11
    case SeperateTag        // 12
    case StarOrExclamation  // 13
    case SeperateNotePhoto  // 14
    case Camera             // 15
    case SeperateDelete     // 16
    case Delete             // 17
}


class EditPoopTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let NVItemCancelColor:UIColor = UIColor(red:255.0/255.0, green:59.0/255.0, blue:48.0/255.0, alpha:1.0) // #FF3B30
    let NVItemDefaultColor:UIColor = UIColor(red:0.0/255.0, green:122.0/255.0, blue:255.0/255.0, alpha:1.0) // #007AFF
    
    
    let justPoop = PoopDetailItem(itemIndex: PoopMoreSettingData.PoopOptions.Just.rawValue,
        name: "Just Poop", hasDesc: false, color: "", texture: "", analogy: "", stinkFactor: 0)
    
    let newbornPoop = PoopDetailItem(itemIndex: PoopMoreSettingData.PoopOptions.Newborn.rawValue,
        name: "Newborn Poop", hasDesc: true, color: "greenish-black or similar",
        texture: "sticky", analogy: "think 'tar' or 'motor oil'", stinkFactor: 0)
    
    let breastfedPoop = PoopDetailItem(itemIndex: PoopMoreSettingData.PoopOptions.Breastfed.rawValue,
        name: "Breastfed Poop", hasDesc: true, color: "yello or yellow-green or similar",
        texture: "mushy, creamy", analogy: "think 'curdled milk or cottage cheese with mustard ... and maybe seeds'", stinkFactor: 1)
    
    
    let formulafedPoop = PoopDetailItem(itemIndex: PoopMoreSettingData.PoopOptions.Formularfed.rawValue,
        name: "Formula-fed Poop", hasDesc: true, color: "tan or brown or green-brown or similar",
        texture: "pasty", analogy: "think 'hummus or peanut butter'", stinkFactor: 2)
    
    
    let solidsfedPoop = PoopDetailItem(itemIndex: PoopMoreSettingData.PoopOptions.Solidsfed.rawValue,
        name: "Solids-fed Poop", hasDesc: true, color: "greenish-brown or yellow-brown or yellow-green or similar",
        texture: "pasty but thicker", analogy: "think 'old guacamole'", stinkFactor: 3)
    
    let diarrhea = PoopDetailItem(itemIndex: PoopMoreSettingData.PoopOptions.Diarrhea.rawValue,
        name: "Diarrhea", hasDesc: false, color: "", texture: "", analogy: "", stinkFactor: 0)
    

    var logEvent: LogEvent!
    var mSelectedIndex: NSInteger! = 0
    var settingData:PoopMoreSettingData = PoopMoreSettingData()
    
    var bIsVisibleTimePicker:Bool = false
    var bIsDisplayDescriptions:Bool = false
    
    // Activity Indicator
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    var initTime:NSDate?
    

    
    //===============================================
    
    @IBOutlet weak var lblTimeResult: UILabel!
    
    @IBOutlet weak var lblTimeNotSet: UILabel!
    
    @IBOutlet weak var lblTimeEdit: UILabel!
    
    @IBOutlet weak var btnClearTime: UIButton!
    
    //============================================
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // ==========================================
    
    
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var memoTextInput: UITextField!
    @IBOutlet weak var memoImageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnDelete: UIButton!
    
    //=============================================
    
    @IBOutlet weak var btnStar: UIButton!
    
    @IBOutlet weak var btnExclamation: UIButton!
    
    @IBOutlet weak var imgStar: UIImageView!
    
    @IBOutlet weak var imgExclamation: UIImageView!
    
    @IBOutlet weak var swNotJustNow: UISwitch!
    
    @IBOutlet weak var swOptionsJust: MyCheckBox!
    
    @IBOutlet weak var swOptionsNewborn: MyCheckBox!
    
    @IBOutlet weak var swOptionsBreastfed: MyCheckBox!
    
    @IBOutlet weak var swOptionsFormulafed: MyCheckBox!
    
    @IBOutlet weak var swOptionsSolidsfed: MyCheckBox!
    
    @IBOutlet weak var swOptionsDiarrhea: MyCheckBox!
    
    
    //===============================================
    
    func dataChanged()
    {
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dataChanged", name: kLogObjectUpdatedNotification, object: nil)
        
        datePicker.addTarget(self, action: "datePickerValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        if settingData.timePoop == nil {
            initTime = NSDate.init()
        }
        else {
            initTime = settingData.timePoop
        }
        
        if logEvent.action.isEqualToString("diarrhea") {
            settingData.optPoop = PoopMoreSettingData.PoopOptions.Diarrhea
        }
        
        // by Marko
        // Update UIs according the settings Data
        memoTextInput.text = settingData.strNoteText
        memoTextInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        memoTextInput.delegate = self
        
        // change Navigation Item color
        btnSave.tintColor = NVItemDefaultColor
        btnCancel.tintColor = NVItemCancelColor
        
        // change Delete button
        btnDelete.clipsToBounds = true
        btnDelete.layer.cornerRadius = 13
        
        // change Navigation Title
        self.title = "Poop Edit"
        
        lblTimeNotSet.hidden = true
        lblTimeResult.hidden = false
        
        RefreshPoopOptions()
        
        SetStar(settingData.bIsSelectedStar)
        SetExclamation(settingData.bIsSelectedExclamation)
        
        // Load Image from Parse
        logEvent.getImage{ (image: UIImage?, error : NSError?) -> Void in
            
            if image == nil || error != nil {
                
            }
            else {
                self.memoImageView.image = image!
                
                self.imageViewHeightConstraint.constant = 120
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
                
                self.tableView.reloadData()
            }
        }
        
        refreshDatePicker(false)
        refreshViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - View life cycle
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden=false
    }
    
    //===============================================
    
    
    @IBAction func OnTappedClearTime(sender: UIButton) {
        settingData.timePoop = initTime
        refreshDatePicker(false)
    }
    
    @IBAction func OnExclamationTapped(sender: UIButton) {
        SetExclamation(!settingData.bIsSelectedExclamation)
    }
    
    @IBAction func OnStarTapped(sender: UIButton) {
        SetStar(!settingData.bIsSelectedStar)
    }
    
    @IBAction func OnChangedNotJustNow(sender: UISwitch) {
        settingData.bIsNotJustNow = sender.on
        if !sender.on {
            settingData.timePoop = initTime
            refreshDatePicker(false)
        }
        else {
            refreshDatePicker(true)
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func OnChangedDisplayDescriptions(sender: UISwitch) {
        bIsDisplayDescriptions = sender.on
        self.tableView.reloadData()
        
        settingData.bDisplayDescription = bIsDisplayDescriptions
    }
    
    @IBAction func onTapCancel(sender: AnyObject) {
        
        memoTextInput.resignFirstResponder()
        dismiss()
    }
    
    @IBAction func onTapSave(sender: AnyObject) {
        
        // save functions
        // Convert SettinsData to LogEvent
        logEvent.noteTime = settingData.timePoop
        logEvent.displayDesc = settingData.bDisplayDescription
        logEvent.starMark = settingData.bIsSelectedStar
        logEvent.exclamationMark = settingData.bIsSelectedExclamation
        logEvent.optValue = settingData.optPoop.rawValue
        logEvent.image = settingData.memoImage
        
        // Assign Text
        if let text = memoTextInput.text {
            settingData.strNoteText = text
        }
        else {
            settingData.strNoteText = ""
        }
        logEvent.note = settingData.strNoteText
        
        // detail save
        let detailItem:PoopDetailItem? = getPoopDetailItem(settingData.optPoop.rawValue)
        
        if detailItem != nil {
            logEvent.detailName = detailItem?.name
            
            if detailItem?.hasDesc == true {
                logEvent.detailColor = detailItem?.color
                logEvent.detailTexture = detailItem?.texture
                logEvent.detailAnalogy = detailItem?.analogy
                logEvent.detailStink = detailItem?.stinkFactor
            }
        }
        
        
        // Add activity indicator
        activityIndicator.center = self.tableView.center
        activityIndicator.color = UIColor.redColor()
        tableView.addSubview(activityIndicator)
        
        // Save data to Parse
        DataSource.sharedDataSouce.updateEventWithIndex(self.mSelectedIndex, logEvent: logEvent)
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
//        activityIndicator.startAnimating()
    }
    
    @IBAction func onTapCamera(sender: AnyObject) {
        
        memoTextInput.resignFirstResponder()
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let photoAction = UIAlertAction(title: "Take a Photo", style:.Default){ (action) in self.takePhoto()}
        alertVC.addAction(photoAction)
        let chooseAction = UIAlertAction(title: "Choose Existing", style:.Default){ (action) in self.getExisting()}
        alertVC.addAction(chooseAction)
        let cancelAction = UIAlertAction(title: "Cancel", style:.Destructive){ (action) in}
        alertVC.addAction(cancelAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func onTapDelete(sender: AnyObject) {
        let alert = UIAlertController(title: "Confirm", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (ACTION :UIAlertAction!) in
            
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!)in
            DataSource.sharedDataSouce.deleteEventWithIndex(self.mSelectedIndex)
            //   self.activityIndicator.startAnimating()
            delay(1, closure: { () -> () in
                //self.navigationController?.popToRootViewControllerAnimated(true)
                self.navigationController?.popViewControllerAnimated(true)
            })
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    //===============================================
    
    
    
    func datePickerValueChanged(sender: UIDatePicker)
    {
        lblTimeResult.text = getDateFormat(datePicker.date)
        settingData.timePoop = datePicker.date
        logEvent.time = datePicker.date.timeIntervalSinceReferenceDate
    }
    
    func getDateFormat(selectedTime:NSDate) -> String
    {
        let dateFormatter = NSDateFormatter()
        var text : String = ""
        if NSCalendar.currentCalendar().isDateInToday(selectedTime) {
            dateFormatter.dateFormat = "h:mm a"
            text = "Today " + dateFormatter.stringFromDate(selectedTime).lowercaseString
//            text = dateFormatter.stringFromDate(selectedTime).lowercaseString
        }else if NSCalendar.currentCalendar().isDateInTomorrow(selectedTime) {
            dateFormatter.dateFormat = "h:mm a"
            text = "Tomorrow " + dateFormatter.stringFromDate(selectedTime).lowercaseString
        }else if NSCalendar.currentCalendar().isDateInYesterday(selectedTime) {
            dateFormatter.dateFormat = "h:mm a"
            text = "Yesterday " + dateFormatter.stringFromDate(selectedTime).lowercaseString
        }else {
            dateFormatter.dateFormat = "MM/dd/yy h:mm a"
            text = dateFormatter.stringFromDate(selectedTime).lowercaseString
        }
        return text
    }
    
    func refreshDatePicker(isExpand:Bool) {
        let t = settingData.timePoop
        lblTimeResult.text = getDateFormat(t!)
        
        datePicker.setDate(t!, animated: true)
        bIsVisibleTimePicker = isExpand
    }
    
    func refreshViews() {
        tableView.reloadData()
    }
    
    func SetStar(isSel:Bool) {
        if isSel {
            btnStar.setImage(UIImage(named: "star_background_a.png"), forState: UIControlState.Normal)
            imgStar.image=UIImage(named: "star_Large_a.png")
            
            SetExclamation(false)
        }else{
            btnStar.setImage(UIImage(named: "a.png"), forState: UIControlState.Normal)
            imgStar.image=UIImage(named: "star_Large.png")
        }
        settingData.bIsSelectedStar = isSel
    }
    
    func SetExclamation(isSel:Bool) {
        if isSel {
            btnExclamation.setImage(UIImage(named: "exclamation_background_a.png"), forState: UIControlState.Normal)
            imgExclamation.image=UIImage(named: "exclamation_Large_a.png")
            SetStar(false)
        }else{
            btnExclamation.setImage(UIImage(named: "a.png"), forState: UIControlState.Normal)
            imgExclamation.image=UIImage(named: "exclamation_Large.png")
        }
        settingData.bIsSelectedExclamation = isSel
    }
    
    
    func RefreshPoopOptions() {
        swOptionsJust.isChecked = settingData.optPoop == PoopMoreSettingData.PoopOptions.Just
        swOptionsNewborn.isChecked = settingData.optPoop == PoopMoreSettingData.PoopOptions.Newborn
        swOptionsBreastfed.isChecked = settingData.optPoop == PoopMoreSettingData.PoopOptions.Breastfed
        swOptionsFormulafed.isChecked = settingData.optPoop == PoopMoreSettingData.PoopOptions.Formularfed
        swOptionsSolidsfed.isChecked = settingData.optPoop == PoopMoreSettingData.PoopOptions.Solidsfed
        swOptionsDiarrhea.isChecked = settingData.optPoop == PoopMoreSettingData.PoopOptions.Diarrhea
        self.tableView.reloadData()
    }
    
    func selectPoop(optSelectPoop: PoopMoreSettingData.PoopOptions) {
        
        if settingData.optPoop == optSelectPoop {
            settingData.optPoop = PoopMoreSettingData.PoopOptions.None
        }
        else {
            settingData.optPoop = optSelectPoop
        }
        RefreshPoopOptions()
    }
    
    func getPoopDetailItem(index: Int) ->PoopDetailItem? {
        let itemArray:[PoopDetailItem] = [justPoop, newbornPoop, breastfedPoop, formulafedPoop, solidsfedPoop, diarrhea]
        
        if index >= 0 && index < itemArray.count {
            return itemArray[index]
        }
        
        return nil
    }
    
    func dismiss() {
        navigationController?.popViewControllerAnimated(true)
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
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        picker.dismissViewControllerAnimated(true, completion: nil)
        let original = info[UIImagePickerControllerOriginalImage] as? UIImage
        memoImageView.image = original
        if memoImageView.image != nil {
            
            settingData.memoImage = memoImageView.image
            
            if imageViewHeightConstraint.constant == 0 {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.imageViewHeightConstraint.constant = 120
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                    
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    func setSettingsData(logData: LogEvent!) {
        logEvent = logData
        
        // convert LogEvent to PoopMoreSettingData
        
        settingData.bIsNotJustNow = logEvent.bIsJustNow
        settingData.timePoop = logEvent.noteTime
        if settingData.timePoop == nil {
            settingData.timePoop = NSDate.init()
        }
        settingData.bDisplayDescription = logEvent.displayDesc
        
        settingData.bIsSelectedStar = logEvent.starMark
        settingData.bIsSelectedExclamation = logEvent.exclamationMark
        
        var optValue:Int! = 0
        if logEvent.optValue != nil {
            optValue = logEvent.optValue
        }
        if (optValue < PoopMoreSettingData.PoopOptions.None.rawValue)
            || (optValue > PoopMoreSettingData.PoopOptions.Diarrhea.rawValue) {
                optValue = PoopMoreSettingData.PoopOptions.Just.rawValue
        }
        
        settingData.optPoop = PoopMoreSettingData.PoopOptions(rawValue: optValue)
        
        if let note = logEvent.note {
            settingData.strNoteText = note
        }
        
        // TODO memo image
        settingData.memoImage = nil     // ???
    }
    
    //===============================================
    //      UITableView Deelgate
    //===============================================
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //       return UITableViewAutomaticDimension
        
        let currCell:kEditPoopContentCell = kEditPoopContentCell(rawValue: indexPath.row)!
        
        switch(currCell)
        {
        case .Time:
            return 45
            
        case .DateTimePicker:
            if bIsVisibleTimePicker == false {
                return 0
            }
            return 160
            
        case .DisplayDescription:
            return 45
            
        case .SeperateOptions:
            return 25
            
        case .OptionsJustPoop:
            return 45
            
        case .OptionsNewbornPoop:
            if bIsDisplayDescriptions{
                return 225
            }
            return 45
            
        case .OptionsBreastfedPoop:
            if bIsDisplayDescriptions{
                return 225
            }
            return 45
            
        case .OptionsFomulafedPoop:
            if bIsDisplayDescriptions{
                return 225
            }
            return 45
            
        case .OptionsSolidsfedPoop:
            if bIsDisplayDescriptions{
                return 225
            }
            return 45
            
        case .OptionsDiarrheaPoop:
            return 45
            
        case .StarOrExclamation:
            return 96
            
        case .Camera:
            // add Marko
            if settingData.memoImage != nil {
                return 170
            }
            return 45
            
        case .SeperateDelete:
            return 35
            
        case .Delete:
            return 57
            
        default:
            return 20
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let currCell:kEditPoopContentCell = kEditPoopContentCell(rawValue: indexPath.row)!
        
        if currCell == .Time {
            if bIsVisibleTimePicker {
                settingData.timePoop = datePicker.date
            }
            refreshDatePicker(!bIsVisibleTimePicker)
        }
        
        if currCell == .OptionsJustPoop {
            selectPoop(PoopMoreSettingData.PoopOptions.Just)
        }
        
        if currCell == .OptionsNewbornPoop {
            selectPoop(PoopMoreSettingData.PoopOptions.Newborn)
        }
        
        if currCell == .OptionsBreastfedPoop {
            selectPoop(PoopMoreSettingData.PoopOptions.Breastfed)
        }
        
        if currCell == .OptionsFomulafedPoop {
            selectPoop(PoopMoreSettingData.PoopOptions.Formularfed)
        }
        
        if currCell == .OptionsSolidsfedPoop {
            selectPoop(PoopMoreSettingData.PoopOptions.Solidsfed)
        }
        
        if currCell == .OptionsDiarrheaPoop {
            selectPoop(PoopMoreSettingData.PoopOptions.Diarrhea)
        }
        
        refreshViews()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
        
    }
    
    //===================================================

    
    
    //===================================================
    //      UITextField Delegate
    //===================================================
    func textFieldDidChange(textField: UITextField) {
        
        settingData.strNoteText = textField.text!
    }
    
    // UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
