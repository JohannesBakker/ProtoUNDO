//
//  NoteMoreTableViewController.swift
//  NoteMore
//
//  Created by Curly Brackets on 9/26/15.
//  Copyright © 2015 Curly Brackets. All rights reserved.
//
enum kContentCell : Int {
    case Splitter0 = 0
    case PastEvent         //1
    case TimeLeft           //3
    case DateTimePicker     //4
    case Interval           //6
    case Splitter1          //7
    case Bell               //8
    case Spliter2           //9
    case Babysitter
    case Doctor
    case Splitter5
    case StarOrExclamation  //10
    case Splitter3          //11
    case Camera             //12
    case Splitter4          //13
    
}
import UIKit

class NoteMoreTableViewController: UITableViewController,  UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate  {
    
    var settingData:NoteMoreSettingData = NoteMoreSettingData()
    var bIsVisibleTimePicker:Bool = false
    var bIsExpandedDuration:Bool = false
    
    //===============================================
    
    @IBOutlet weak var lblTimeBothText: UILabel!
    
    @IBOutlet weak var lblTimeResult: UILabel!
    
    @IBOutlet weak var lblTimeNotSet: UILabel!
    
    @IBOutlet weak var lblTimeEdit: UILabel!
    
    @IBOutlet weak var btnClearTime: UIButton!
    
    //============================================
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    //============================================
    
    @IBOutlet weak var lblDuration2: UILabel!

    @IBOutlet weak var lblPickerNotSet2: UILabel!

    @IBOutlet weak var lblPickerEdit: UILabel!
    
    @IBOutlet weak var btnClearPicker: UIButton!
    
    //============================================
    
    @IBOutlet weak var pickerHours: UIPickerView!
    
    @IBOutlet weak var pickerMinutes: UIPickerView!
 
    // ============================================
    @IBOutlet weak var memoTextInput: UITextField!
    
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var btnCancel: UIBarButtonItem!

    

    let NVItemSaveColor:UIColor = UIColor(red:255.0/255.0, green:59.0/255.0, blue:48.0/255.0, alpha:1.0) // #FF3B30
    let NVItemDefaultColor:UIColor = UIColor(red:0.0/255.0, green:122.0/255.0, blue:255.0/255.0, alpha:1.0) // #007AFF
    
    var bItemChanged:Bool = false
    var init_settingData:NoteMoreSettingData = NoteMoreSettingData()
    
    // Activity Indicator
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    @IBOutlet weak var memoImageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    // by Marko
    // MARK: - View life cycle
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden=false
    }
    
    // by Marko
    // MARK: - IBAction slot
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
    
    func dismiss() {
        navigationController?.popViewControllerAnimated(true)
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
        
        // save function
        // Convert SettingsData to LogEvent
        logEvent.starMark = settingData.bIsSelectedStar
        logEvent.exclamationMark = settingData.bIsSelectedExclamation
        logEvent.babyMark = settingData.bBabysitter
        logEvent.doctorMark = settingData.bDoctor
        logEvent.bIsJustNow = settingData.bIsNotJustNow
        logEvent.noteTime = settingData.time
        logEvent.image = settingData.memoImage

        // Assign Text
        if let text = memoTextInput.text {
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
    
    var logEvent = LogEvent() {
        didSet {
            
            // convert LogEvent to NoteMoreSettingData
            settingData.bIsSelectedStar = logEvent.starMark
            settingData.bIsSelectedExclamation = logEvent.exclamationMark
            settingData.bBabysitter = logEvent.babyMark
            settingData.bDoctor = logEvent.doctorMark
            
            settingData.bIsNotJustNow = logEvent.bIsJustNow
            settingData.time = logEvent.noteTime
            if settingData.time == nil {
                settingData.time = NSDate()
            }
            
            if let note = logEvent.note {
                settingData.strNoteText = note
            }
            
            // save initialize setting data
            init_settingData.bIsSelectedStar = settingData.bIsSelectedStar
            init_settingData.bIsSelectedExclamation = settingData.bIsSelectedExclamation
            init_settingData.bBabysitter = settingData.bBabysitter
            init_settingData.bDoctor = settingData.bDoctor
            init_settingData.bIsNotJustNow = logEvent.bIsJustNow
            init_settingData.time = NSDate.init(timeInterval: 0, sinceDate: settingData.time!)
            init_settingData.strNoteText = settingData.strNoteText
        }
    }
    
    // MARK: - Previous Code
    func datePickerValueChanged(sender: UIDatePicker)
    {
        if !lblTimeNotSet.hidden {
            lblTimeNotSet.hidden = true
            lblTimeEdit.hidden = false
            btnClearTime.hidden = false
        }
        lblTimeEdit.text = getDateFormat(datePicker.date)
        
        settingData.time = datePicker.date
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
        var text:String=""
        if hours>0{
            text = String(format:"%d hour %d min",hours,minutes)
        }else if minutes>0{
            text = String(format:"%d min",minutes)
        }else{
            text = "0 min"
        }
        return text
    }
    
    var oldState = 0
    var initTime:NSDate?
    
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let hours = pickerHours.selectedRowInComponent(0)
        let minutes = pickerMinutes.selectedRowInComponent(0)
        if oldState == hours + minutes {
            return row.description
        }
        oldState = hours + minutes
        if !lblPickerNotSet2.hidden {
            lblPickerNotSet2.hidden = true
        }
        lblPickerEdit.hidden = false
        btnClearPicker.hidden = false
        lblPickerEdit.text = getPickerFormat(hours, minutes: minutes)
        oldState = pickerHours.selectedRowInComponent(0) + pickerMinutes.selectedRowInComponent(0)
        
        checkItemChanged()
        
        return row.description
    }
    
    @IBAction func OnTappedClearTime(sender: UIButton) {
            settingData.time = initTime
        refreshDatePicker(false)
        refreshViews()
        
        checkItemChanged()
    }
    
    @IBAction func OnTappedClearPicker(sender: UIButton) {

        refreshViewPicker(false)
        refreshViews()
        
        checkItemChanged()
    }
    
    @IBOutlet weak var btnStar: UIButton!
    
    @IBOutlet weak var btnExclamation: UIButton!
    
    @IBOutlet weak var imgStar: UIImageView!
    
    @IBOutlet weak var imgExclamation: UIImageView!
    
    @IBAction func OnStarTapped(sender: UIButton) {
        SetStar(!settingData.bIsSelectedStar)
        
        checkItemChanged()
    }
    
    @IBAction func OnExclamationTapped(sender: UIButton) {
        SetExclamation(!settingData.bIsSelectedExclamation)
        
        checkItemChanged()
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

    func refreshDatePicker(isExpand:Bool){
        var t = initTime
        t = settingData.time!

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
        let hours = 0
        let minutes = 0
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

        }
        pickerHours.selectRow(hours, inComponent: 0, animated: true)
        pickerMinutes.selectRow(minutes, inComponent: 0, animated: true)
        oldState = hours + minutes
        bIsExpandedDuration = isExpand
    }
    
    
    @IBOutlet weak var lblDurationInfo2: UILabel!
    
  //=============================================================
    
    @IBOutlet weak var swNotJustNow: UISwitch!

    @IBAction func OnChangedNotJustNow(sender: UISwitch) {
        settingData.bIsNotJustNow = sender.on
        if !sender.on {
            settingData.time = initTime
            refreshDatePicker(false)
        }
        else {
            refreshDatePicker(true)
        }
        refreshViews()
        
        checkItemChanged()
    }
    
    @IBAction func OnTappedDurationStart(sender: UIButton) {
        checkItemChanged()
    }
    
    @IBAction func OnTappedDurationReset(sender: UIButton) {
        checkItemChanged()
    }
    
    @IBOutlet weak var lblDurationReady1: UILabel!
    @IBOutlet weak var lblDurationReady2: UILabel!
    
    @IBAction func OnTappedDurationOR1(sender: UIButton) {
        bIsExpandedDuration = true
        self.tableView.reloadData()
        
        checkItemChanged()
    }
    
    @IBAction func OnTappedDurationOR2(sender: UIButton) {
        bIsExpandedDuration = false
        self.tableView.reloadData()
        
        checkItemChanged()
    }
    @IBOutlet weak var babysitterButton: UIButton!
    
    @IBAction func babysitterAction(sender: AnyObject) {
        settingData.bBabysitter = !settingData.bBabysitter
        babysitterButton.selected = settingData.bBabysitter
        
        checkItemChanged()
    }
    @IBOutlet weak var doctorButton: UIButton!

    @IBAction func doctorAction(sender: AnyObject) {
        settingData.bDoctor = !settingData.bDoctor
        doctorButton.selected = settingData.bDoctor
        
        checkItemChanged()
    }
    @IBOutlet weak var vwNeededBorder2: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerHours.delegate = self
        pickerHours.dataSource = self
        
        pickerMinutes.delegate = self
        pickerMinutes.dataSource = self
        
        initTime = settingData.time
        
        datePicker.addTarget(self, action: "datePickerValueChanged:", forControlEvents: UIControlEvents.ValueChanged)

        vwNeededBorder2.layer.borderWidth = 0.5
        vwNeededBorder2.layer.borderColor = UIColor(red: 224/255.0, green: 224/255.0, blue: 224/255.0, alpha: 1.0).CGColor

        
        memoTextInput.text = settingData.strNoteText;
        memoTextInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        memoTextInput.delegate = self
        
        // by Marko
        // Update UIs according the settings Data
        SetStar(settingData.bIsSelectedStar)
        SetExclamation(settingData.bIsSelectedExclamation)
        
        babysitterButton.selected = settingData.bBabysitter
        doctorButton.selected = settingData.bDoctor
        
        memoTextInput.text = settingData.strNoteText
        
        // Load Image From Parse
        logEvent.getImage { (image : UIImage?, error : NSError?) -> Void in
            
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
        
        btnSave.enabled = false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //       return UITableViewAutomaticDimension
        let type:kContentCell = kContentCell(rawValue: indexPath.row)!
        
        switch(type)
        {
        case .PastEvent:
            return 45
            
        case .TimeLeft:
            if settingData.bIsNotJustNow {
                return 45
            }
            return 0
        case .DateTimePicker:
            if bIsVisibleTimePicker == false || !settingData.bIsNotJustNow {
                return 0
            }
            return 160
        case .Interval:
            if bIsExpandedDuration {
                return 270
            }
            return 0
        case .Bell:
            return 96
        case .Babysitter:
            return 96
        case .Doctor:
            return 96
        case .StarOrExclamation:
            return 96
        case .Camera:
            
            if settingData.memoImage != nil {
                return 170
            }
            return 45
        case .Splitter4:
            return 70
            
        default:
            return 20
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
//        if cell.respondsToSelector(Selector("setSeparatorInset:")) {
//            let type:kContentCell = kContentCell(rawValue: indexPath.row)!
//            let deltaEdge = UIEdgeInsets(top:0,left:0,bottom:0,right:0)
//            switch type {
//            case .TimeLeft,.DateTimePicker:
//                cell.separatorInset = deltaEdge
//            default:
//                return
//            }
//        }
    }
    
    func refreshViews() {
        lblTimeBothText.text = "Time Note"
        lblDuration2.text = "Duration"
        lblDurationInfo2.text = "Time"
        tableView.reloadData()
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let t = datePicker.date
        //let hours = pickerHours.selectedRowInComponent(0)
        //let minutes = pickerMinutes.selectedRowInComponent(0)
        let type:kContentCell = kContentCell(rawValue: indexPath.row)!
        
        switch (type){
        case .TimeLeft:
            if bIsVisibleTimePicker{
                settingData.time = t
            }
            refreshDatePicker(!bIsVisibleTimePicker)
            refreshViews()
        case .Interval:
            refreshViewPicker(false)
            refreshViews()
        default:
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
    
    
    
    func checkItemChanged() {
        
        // check all any item changed
        bItemChanged = false
        
        repeat {
            let formatter : NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let szInitTime = formatter.stringFromDate(init_settingData.time!)
            let szSettTime = formatter.stringFromDate(settingData.time!)
            
            if !szInitTime.isEqual(szSettTime) {
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
            
            if init_settingData.bBabysitter != settingData.bBabysitter {
                bItemChanged = true
                break
            }
            
            if init_settingData.bDoctor != settingData.bDoctor {
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