//
//  BothMoreTableViewController.swift
//  BothMore
//
//  Created by Lee Xiaoxiao on 9/26/15.
//  Copyright © 2015 Lee Xiaoxiao. All rights reserved.
//

import UIKit

enum kBreastContentCell : Int {
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
    case SeperateEnd        // 15
}



class BothMoreTableViewController: UITableViewController,  UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate  {
    
    let NVItemSaveColor:UIColor = UIColor(red:255.0/255.0, green:59.0/255.0, blue:48.0/255.0, alpha:1.0) // #FF3B30
    let NVItemDefaultColor:UIColor = UIColor(red:0.0/255.0, green:122.0/255.0, blue:255.0/255.0, alpha:1.0) // #007AFF
    
    var settingData:BothMoreSettingData = BothMoreSettingData()
    var bIsVisibleTimePicker:Bool = false
    var bIsExpandedDuration:Bool = false
    var bIsLeft:Bool = true
    
    var oldState = 0
    var initTime:NSDate?
    
    var bItemChanged:Bool = false
    var init_settingData:BothMoreSettingData = BothMoreSettingData()
    
    // Activity Indicator
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
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
    
    



    
    
    //===============================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerHours.delegate = self
        pickerHours.dataSource = self
        
        pickerMinutes.delegate = self
        pickerMinutes.dataSource = self
        
        initTime = settingData.timeLeft
        settingData.timeRight = initTime
        
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
        
        btnSave.enabled = false
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
        if bIsLeft{
            settingData.timeLeft = initTime
        }else{
            settingData.timeRight = initTime
        }
        refreshDatePicker(false)
        refreshViews()
        
        // Marko
        checkItemChanged()
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
        
        // Marko
        checkItemChanged()
    }
    
    
    @IBAction func OnStarTapped(sender: UIButton) {
        SetStar(!settingData.bIsSelectedStar)
        
        // Marko
        checkItemChanged()
    }
    
    @IBAction func OnExclamationTapped(sender: UIButton) {
        SetExclamation(!settingData.bIsSelectedExclamation)
        
        // Marko
        checkItemChanged()
    }
    
    @IBAction func OnChangedNotJustNow(sender: UISwitch) {
        settingData.bIsNotJustNow = sender.on
        if !sender.on {
            if bIsLeft{
                settingData.timeLeft = initTime
            }else{
                settingData.timeRight = initTime
            }
            refreshDatePicker(false)
        }
        else {
            refreshDatePicker(true)
        }
        
        refreshViews()
        
        // Marko
        checkItemChanged()
    }
    
    @IBAction func OnTappedDurationStart(sender: UIButton) {
        // Marko
        checkItemChanged()
    }
    
    @IBAction func OnTappedDurationReset(sender: UIButton) {
        // Marko
        checkItemChanged()
    }
    
    
    @IBAction func OnTappedDurationOR1(sender: UIButton) {
        bIsExpandedDuration = true
        self.tableView.reloadData()
        
        // Marko
        checkItemChanged()
    }
    
    @IBAction func OnTappedDurationOR2(sender: UIButton) {
        bIsExpandedDuration = false
        self.tableView.reloadData()
        
        // Marko
        checkItemChanged()
    }
    
    @IBAction func OnValueChangedLeftRight(sender: UISegmentedControl) {
        bIsLeft = sender.selectedSegmentIndex == 0
        refreshDatePicker(false)
        refreshViewPicker(false)
        refreshViews()
        
        // Marko
        checkItemChanged()
    }
    
    @IBAction func onTapCancel(sender: AnyObject) {
        
        breastTextInput.resignFirstResponder()
        if bItemChanged {
            let alertVC = UIAlertController(title: nil, message: "You will be lose changed data", preferredStyle: .ActionSheet)
            let yesAction = UIAlertAction(title: "Yes", style:.Default){ (action) in
                self.dismiss()
            }
            alertVC.addAction(yesAction)
            let cancelAction = UIAlertAction(title: "Cancel", style:.Destructive){ (action) in
            }
            alertVC.addAction(cancelAction)
            presentViewController(alertVC, animated: true, completion: nil)
        }
        else {
            dismiss()
        }
        
    }
    
    @IBAction func onTapSave(sender: AnyObject) {
        
        // save functions
        // Convert SettingData to LogEvent
        
        logEvent.bIsJustNow = settingData.bIsNotJustNow
        logEvent.displayDesc = settingData.bDisplayDescription
        
        if settingData.optAction != BothMoreSettingData.BreastActions.ActRight {
            logEvent.timeLeft = settingData.timeLeft
            logEvent.leftHours = settingData.nLeftDurationHours
            logEvent.leftMins = settingData.nLeftDurationMinutes
        }
        
        if settingData.optAction != BothMoreSettingData.BreastActions.ActLeft {
            logEvent.timeRight = settingData.timeRight
            logEvent.rightHours = settingData.nRightDurationHours
            logEvent.rightMins = settingData.nRightDurationMinutes
        }
        
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
            
            /*
            let item = logEvent.item
            if item != nil {
            item?.actions[0].actionID = actionId
            item?.actions[0].name = actionName
            }
            */
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
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        DataSource.sharedDataSouce.logEvent(self.logEvent, block: { (success, error) -> Void in
            
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            self.activityIndicator.stopAnimating()
            if (success){
                // self.changed = false
                self.navigationController?.popViewControllerAnimated(true)
            }
            else{
                let av = UIAlertView(title: "Error", message: "Error:\(error?.localizedDescription)", delegate: nil, cancelButtonTitle: "OK")
                av.show()
            }
        })
        
        
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

    
    
    
    
    
    //===============================================
    
    
    
    func datePickerValueChanged(sender: UIDatePicker)
    {
        if !lblTimeNotSet.hidden {
            lblTimeNotSet.hidden = true
            lblTimeEdit.hidden = false
            btnClearTime.hidden = false
        }
        lblTimeEdit.text = getDateFormat(datePicker.date)
        
        if bIsLeft {
            settingData.timeLeft = datePicker.date
        }else{
            settingData.timeRight = datePicker.date
        }
        
        logEvent.time = datePicker.date.timeIntervalSinceReferenceDate
        
        checkItemChanged()
    }
    
    func getDateFormat(selectedTime:NSDate) -> String
    {
        let dateFormatter = NSDateFormatter()
        var text : String = ""
        if NSCalendar.currentCalendar().isDateInToday(selectedTime) {
            dateFormatter.dateFormat = "h:mm a"
            text = "Today " + dateFormatter.stringFromDate(selectedTime).lowercaseString
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
        }else if minutes>0{
            text = String(format:"%d min",minutes)
        }else{
            text = "0 min"
        }
        return text
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var hours = 0
        var minutes = 0
        
        if settingData.bIsNotJustNow {
            hours = pickerHoursJust.selectedRowInComponent(0)
            minutes = pickerMinutesJust.selectedRowInComponent(0)
        }
        else {
            hours = pickerHours.selectedRowInComponent(0)
            minutes = pickerMinutes.selectedRowInComponent(0)
        }
        

        if oldState == hours + minutes {
            return row.description
        }
        oldState = hours + minutes
        
        if !settingData.bIsNotJustNow {
            if !lblPickerNotSet2.hidden {
                lblPickerNotSet2.hidden = true
            }
            lblPickerEdit.hidden = false
            btnClearPicker.hidden = false
            lblPickerEdit.text = getPickerFormat(hours, minutes: minutes)
            oldState = pickerHours.selectedRowInComponent(0) + pickerMinutes.selectedRowInComponent(0)
        }
        else {
            if !lblPickerNotSetJustExpand.hidden {
                lblPickerNotSetJustExpand.hidden = true
            }
            lblPickerEditJustExpand.hidden = false
            btnClearPickerJustExpand.hidden = false
            lblPickerEditJustExpand.text = getPickerFormat(hours, minutes: minutes)
            oldState = pickerHoursJust.selectedRowInComponent(0) + pickerMinutesJust.selectedRowInComponent(0)
        }
        
        
        
        // Marko
        if bIsLeft{
            settingData.nLeftDurationHours = hours
            settingData.nLeftDurationMinutes = minutes
        }else{
            settingData.nRightDurationHours = hours
            settingData.nRightDurationMinutes = minutes
        }
        
        checkItemChanged()
        

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
        var t = initTime
        if bIsLeft{
            t = settingData.timeLeft!
        }else{
            t = settingData.timeRight!
        }
        
        if isExpand {
            if t == initTime {
                lblTimeNotSet.hidden = false
                lblTimeEdit.hidden = true
                btnClearTime.hidden = true
            }else{
                lblTimeNotSet.hidden = true
                lblTimeEdit.hidden = false
                btnClearTime.hidden = false
                lblTimeEdit.text = getDateFormat(t!)
            }
            lblTimeResult.hidden = true
        }else{
            if t == initTime {
                lblTimeNotSet.hidden = false
                lblTimeResult.hidden = true
            }else{
                lblTimeNotSet.hidden = true
                lblTimeResult.hidden = false
                lblTimeResult.text = getDateFormat(t!)
            }
            lblTimeEdit.hidden = true
            btnClearTime.hidden = true
        }
        
        
        
        
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
        
        if !settingData.bIsNotJustNow {
            if isExpand {
                if hours + minutes == 0 {
                    lblPickerNotSet2.hidden = false
                    lblPickerEdit.hidden = true
                    btnClearPicker.hidden = true
                }else{
                    lblPickerNotSet2.hidden = true
                    lblPickerEdit.hidden = false
                    btnClearPicker.hidden = false
                    lblPickerEdit.text = getPickerFormat(hours, minutes: minutes)
                }
            }else{
                if hours + minutes == 0 {
                    lblPickerNotSet1.hidden = false
                    lblPickerResult.hidden = true
                }else{
                    lblPickerNotSet1.hidden = true
                    lblPickerResult.hidden = false
                    lblPickerResult.text = getPickerFormat(hours, minutes: minutes)
                }
            }
            pickerHours.selectRow(hours, inComponent: 0, animated: true)
            pickerMinutes.selectRow(minutes, inComponent: 0, animated: true)
        }
        else {
            // Marko
            
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
        }
        
        
        oldState = hours + minutes
        bIsExpandedDuration = isExpand
    }
    
    func refreshViews() {
        if !settingData.bIsNotJustNow {
            if bIsLeft {
                lblTimeBothText.text = "Time Breast Left"
                lblDuration1.text = "Duration Breast Left"
                lblDuration2.text = "Duration Breast Left"
                lblDurationInfo1.text = "Left"
                lblDurationInfo2.text = "Left"
            }else{
                lblTimeBothText.text = "Time Breast Right"
                lblDuration1.text = "Duration Breast Right"
                lblDuration2.text = "Duration Breast Right"
                lblDurationInfo1.text = "Right"
                lblDurationInfo2.text = "Right"
            }
        }
        else {
            if bIsLeft {
                lblTimeBothText.text = "Time Breast Left"
                lblDurationJust.text = "Duration Breast Left"
                lblDurationJustExpand.text = "Duration Breast Left"
            }else{
                lblTimeBothText.text = "Time Breast Right"
                lblDurationJust.text = "Duration Breast Right"
                lblDurationJustExpand.text = "Duration Breast Right"
            }
        }
        
        tableView.reloadData()
    }
    
    func dismiss() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func checkItemChanged() {
        
        // check all any item changed
        bItemChanged = false
        
        repeat {
            let formatter : NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            // check left time, durations
            if settingData.optAction != BothMoreSettingData.BreastActions.ActRight {
                
                let timeLeftInit = formatter.stringFromDate(init_settingData.timeLeft!)
                let timeLeftSetting = formatter.stringFromDate(settingData.timeLeft!)
                if !timeLeftSetting.isEqual(timeLeftInit) {
                    bItemChanged = true
                    break
                }
                
                if init_settingData.nLeftDurationHours != settingData.nLeftDurationHours {
                    bItemChanged = true
                    break
                }
                
                if init_settingData.nLeftDurationMinutes != settingData.nLeftDurationMinutes {
                    bItemChanged = true
                    break
                }
            }
            
            
            // check right time, durations
            if settingData.optAction != BothMoreSettingData.BreastActions.ActLeft {
                
                let timeRightInit = formatter.stringFromDate(init_settingData.timeRight!)
                let timeRightSetting = formatter.stringFromDate(settingData.timeRight!)
                if !timeRightSetting.isEqual(timeRightInit) {
                    bItemChanged = true
                    break
                }
                
                if init_settingData.nRightDurationHours != settingData.nRightDurationHours {
                    bItemChanged = true
                    break
                }
                
                if init_settingData.nRightDurationMinutes != settingData.nRightDurationMinutes {
                    bItemChanged = true
                    break
                }
            }
            
            if init_settingData.bIsSelectedStar != settingData.bIsSelectedStar {
                bItemChanged = true
                break
            }
            
            if init_settingData.bIsSelectedExclamation != settingData.bIsSelectedExclamation {
                bItemChanged = true
                break
            }
            
            if init_settingData.strNoteText != settingData.strNoteText {
                bItemChanged = true
                break
            }
            
            if init_settingData.breastImage != settingData.breastImage {
                bItemChanged = true
                break
            }
        } while false
        
        
        // Navigation Item change
        if bItemChanged {
            btnSave.tintColor = NVItemSaveColor
            btnSave.enabled = true
        }
        else {
            btnCancel.tintColor = NVItemDefaultColor
            btnSave.enabled = false
        }
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
    
    var logEvent = LogEvent() {
        didSet {
            
            // convert LogEvent to PoopMoreSettingData
            
            settingData.bIsNotJustNow = logEvent.bIsJustNow
            settingData.bDisplayDescription = logEvent.displayDesc
            
            settingData.timeLeft = logEvent.timeLeft
            if settingData.timeLeft == nil {
                settingData.timeLeft = NSDate.init()
            }
            
            settingData.timeRight = logEvent.timeRight
            if settingData.timeRight == nil {
                settingData.timeRight = NSDate.init()
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
            
            // save initialize setting data
            init_settingData.bIsNotJustNow = settingData.bIsNotJustNow
            init_settingData.timeLeft = NSDate.init(timeInterval: 0, sinceDate: settingData.timeLeft!)
            init_settingData.timeRight = NSDate.init(timeInterval: 0, sinceDate: settingData.timeRight!)
            init_settingData.bDisplayDescription = settingData.bDisplayDescription
            init_settingData.bIsSelectedStar = settingData.bIsSelectedStar
            init_settingData.bIsSelectedExclamation = settingData.bIsSelectedExclamation
            init_settingData.nLeftDurationHours = settingData.nLeftDurationHours
            init_settingData.nLeftDurationMinutes = settingData.nLeftDurationMinutes
            init_settingData.nRightDurationHours = settingData.nRightDurationHours
            init_settingData.nRightDurationMinutes = settingData.nRightDurationMinutes
            init_settingData.strNoteText = settingData.strNoteText
            init_settingData.breastImage = settingData.breastImage
        }
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
            checkItemChanged()
            
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
        var szTitle:String = "Breast Both More"
        
        if settingData.optAction == BothMoreSettingData.BreastActions.ActLeft {
            szTitle = "Breast Left More"
        }
        else if settingData.optAction == BothMoreSettingData.BreastActions.ActRight {
            szTitle = "Breast Right More"
        }
        
        self.title = szTitle
        
        refreshViews()
    }
    
    
  //=============================================================
    

    
    

    //===============================================
    //      UITableView Deelgate
    //===============================================
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let currCell:kBreastContentCell = kBreastContentCell(rawValue: indexPath.row)!
        
        switch (currCell)
        {
        case .NotNustNow:     // id_NotJustNow
            return 45
            
        case .LeftRight:     // id_LeftRight
            if settingData.optAction != BothMoreSettingData.BreastActions.ActBoth {
                return 20
            }
            return 60
            
        case .TimeBoth:     // id_TimeBoth
            if settingData.bIsNotJustNow {
                return 45
            }
            return 0
            
        case .DateTimePicker:     // id_DateTimePicker
            if bIsVisibleTimePicker == false || !settingData.bIsNotJustNow {
                return 0
            }
            return 160
            
        case .DurationNoExpand:     // id_DurationNoExpand
            if settingData.bIsNotJustNow {
                return 0
            }
            else if bIsExpandedDuration {
                return 0
            }
            return 133
            
        case .DurationExpand:     // id_DurationExpand
            if settingData.bIsNotJustNow {
                return 0
            }
            else if bIsExpandedDuration {
                return 270
            }
            return 0
            
        case .DurationNoExpandNotJustNow:     // id_DurationNoExpandNotJustNow
            if settingData.bIsNotJustNow {
                if bIsExpandedDuration {
                    return 0
                }
                return 45
            }
            return 0
            
        case .DurationExpandNotJustNow:     // id_DurationExpandNotJustNow
            if settingData.bIsNotJustNow {
                if bIsExpandedDuration {
                    return 190
                }
            }
            return 0
            
        case .Bell:    // id_Bell
            return 96
            
        case .StarOrExclamation:    // id_StarOrExclamation
            return 96
            
        case .Camera:    // id_Camera
            // add Marko
            if settingData.breastImage != nil {
                return 170
            }
            return 45
            
        case .SeperateEnd:
            return 70
            
        default:
            return 20
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
        if cell.respondsToSelector(Selector("setSeparatorInset:")) {
            let deltaEdge = UIEdgeInsets(top:0,left:15,bottom:0,right:0)
            
            let currCell:kBreastContentCell = kBreastContentCell(rawValue: indexPath.row)!

            switch (currCell) {
                
            case .TimeBoth:
                cell.separatorInset = deltaEdge
                return
                
            case .DateTimePicker:
                cell.separatorInset = deltaEdge
                return
            default:
                return
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let t = datePicker.date
        
        var hours = 0
        var minutes = 0
        
        if !settingData.bIsNotJustNow {
            hours = pickerHours.selectedRowInComponent(0)
            minutes = pickerMinutes.selectedRowInComponent(0)
        }
        else {
            hours = pickerHoursJust.selectedRowInComponent(0)
            minutes = pickerMinutesJust.selectedRowInComponent(0)
        }
        
        let currCell:kBreastContentCell = kBreastContentCell(rawValue: indexPath.row)!
        
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
        
        checkItemChanged()
    }
    
    // The number of columns of data
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 60
    }
    
    
    
    
    
    
    
    
    //===============================================
    
    
    
    //===================================================
    //      UITextField Delegate
    //===================================================
    
    func textFieldDidChange(textField: UITextField) {
        
        settingData.strNoteText = textField.text!
        checkItemChanged()
    }
    
    
    // UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}