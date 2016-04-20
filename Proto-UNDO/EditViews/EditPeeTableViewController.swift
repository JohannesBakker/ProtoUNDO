//
//  PeeMoreTableViewController.swift
//  PeeMore
//
//  Created by Lee Xiaoxiao on 9/26/15.
//  Copyright © 2015 Lee Xiaoxiao. All rights reserved.
//

import UIKit


enum kEditPeeContentCell : Int {
    case SeperateStart = 0
    case NotJustNow         // 1
    case Time               // 2
    case DateTimePicker     // 3
    case SeperateDesription // 4
    case DisplayDescription // 5
    case SeperateOptions    // 6
    case OptionsJustPee     // 7
    case OptionsOrrangePee  // 8
    case OptionsLighterOrrangePee // 9
    case OptionsBrightYellowToOrrangePee // 10
    case OptionsBrightLemonyPee // 11
    case OptionsPaleYello  // 12
    case SeperateTag        // 13
    case StarOrExclamation  // 14
    case SeperateNotePhoto  // 15
    case Camera             // 16
    case SeperateDelete     // 17
    case Delete             // 18
}



class EditPeeTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let NVItemCancelColor:UIColor = UIColor(red:255.0/255.0, green:59.0/255.0, blue:48.0/255.0, alpha:1.0) // #FF3B30
    let NVItemDefaultColor:UIColor = UIColor(red:0.0/255.0, green:122.0/255.0, blue:255.0/255.0, alpha:1.0) // #007AFF
    
    let justPee = PeeDetailItem(itemIndex: PeeMoreSettingData.PeeOptions.Just.rawValue,
        name: "Just Pee", hasDesc: false,
        analogy: "")
    
    let orangeColorPee = PeeDetailItem(itemIndex: PeeMoreSettingData.PeeOptions.Orange.rawValue,
        name: "Orange Color Pee", hasDesc: true,
        analogy: "Your baby will probably only urinate 1x on day 1, and it will be orange.")
    
    let LighterOrangePee = PeeDetailItem(itemIndex: PeeMoreSettingData.PeeOptions.LighterOrange.rawValue,
        name: "Orange, but a lighter Orange Pee", hasDesc: true,
        analogy: "Around day 2, the pee will be a lighter shade of orange.")
    
    let brightYellowToPee = PeeDetailItem(itemIndex: PeeMoreSettingData.PeeOptions.BrightYellowToOrange.rawValue,
        name: "Bright Yellow to Orange Pee", hasDesc: true,
        analogy: "Typically, around day 3, a healthy infant's pee starts to become less orange and more a bright yellow.")
    
    let brightLemonyPee = PeeDetailItem(itemIndex: PeeMoreSettingData.PeeOptions.BrightLemony.rawValue,
        name: "Bright Lemony Color Pee", hasDesc: true,
        analogy: "Typically starts on day 4.")
    
    let paleYellowPee = PeeDetailItem(itemIndex: PeeMoreSettingData.PeeOptions.PaleYello.rawValue,
        name: "Pale Yellow Color Pee", hasDesc: true,
        analogy: "Starts becoming pale yellow color around days 6 - 8; This is the color we normally expect to see when we think about pee.")
    
    //===============================================

    var logEvent: LogEvent!
    var mSelectedIndex: NSInteger! = 0
    var settingData:PeeMoreSettingData = PeeMoreSettingData()
    
    var bIsVisibleTimePicker:Bool = false
    var bIsDisplayDescriptions:Bool = false
    
    var initTime:NSDate?
    
    var bItemChanged:Bool = false
    
    // Activity Indicator
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)

    
    //===============================================
    
    @IBOutlet weak var lblTimeResult: UILabel!
    
    @IBOutlet weak var lblTimeNotSet: UILabel!
    
    @IBOutlet weak var lblTimeEdit: UILabel!
    
    @IBOutlet weak var btnClearTime: UIButton!
    
    @IBOutlet weak var btnStar: UIButton!
    
    @IBOutlet weak var btnExclamation: UIButton!
    
    @IBOutlet weak var imgStar: UIImageView!
    
    @IBOutlet weak var imgExclamation: UIImageView!
    
    @IBOutlet weak var swNotJustNow: UISwitch!
    
    @IBOutlet weak var swOptionsJust: MyCheckBox!
    
    @IBOutlet weak var swOptionsOrange: MyCheckBox!
    
    @IBOutlet weak var swOptionsLighterOrange: MyCheckBox!
    
    @IBOutlet weak var swOptionsBrightYelloToOrange: MyCheckBox!
    
    @IBOutlet weak var swOptionsBrightLemony: MyCheckBox!
    
    @IBOutlet weak var swOptionsPaleYello: MyCheckBox!

    
    //============================================
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var memoTextInput: UITextField!
    @IBOutlet weak var memoImageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnDelete: UIButton!

    
    // ==========================================
    
    func dataChanged()
    {
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dataChanged", name: kLogObjectUpdatedNotification, object: nil)
        
        datePicker.addTarget(self, action: "datePickerValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        if settingData.timePee == nil {
            initTime = NSDate.init()
        }
        else {
            initTime = settingData.timePee
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
        self.title = "Pee Edit"
        
        lblTimeNotSet.hidden = true
        lblTimeResult.hidden = false
        
        RefreshPeeOptions()
        
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
        settingData.timePee = initTime
        refreshDatePicker(false)
    }
    
    @IBAction func OnStarTapped(sender: UIButton) {
        SetStar(!settingData.bIsSelectedStar)
    }
    
    @IBAction func OnExclamationTapped(sender: UIButton) {
        SetExclamation(!settingData.bIsSelectedExclamation)
    }
    
    @IBAction func OnChangedNotJustNow(sender: UISwitch) {
        settingData.bIsNotJustNow = sender.on
        if !sender.on {
            settingData.timePee = initTime
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
        
        // Marko
        settingData.bDisplayDescription = bIsDisplayDescriptions
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
    
    @IBAction func onTapCancel(sender: AnyObject) {
        
        
        memoTextInput.resignFirstResponder()
        dismiss()
    }

    
    @IBAction func onTapSave(sender: AnyObject) {
        
        // save functions
        // Convert SettinsData to LogEvent
        logEvent.bIsJustNow = settingData.bIsNotJustNow
        logEvent.noteTime = settingData.timePee
        logEvent.displayDesc = settingData.bDisplayDescription
        logEvent.starMark = settingData.bIsSelectedStar
        logEvent.exclamationMark = settingData.bIsSelectedExclamation
        logEvent.optValue = settingData.optPee.rawValue
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
        let detailItem:PeeDetailItem? = getPeeDetailIem(settingData.optPee.rawValue)
        
        if detailItem != nil {
            logEvent.detailName = detailItem?.name
            
            if detailItem?.hasDesc == true && settingData.bDisplayDescription {
                logEvent.detailAnalogy = detailItem?.analogy
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
    
    @IBAction func onTapDelete(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Confirm", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (ACTION :UIAlertAction!) in
            
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!)in
            DataSource.sharedDataSouce.deleteEventWithIndex(self.mSelectedIndex)
            //   self.activityIndicator.startAnimating()
            delay(1, closure: { () -> () in
//                self.navigationController?.popToRootViewControllerAnimated(true)
                self.navigationController?.popViewControllerAnimated(true)
            })
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //===============================================

    
    
    func datePickerValueChanged(sender: UIDatePicker)
    {
        lblTimeResult.text = getDateFormat(datePicker.date)
        logEvent.time = datePicker.date.timeIntervalSinceReferenceDate
        settingData.timePee = datePicker.date
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
    

    func refreshDatePicker(isExpand:Bool){
        
        let t = settingData.timePee
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
    
    
    func RefreshPeeOptions() {
        swOptionsJust.isChecked = settingData.optPee == PeeMoreSettingData.PeeOptions.Just
        swOptionsOrange.isChecked = settingData.optPee == PeeMoreSettingData.PeeOptions.Orange
        swOptionsLighterOrange.isChecked = settingData.optPee == PeeMoreSettingData.PeeOptions.LighterOrange
        swOptionsBrightYelloToOrange.isChecked = settingData.optPee == PeeMoreSettingData.PeeOptions.BrightYellowToOrange
        swOptionsBrightLemony.isChecked = settingData.optPee == PeeMoreSettingData.PeeOptions.BrightLemony
        swOptionsPaleYello.isChecked = settingData.optPee == PeeMoreSettingData.PeeOptions.PaleYello
        self.tableView.reloadData()
    }
    
    func selectPee(optSelectPee: PeeMoreSettingData.PeeOptions) {
        
        if settingData.optPee == optSelectPee {
            settingData.optPee = PeeMoreSettingData.PeeOptions.None
        }
        else {
            settingData.optPee = optSelectPee
        }
        RefreshPeeOptions()
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
        settingData.timePee = logEvent.noteTime
        if settingData.timePee == nil {
            settingData.timePee = NSDate.init()
        }
        settingData.bDisplayDescription = logEvent.displayDesc
        
        settingData.bIsSelectedStar = logEvent.starMark
        settingData.bIsSelectedExclamation = logEvent.exclamationMark
        
        var optValue:Int! = 0
        if logEvent.optValue != nil {
            optValue = logEvent.optValue
        }
        if (optValue < PeeMoreSettingData.PeeOptions.None.rawValue)
            || (optValue > PeeMoreSettingData.PeeOptions.PaleYello.rawValue) {
                optValue = PeeMoreSettingData.PeeOptions.Just.rawValue
        }
        
        settingData.optPee = PeeMoreSettingData.PeeOptions(rawValue: optValue)
        
        if let note = logEvent.note {
            settingData.strNoteText = note
        }
        
        // TODO memo image
        settingData.memoImage = nil     // ???
    }
    
    func getPeeDetailIem(index: Int) ->PeeDetailItem? {
        let itemArray:[PeeDetailItem] = [justPee, orangeColorPee, LighterOrangePee, brightYellowToPee, brightLemonyPee, paleYellowPee]
        
        if index >= 0 && index < itemArray.count {
            return itemArray[index]
        }
        
        return nil
    }
    
    
    //===============================================
    
    
    
    
    //===============================================
    //      UITableView Deelgate
    //===============================================

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let currCell:kEditPeeContentCell = kEditPeeContentCell(rawValue: indexPath.row)!
        
        switch(currCell)
        {
        case .NotJustNow:
            return 0
            
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
            
        case .OptionsJustPee:
            return 45
            
        case .OptionsOrrangePee:
            if bIsDisplayDescriptions{
                return 90
            }
            return 45
            
        case .OptionsLighterOrrangePee:
            if bIsDisplayDescriptions{
                return 90
            }
            return 45
            
        case .OptionsBrightYellowToOrrangePee:
            if bIsDisplayDescriptions{
                return 90
            }
            return 45
            
        case .OptionsBrightLemonyPee:
            if bIsDisplayDescriptions{
                return 90
            }
            return 45
            
        case .OptionsPaleYello:
            if bIsDisplayDescriptions{
                return 90
            }
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
        
        let currCell:kEditPeeContentCell = kEditPeeContentCell(rawValue: indexPath.row)!

        if currCell == .Time {
            if bIsVisibleTimePicker {
                settingData.timePee = datePicker.date
            }
            refreshDatePicker(!bIsVisibleTimePicker)
        }
        
        if currCell == .OptionsJustPee {
            selectPee(PeeMoreSettingData.PeeOptions.Just)
        }

        if currCell == .OptionsOrrangePee {
            selectPee(PeeMoreSettingData.PeeOptions.Orange)
        }
        
        if currCell == .OptionsLighterOrrangePee {
            selectPee(PeeMoreSettingData.PeeOptions.LighterOrange)
        }
        
        if currCell == .OptionsBrightYellowToOrrangePee {
            selectPee(PeeMoreSettingData.PeeOptions.BrightYellowToOrange)
        }
        
        if currCell == .OptionsBrightLemonyPee {
            selectPee(PeeMoreSettingData.PeeOptions.BrightLemony)
        }
        
        if currCell == .OptionsPaleYello {
            selectPee(PeeMoreSettingData.PeeOptions.PaleYello)
        }
        
        refreshViews()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
      
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
        /*
        if cell.respondsToSelector(Selector("setSeparatorInset:")) {
            
            switch indexPath.row {
            case 1:
                if !settingData.bIsNotJustNow {
                    cell.separatorInset = UIEdgeInsets(top:0,left:0,bottom:0,right:0)
                }
                else
                {
                    cell.separatorInset = UIEdgeInsets(top:0,left:15,bottom:0,right:0)
                }
            case 2:
                if bIsVisibleTimePicker == false || !settingData.bIsNotJustNow {
                    cell.separatorInset = UIEdgeInsets(top:0,left:0,bottom:0,right:0)
                }
                else
                {
                    cell.separatorInset = UIEdgeInsets(top:0,left:15,bottom:0,right:0)
                }
            default:
                return
            }
        }
*/
        
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