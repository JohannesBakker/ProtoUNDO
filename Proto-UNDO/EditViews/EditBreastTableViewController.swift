//
//  BothMoreTableViewController.swift
//  BothMore
//
//  Created by Lee Xiaoxiao on 9/26/15.
//  Copyright © 2015 Lee Xiaoxiao. All rights reserved.
//

import UIKit

enum kEditBreastContentCell : Int {
    
    case SeperateStart = 0
    case NotNustNow         // 1
    case LeftRight          // 2
    case TimeBoth           // 3
    case DateTimePicker     // 4
    case DurationNoExpand   // 5
    case DurationExpand     // 6
    case DurationNoExpandNotJustNow     // 7
    case DurationExpandNotJustNow       // 8
    case SeperateBell       // 9
    case Bell               // 10
    case SeperateTag        // 11
    case StarOrExclamation  // 12
    case SeperateNotePhoto  // 13
    case Camera             // 14
    case SeperateDelete     // 15
    case Delete             // 16
}


class EditBreastTableViewController: UITableViewController,  UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate  {

    let NVItemCancelColor:UIColor = UIColor(red:255.0/255.0, green:59.0/255.0, blue:48.0/255.0, alpha:1.0) // #FF3B30
    let NVItemDefaultColor:UIColor = UIColor(red:0.0/255.0, green:122.0/255.0, blue:255.0/255.0, alpha:1.0) // #007AFF

    //===============================================
    
    var logEvent: LogEvent!
    var mSelectedIndex: NSInteger! = 0
    var settingData:BothMoreSettingData = BothMoreSettingData()
    
    var bIsVisibleTimePicker:Bool = false
    var bIsExpandedDuration:Bool = false
    var bIsLeft:Bool = true
    
    var oldState = 0
    var initLeftTime:NSDate?
    var initRightTime:NSDate?
    
    var bItemChanged:Bool = false
    
    // Activity Indicator
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    //===============================================
    
    var optAction:BothMoreSettingData.BreastActions! = .ActLeft

    
    //===============================================
    
    @IBOutlet weak var lblTimeBothText: UILabel!
    
    @IBOutlet weak var lblTimeResult: UILabel!
    
    @IBOutlet weak var lblTimeNotSet: UILabel!
    
    @IBOutlet weak var lblTimeEdit: UILabel!
    
    @IBOutlet weak var btnClearTime: UIButton!
    
    //============================================
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    //============================================
    
    @IBOutlet weak var lblDuration1: UILabel!
    
    @IBOutlet weak var lblPickerResult: UILabel!
    
    @IBOutlet weak var lblPickerNotSet1: UILabel!
    
    //============================================
    
    @IBOutlet weak var lblDuration2: UILabel!

    @IBOutlet weak var lblPickerNotSet2: UILabel!

    @IBOutlet weak var lblPickerEdit: UILabel!
    
    @IBOutlet weak var btnClearPicker: UIButton!
    
    //============================================
    
    @IBOutlet weak var pickerHours: UIPickerView!
    
    @IBOutlet weak var pickerMinutes: UIPickerView!
    
    @IBOutlet weak var btnStar: UIButton!
    
    @IBOutlet weak var btnExclamation: UIButton!
    
    @IBOutlet weak var imgStar: UIImageView!
    
    @IBOutlet weak var imgExclamation: UIImageView!
    
    @IBOutlet weak var lblDurationInfo1: UILabel!
    
    @IBOutlet weak var lblDurationInfo2: UILabel!
    
    @IBOutlet weak var swNotJustNow: UISwitch!
    
    @IBOutlet weak var lblDurationReady1: UILabel!
    @IBOutlet weak var lblDurationReady2: UILabel!
    
    @IBOutlet weak var vwNeededBorder1: UIView!
    
    @IBOutlet weak var vwNeededBorder2: UIView!
    
    //===============================================
    // Marko
    //===============================================
    
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var breastTextInput: UITextField!
    @IBOutlet weak var breastImageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    
    //============================================
    
    @IBOutlet weak var lblDurationJust: UILabel!
    
    @IBOutlet weak var lblPickerResultJust: UILabel!
    
    @IBOutlet weak var lblPickerNotSetJust: UILabel!
    
    //============================================
    
    @IBOutlet weak var lblDurationJustExpand: UILabel!
    
    @IBOutlet weak var lblPickerNotSetJustExpand: UILabel!
    
    @IBOutlet weak var lblPickerEditJustExpand: UILabel!
    
    @IBOutlet weak var btnClearPickerJustExpand: UIButton!
    
    //============================================
    
    @IBOutlet weak var pickerHoursJust: UIPickerView!
    
    @IBOutlet weak var pickerMinutesJust: UIPickerView!
    
    @IBOutlet weak var vwNeededBorder3: UIView!
    
    @IBOutlet weak var segLeftRightSelector:UISegmentedControl!
    
    @IBOutlet weak var btnDelete: UIButton!
    
    //===============================================
    
    func dataChanged()
    {
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dataChanged", name: kLogObjectUpdatedNotification, object: nil)
        
        initSettingData()
        
        pickerHours.delegate = self
        pickerHours.dataSource = self
        
        pickerMinutes.delegate = self
        pickerMinutes.dataSource = self
        
        if settingData.timeLeft != nil {
            initLeftTime = NSDate(timeInterval: 0, sinceDate: settingData.timeLeft!)
        }
        else {
            initLeftTime = NSDate.init()
            settingData.timeLeft = NSDate(timeInterval: 0, sinceDate: initLeftTime!)
        }
        
        if settingData.timeRight != nil {
            initRightTime = NSDate(timeInterval: 0, sinceDate: settingData.timeRight!)
        }
        else {
            initRightTime = NSDate.init()
            settingData.timeRight = NSDate(timeInterval: 0, sinceDate: initRightTime!)
        }
        
        // change Navigation Item color
        btnSave.tintColor = NVItemDefaultColor
        btnCancel.tintColor = NVItemCancelColor
        
        // change Delete button
        btnDelete.clipsToBounds = true
        btnDelete.layer.cornerRadius = 13
        
        
        lblTimeNotSet.hidden = true
        lblTimeResult.hidden = false
        
        lblPickerNotSetJust.hidden = true
        lblPickerNotSetJustExpand.hidden = true
        lblPickerResultJust.hidden = false

        
        datePicker.addTarget(self, action: "datePickerValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        vwNeededBorder1.layer.borderWidth = 0.5
        vwNeededBorder1.layer.borderColor = UIColor(red: 224/255.0, green: 224/255.0, blue: 224/255.0, alpha: 1.0).CGColor
        
        vwNeededBorder2.layer.borderWidth = 0.5
        vwNeededBorder2.layer.borderColor = UIColor(red: 224/255.0, green: 224/255.0, blue: 224/255.0, alpha: 1.0).CGColor
        
        // by Marko
        // Update UIs according the settings Data
        
        initBreastUIs()
        
        pickerHoursJust.delegate = self
        pickerHoursJust.dataSource = self
        
        pickerMinutesJust.delegate = self
        pickerMinutesJust.dataSource = self
        
        vwNeededBorder3.layer.borderWidth = 0.5
        vwNeededBorder3.layer.borderColor = UIColor(red: 224/255.0, green: 224/255.0, blue: 224/255.0, alpha: 1.0).CGColor
        
        breastTextInput.text = settingData.strNoteText;
        breastTextInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        breastTextInput.delegate = self
        
        SetStar(settingData.bIsSelectedStar)
        SetExclamation(settingData.bIsSelectedExclamation)
        
        // Load Image from Parse
        logEvent.getImage{ (image: UIImage?, error : NSError?) -> Void in
            
            if image == nil || error != nil {
                
            }
            else {
                self.breastImageView.image = image!
                self.imageViewHeightConstraint.constant = 120
                self.view.layoutIfNeeded()
                self.tableView.reloadData()
            }
        }
        
        refreshDatePicker(false)
        refreshViewPicker(false)
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
    

    
    // ==========================================
    
    
    
    @IBAction func OnTappedClearTime(sender: UIButton) {
        if bIsLeft{
            settingData.timeLeft = initLeftTime
        }else{
            settingData.timeRight = initRightTime
        }
        refreshDatePicker(false)
        refreshViews()
    }
    
    @IBAction func OnTappedClearPicker(sender: UIButton) {
        if bIsLeft{
            settingData.nLeftDurationHours = 0
            settingData.nLeftDurationMinutes = 0
        }else{
            settingData.nRightDurationHours = 0
            settingData.nRightDurationMinutes = 0
        }
        refreshViewPicker(false)
        refreshViews()
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
            if bIsLeft{
                settingData.timeLeft = initLeftTime
            }else{
                settingData.timeRight = initRightTime
            }
            refreshDatePicker(false)
        }
        else {
            refreshDatePicker(true)
        }
        
        refreshViews()
    }
    
    @IBAction func OnTappedDurationStart(sender: UIButton) {
    }
    
    @IBAction func OnTappedDurationReset(sender: UIButton) {
    }
    
    @IBAction func OnTappedDurationOR1(sender: UIButton) {
        bIsExpandedDuration = true
        self.tableView.reloadData()
    }
    
    @IBAction func OnTappedDurationOR2(sender: UIButton) {
        bIsExpandedDuration = false
        self.tableView.reloadData()
    }
    
    @IBAction func OnValueChangedLeftRight(sender: UISegmentedControl) {
        bIsLeft = sender.selectedSegmentIndex == 0
        refreshDatePicker(false)
        refreshViewPicker(false)
        refreshViews()
    }
    
    @IBAction func onTapCancel(sender: AnyObject) {
        
        breastTextInput.resignFirstResponder()
        dismiss()
    }
    
    @IBAction func onTapSave(sender: AnyObject) {
        
        // save functions
        // Convert SettingData to LogEvent
        
        logEvent.bIsJustNow = settingData.bIsNotJustNow
        logEvent.displayDesc = settingData.bDisplayDescription

        logEvent.timeLeft = settingData.timeLeft
        logEvent.leftHours = settingData.nLeftDurationHours
        logEvent.leftMins = settingData.nLeftDurationMinutes
        
        logEvent.timeRight = settingData.timeRight
        logEvent.rightHours = settingData.nRightDurationHours
        logEvent.rightMins = settingData.nRightDurationMinutes
        
        logEvent.starMark = settingData.bIsSelectedStar
        logEvent.exclamationMark = settingData.bIsSelectedExclamation
        logEvent.image = settingData.breastImage
        
        // change action type
        if logEvent.action.isEqualToString("both") {
            
            let nLeft = settingData.nLeftDurationHours * 60 + settingData.nLeftDurationMinutes
            let nRight = settingData.nRightDurationHours * 60 + settingData.nRightDurationMinutes
            var actionId:String = "both"
            
            if nLeft != 0 && nRight == 0 {
                actionId = "left"
            }
            else if nLeft == 0 && nRight != 0 {
                actionId = "right"
            }
            
            logEvent.action = actionId
        }
        
        
        // Assign Text
        if let text = breastTextInput.text {
            settingData.strNoteText = text
        }
        else {
            settingData.strNoteText = ""
        }
        logEvent.note = settingData.strNoteText
        
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
        
        breastTextInput.resignFirstResponder()
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
//                self.navigationController?.popToRootViewControllerAnimated(true)
                self.navigationController?.popViewControllerAnimated(true)
            })
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // ==========================================
    
    
    func datePickerValueChanged(sender: UIDatePicker)
    {
        lblTimeResult.text = getDateFormat(datePicker.date)
        
        if bIsLeft {
            settingData.timeLeft = datePicker.date
        }else{
            settingData.timeRight = datePicker.date
        }
        
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
    
    
    func getPickerFormat(hours:Int,minutes:Int) -> String{
        var text:String = "0 min"
        
        if hours > 0 {
            text = String(format:"%d hour %d min",hours,minutes)
        }else if minutes > 0{
            text = String(format:"%d min",minutes)
        }else{
            text = "0 min"
        }
        return text
    }
    
    
    
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var hours = 0
        var minutes = 0
        
        hours = pickerHoursJust.selectedRowInComponent(0)
        minutes = pickerMinutesJust.selectedRowInComponent(0)

        

        if oldState == hours + minutes {
            return row.description
        }
        oldState = hours + minutes

        if !lblPickerNotSetJustExpand.hidden {
            lblPickerNotSetJustExpand.hidden = true
        }
        lblPickerEditJustExpand.hidden = false
        btnClearPickerJustExpand.hidden = false
        lblPickerEditJustExpand.text = getPickerFormat(hours, minutes: minutes)
        oldState = pickerHoursJust.selectedRowInComponent(0) + pickerMinutesJust.selectedRowInComponent(0)
        
        
        // Marko
        if bIsLeft{
            settingData.nLeftDurationHours = hours
            settingData.nLeftDurationMinutes = minutes
        }else{
            settingData.nRightDurationHours = hours
            settingData.nRightDurationMinutes = minutes
        }
        
        return row.description
    }
    
    
    func SetStar(isSel:Bool) {
        if isSel {
            btnStar.setImage(UIImage(named: "star_background_a.png"), forState: UIControlState.Normal)
            imgStar.image=UIImage(named: "star_Large_a.png")
            1
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

    func refreshDatePicker(isExpand:Bool){
        var t = initLeftTime
        if bIsLeft{
            t = settingData.timeLeft!
        }else{
            t = settingData.timeRight!
        }
        
        
        lblTimeResult.text = getDateFormat(t!)
        
        datePicker.setDate(t!, animated: true)
        bIsVisibleTimePicker = isExpand
    }
    
    func refreshViewPicker(isExpand:Bool){
        var hours = 0
        var minutes = 0
        if bIsLeft{
            hours = settingData.nLeftDurationHours
            minutes = settingData.nLeftDurationMinutes
        }else{
            hours = settingData.nRightDurationHours
            minutes = settingData.nRightDurationMinutes
        }
        
        if isExpand {
            if hours + minutes == 0 {
                lblPickerNotSetJustExpand.hidden = false
                lblPickerEditJustExpand.hidden = true
                btnClearPickerJustExpand.hidden = true
            }else{
                lblPickerNotSetJustExpand.hidden = true
                lblPickerEditJustExpand.hidden = false
                btnClearPickerJustExpand.hidden = false
                lblPickerEditJustExpand.text = getPickerFormat(hours, minutes: minutes)
            }
        }else{
            if hours + minutes == 0 {
                lblPickerNotSetJust.hidden = false
                lblPickerResultJust.hidden = true
            }else{
                lblPickerNotSetJust.hidden = true
                lblPickerResultJust.hidden = false
                lblPickerResultJust.text = getPickerFormat(hours, minutes: minutes)
            }
        }
        pickerHoursJust.selectRow(hours, inComponent: 0, animated: true)
        pickerMinutesJust.selectRow(minutes, inComponent: 0, animated: true)
        
        
        oldState = hours + minutes
        bIsExpandedDuration = isExpand
    }
    
    func refreshViews() {

        if bIsLeft {
            lblTimeBothText.text = "Time Breast Left"
            lblDurationJust.text = "Duration Breast Left"
            lblDurationJustExpand.text = "Duration Breast Left"
        }else{
            lblTimeBothText.text = "Time Breast Right"
            lblDurationJust.text = "Duration Breast Right"
            lblDurationJustExpand.text = "Duration Breast Right"
        }
        
        tableView.reloadData()
    }
    
    func initBreastUIs() {
        settingData.optAction = self.optAction
        
        // hide/show Left/Right Segment control
        if settingData.optAction != BothMoreSettingData.BreastActions.ActBoth {
            segLeftRightSelector.hidden = true
        }
        
        // select left/right action
        if settingData.optAction == BothMoreSettingData.BreastActions.ActRight {
            bIsLeft = false
        }
        else {
            bIsLeft = true
        }
        
        // change Navigation title
        var szTitle:String = "Breast Both Edit"
        
        if settingData.optAction == BothMoreSettingData.BreastActions.ActLeft {
            szTitle = "Breast Left Edit"
        }
        else if settingData.optAction == BothMoreSettingData.BreastActions.ActRight {
            szTitle = "Breast Right Edit"
        }
        
        self.title = szTitle
        
        refreshViews()
    }
    
    func dismiss() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func getIntValue(eventObj:Int?, limitMin:Int, limitMax:Int, valueMin:Int, valueMax:Int) ->Int {
        var retValue:Int! = valueMin
        
        if eventObj != nil {
            retValue = eventObj
        }
        
        if retValue < limitMin {
            retValue = valueMin
        }
        
        if retValue > limitMax {
            retValue = valueMax
        }
        
        return retValue
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
        breastImageView.image = original
        if breastImageView.image != nil {
            
            settingData.breastImage = breastImageView.image
            
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
    }
    
    func initSettingData() {
        // convert LogEvent to PoopMoreSettingData
        
        settingData.bIsNotJustNow = logEvent.bIsJustNow
        settingData.bDisplayDescription = logEvent.displayDesc
        
        if logEvent.timeLeft != nil {
            settingData.timeLeft = NSDate(timeInterval: 0, sinceDate: logEvent.timeLeft!)
        }
        else {
            settingData.timeLeft = nil
        }
        
        if logEvent.timeRight != nil {
            settingData.timeRight = NSDate(timeInterval: 0, sinceDate: logEvent.timeRight!)
        }
        else {
            settingData.timeRight = nil
        }
        
        
        settingData.nLeftDurationHours = getIntValue(logEvent.leftHours, limitMin: 0, limitMax: 59, valueMin: 0, valueMax: 59)
        settingData.nLeftDurationMinutes = getIntValue(logEvent.leftMins, limitMin: 0, limitMax: 59, valueMin: 0, valueMax: 59)
        
        settingData.nRightDurationHours = getIntValue(logEvent.rightHours, limitMin: 0, limitMax: 59, valueMin: 0, valueMax: 59)
        settingData.nRightDurationMinutes = getIntValue(logEvent.rightMins, limitMin: 0, limitMax: 59, valueMin: 0, valueMax: 59)
        
        settingData.bIsSelectedStar = logEvent.starMark
        settingData.bIsSelectedExclamation = logEvent.exclamationMark
        
        if let note = logEvent.note {
            settingData.strNoteText = note
        }
        
        // TODO image
        settingData.breastImage = nil   // ???

    }
    
    
    //===============================================
    
    
    
    
    //===============================================
    //      UITableView Deelgate
    //===============================================
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let currCell:kEditBreastContentCell = kEditBreastContentCell(rawValue: indexPath.row)!
        
        switch(currCell)
        {
        case .SeperateStart:
            if settingData.optAction == BothMoreSettingData.BreastActions.ActBoth {
                return 0
            }
            return 20
            
        case .NotNustNow:
            return 0
            
        case .LeftRight:
            if settingData.optAction != BothMoreSettingData.BreastActions.ActBoth {
                return 0
            }
            return 60
            
        case .TimeBoth:
            return 45
            
        case .DateTimePicker:
            if bIsVisibleTimePicker == false {
                return 0
            }
            return 160
            
        case .DurationNoExpand:
            return 0
            
        case .DurationExpand:
            return 0
            
        case .DurationNoExpandNotJustNow:
            if bIsExpandedDuration {
                return 0
            }
            return 45
            
        case .DurationExpandNotJustNow:
            if bIsExpandedDuration {
                return 190
            }
            return 0
            
        case .Bell:
            return 96
            
        case .StarOrExclamation:
            return 96
            
        case .Camera:
            // add Marko
            if settingData.breastImage != nil {
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
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
/*
        if cell.respondsToSelector(Selector("setSeparatorInset:")) {
            let deltaEdge = UIEdgeInsets(top:0,left:15,bottom:0,right:0)
            switch indexPath.row {
            case 3,4:
                cell.separatorInset = deltaEdge
            default:
                return
            }
        }
*/
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let t = datePicker.date
        
        var hours = 0
        var minutes = 0
        
        hours = pickerHoursJust.selectedRowInComponent(0)
        minutes = pickerMinutesJust.selectedRowInComponent(0)
        
        let currCell:kEditBreastContentCell = kEditBreastContentCell(rawValue: indexPath.row)!
        
        if currCell == .TimeBoth {
            if bIsVisibleTimePicker{
                if bIsLeft {
                    settingData.timeLeft = t
                }else{
                    settingData.timeRight = t
                }
            }
            
            refreshDatePicker(!bIsVisibleTimePicker)
            refreshViews()
        }
        
        if currCell == .DurationNoExpand {
            refreshViewPicker(true)
            refreshViews()
        }
        
        if currCell == .DurationExpand {
            if bIsLeft {
                settingData.nLeftDurationHours = hours
                settingData.nLeftDurationMinutes = minutes
            }else{
                settingData.nRightDurationHours = hours
                settingData.nRightDurationMinutes = minutes
            }
            refreshViewPicker(false)
            refreshViews()
        }
        
        // Marko
        if currCell == .DurationNoExpandNotJustNow {
            refreshViewPicker(true)
            refreshViews()
        }
        
        if currCell == .DurationExpandNotJustNow {
            if bIsLeft {
                settingData.nLeftDurationHours = hours
                settingData.nLeftDurationMinutes = minutes
            }else{
                settingData.nRightDurationHours = hours
                settingData.nRightDurationMinutes = minutes
            }
            refreshViewPicker(false)
            refreshViews()
        }
    }
    
    // The number of columns of data
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 60
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