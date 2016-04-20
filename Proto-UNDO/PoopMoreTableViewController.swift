//
//  PoopMoreTableViewController.swift
//  PoopMore
//
//  Created by Lee Xiaoxiao on 9/26/15.
//  Copyright © 2015 Lee Xiaoxiao. All rights reserved.
//

import UIKit

enum kPoopContentCell : Int {
    case SeperateStart = 0
    case NotJustNow         // 1
    case Time               // 2
    case DateTimePicker     // 3
    case SeperateDesription // 4
    case DisplayDescription // 5
    case SeperateOptions    // 6
    case OptionsJustPoop    // 7
    case OptionsNewbornPoop // 8
    case OptionsBreastfedPoop // 9
    case OptionsFomulafedPoop // 10
    case OptionsSolidsfedPoop // 11
    case OptionsDiarrheaPoop  // 12
    case SeperateTag        // 13
    case StarOrExclamation  // 14
    case SeperateNotePhoto  // 15
    case Camera             // 16
    case SeperateEnd        // 17
}


class PoopDetailItem {
    var itemIndex: Int
    var name: String
    var hasDesc: Bool
    var color: String
    var texture: String
    var analogy: String
    var stinkFactor: Int
    
    init(itemIndex: Int, name: String, hasDesc: Bool, color: String, texture: String, analogy: String, stinkFactor: Int) {
        self.itemIndex = itemIndex
        self.name = name
        self.hasDesc = hasDesc
        self.color = color
        self.texture = texture
        self.analogy = analogy
        self.stinkFactor = stinkFactor
    }
}


class PoopMoreTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let NVItemSaveColor:UIColor = UIColor(red:255.0/255.0, green:59.0/255.0, blue:48.0/255.0, alpha:1.0) // #FF3B30
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

    
    var settingData:PoopMoreSettingData = PoopMoreSettingData()
    
    var bIsVisibleTimePicker:Bool = false
    var bIsDisplayDescriptions:Bool = false
    
    var bItemChanged:Bool = false
    var init_settingData:PoopMoreSettingData = PoopMoreSettingData()
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RefreshPoopOptions()
        
        datePicker.addTarget(self, action: "datePickerValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        initTime = settingData.timePoop
        
        // by Marko
        // Update UIs according the settings Data
        memoTextInput.text = settingData.strNoteText
        memoTextInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        memoTextInput.delegate = self
        
        SetStar(settingData.bIsSelectedStar)
        SetExclamation(settingData.bIsSelectedExclamation)
        
        // Load Image from Parse
        logEvent.getImage{ (image: UIImage?, error : NSError?) -> Void in
            
            if image == nil || error != nil {
                
            }
            else {
                self.memoImageView.image = image!
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
        settingData.timePoop = initTime
        refreshDatePicker(false)
        
        // Marko
        checkItemChanged()
    }
    
    @IBAction func OnExclamationTapped(sender: UIButton) {
        SetExclamation(!settingData.bIsSelectedExclamation)
        
        // Marko
        checkItemChanged()
    }
    
    @IBAction func OnStarTapped(sender: UIButton) {
        SetStar(!settingData.bIsSelectedStar)
        
        // Marko
        checkItemChanged()
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
        
        // Marko
        checkItemChanged()
    }
    
    
    @IBAction func OnChangedDisplayDescriptions(sender: UISwitch) {
        bIsDisplayDescriptions = sender.on
        self.tableView.reloadData()
        
        // Marko
        settingData.bDisplayDescription = bIsDisplayDescriptions
        checkItemChanged()
    }
    
    @IBAction func onTapCancel(sender: AnyObject) {
        
        memoTextInput.resignFirstResponder()
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
        // Convert SettinsData to LogEvent
        logEvent.bIsJustNow = settingData.bIsNotJustNow
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
    
    
    //===============================================
    
    
    
    func datePickerValueChanged(sender: UIDatePicker)
    {
        if !lblTimeNotSet.hidden {
            lblTimeNotSet.hidden = true
            lblTimeEdit.hidden = false
            btnClearTime.hidden = false
        }
        lblTimeEdit.text = getDateFormat(datePicker.date)
        
        settingData.timePoop = datePicker.date
        
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
    
    func refreshDatePicker(isExpand:Bool) {
        let t = settingData.timePoop

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
        } else {
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
    
    func checkItemChanged() {
        
        // check all any item changed
        bItemChanged = false
        
        repeat {
            let formatter : NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateInit = formatter.stringFromDate(init_settingData.timePoop!)
            let dateSetting = formatter.stringFromDate(settingData.timePoop!)
            
            if !dateSetting.isEqual(dateInit) {
                bItemChanged = true
                break
            }
            
            if init_settingData.bIsSelectedStar != settingData.bIsSelectedStar {
                bItemChanged = true
                break
            }
            
            if init_settingData.bIsSelectedExclamation != settingData.bIsSelectedExclamation {
                bItemChanged = true
                break
            }
            
            if init_settingData.optPoop != settingData.optPoop {
                bItemChanged = true
                break
            }
            
            if init_settingData.strNoteText != settingData.strNoteText {
                bItemChanged = true
                break
            }
            
            if init_settingData.memoImage != settingData.memoImage {
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
    
    var logEvent = LogEvent() {
        didSet {
            
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
            
            
            // save initialize setting data
            init_settingData.bIsNotJustNow = settingData.bIsNotJustNow
            init_settingData.timePoop = NSDate.init(timeInterval: 0, sinceDate: settingData.timePoop!)
            
            init_settingData.bDisplayDescription = settingData.bDisplayDescription
            init_settingData.bIsSelectedStar = settingData.bIsSelectedStar
            init_settingData.bIsSelectedExclamation = settingData.bIsSelectedExclamation
            init_settingData.optPoop = settingData.optPoop
            init_settingData.strNoteText = settingData.strNoteText
            init_settingData.memoImage = settingData.memoImage
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
        memoImageView.image = original
        if memoImageView.image != nil {
            
            settingData.memoImage = memoImageView.image
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

    
    
    //===============================================
    //      UITableView Deelgate
    //===============================================
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //       return UITableViewAutomaticDimension
        
        let currCell:kPoopContentCell = kPoopContentCell(rawValue: indexPath.row)!
        
        switch(currCell)
        {
        case .NotJustNow:
            return 45
            
        case .Time:
            if settingData.bIsNotJustNow {
                return 45
            }
            return 0
            
        case .DateTimePicker:
            if bIsVisibleTimePicker == false || !settingData.bIsNotJustNow {
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
            
        case .SeperateEnd:
            return 70
            
        default:
            return 20
        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let currCell:kPoopContentCell = kPoopContentCell(rawValue: indexPath.row)!
        
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
        
        // Marko
        checkItemChanged()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
      
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
        let currCell:kPoopContentCell = kPoopContentCell(rawValue: indexPath.row)!
        
        if cell.respondsToSelector(Selector("setSeparatorInset:")) {
            
            switch currCell {
            case .NotJustNow:
                if !settingData.bIsNotJustNow {
                    cell.separatorInset = UIEdgeInsets(top:0,left:0,bottom:0,right:0)
                }
                else
                {
                    cell.separatorInset = UIEdgeInsets(top:0,left:15,bottom:0,right:0)
                }
            case .Time:
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
