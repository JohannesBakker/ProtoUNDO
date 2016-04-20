//
//  EditNoteTableViewController.swift
//  NoteMore
//
//  Created by Curly Brackets on 9/26/15.
//  Copyright © 2015 Curly Brackets. All rights reserved.
//
enum kEditNoteContentCell : Int {
    case SplitterFirst = 0
    case TimeLeft           //3
    case DateTimePicker     //4
    case Interval           //6
    case Spliter2           //9
    case Babysitter
    case Spliter6
    case Doctor
    case Splitter5
    case StarOrExclamation  //10
    case Splitter3          //11
    case Camera             //12
    case SplitterLast          //13
    case DeleteCell         //14
    
}
import UIKit

class EditNoteTableViewController: UITableViewController,  UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var logEvent : LogEvent!
    var mSelectedIndex: NSInteger! = 0
    var settingData:NoteMoreSettingData = NoteMoreSettingData()
    var bIsVisibleTimePicker:Bool = false
    var bIsExpandedDuration:Bool = false
    
    //===============================================
    
    @IBOutlet weak var lblTimeBothText: UILabel!
    
    @IBOutlet weak var lblTimeResult: UILabel!
    
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
    
    // ============================================
    
    @IBOutlet weak var btnDelete: UIButton!
    // ============================================
    
    
    
    // Activity Indicator
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
 
    @IBOutlet weak var memoImageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    // by Marko
    // MARK: - View life cycle
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden=false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.hidden=false
    }
    
    // by Marko
    // MARK: - IBAction slot
    
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
    
    @IBAction func onTapCancel(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onTapSave(sender: AnyObject) {
        
        // save function
        // Convert SettingsData to LogEvent
        logEvent.starMark = settingData.bIsSelectedStar
        logEvent.exclamationMark = settingData.bIsSelectedExclamation
        logEvent.babyMark = settingData.bBabysitter
        logEvent.doctorMark = settingData.bDoctor
        logEvent.bIsJustNow = settingData.bIsNotJustNow
        logEvent.time = (settingData.time?.timeIntervalSinceReferenceDate)!
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
        activityIndicator.color = UIColor.darkGrayColor()
        tableView.addSubview(activityIndicator)
        
        DataSource.sharedDataSouce.updateEventWithIndex(self.mSelectedIndex, logEvent: logEvent)
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        self.activityIndicator.startAnimating()
    }
    
//    var logEvent = LogEvent() {
//        didSet {
//            
//            // convert LogEvent to NoteMoreSettingData
//            settingData.bIsSelectedStar = logEvent.starMark
//            settingData.bIsSelectedExclamation = logEvent.exclamationMark
//            settingData.bBabysitter = logEvent.babyMark
//            settingData.bDoctor = logEvent.doctorMark
//            
//            settingData.bIsNotJustNow = logEvent.bIsJustNow
//            settingData.time = logEvent.noteTime
//            if settingData.time == nil {
//                settingData.time = NSDate()
//            }
//            
//            if let note = logEvent.note {
//                settingData.strNoteText = note
//            }
//        }
//    }
    
    // MARK: - Previous Code
    func datePickerValueChanged(sender: UIDatePicker)
    {
        settingData.time = datePicker.date;
        lblTimeResult.text = dateFormatter.stringFromDate(datePicker.date);
    }

    lazy var dateFormatter : NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
        }()
    
//    func getDateFormat(selectedTime:NSDate) -> String
//    {
//        let dateFormatter = NSDateFormatter()
//        var text : String = ""
//        if NSCalendar.currentCalendar().isDateInToday(selectedTime) {
//            dateFormatter.dateFormat = "h:mm a"
//            text = "Today " + dateFormatter.stringFromDate(selectedTime)
//        }else if NSCalendar.currentCalendar().isDateInTomorrow(selectedTime) {
//            dateFormatter.dateFormat = "h:mm a"
//            text = "Tomorrow " + dateFormatter.stringFromDate(selectedTime)
//        }else if NSCalendar.currentCalendar().isDateInYesterday(selectedTime) {
//            dateFormatter.dateFormat = "h:mm a"
//            text = "Yesterday " + dateFormatter.stringFromDate(selectedTime)
//        }else {
//            dateFormatter.dateFormat = "MM-dd h:mm a"
//            text = dateFormatter.stringFromDate(selectedTime)
//        }
//        return text
//    }
//    
    
    func getPickerFormat(hours:Int,minutes:Int) -> String{
        var text:String=""
        if hours>0{
            text = String(format:"%02d hour %02d min",hours,minutes)
        }else if minutes>0{
            text = String(format:"%02d min",minutes)
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
        return row.description
    }
    
    @IBAction func OnTappedClearTime(sender: UIButton) {
            settingData.time = initTime
        refreshDatePicker(false)
        refreshViews()
    }
    
    @IBAction func OnTappedClearPicker(sender: UIButton) {

        refreshViewPicker(false)
        refreshViews()
    }
    
    @IBOutlet weak var btnStar: UIButton!
    
    @IBOutlet weak var btnExclamation: UIButton!
    
    @IBOutlet weak var imgStar: UIImageView!
    
    @IBOutlet weak var imgExclamation: UIImageView!
    
    @IBAction func OnStarTapped(sender: UIButton) {
        SetStar(!settingData.bIsSelectedStar)
    }
    
    @IBAction func OnExclamationTapped(sender: UIButton) {
        SetExclamation(!settingData.bIsSelectedExclamation)
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
//        var t = initTime
//        t = settingData.time!
//
//        if isExpand {
//            if t == initTime {
//                lblTimeNotSet.hidden = false
//                lblTimeEdit.hidden = true
//                btnClearTime.hidden = true
//            }else{
//                lblTimeNotSet.hidden = true
//                lblTimeEdit.hidden = false
//                btnClearTime.hidden = false
//                lblTimeEdit.text = getDateFormat(t!)
//            }
//            lblTimeResult.hidden = true
//        }else{
//            if t == initTime {
//                lblTimeNotSet.hidden = false
//                lblTimeResult.hidden = true
//            }else{
//                lblTimeNotSet.hidden = true
//                lblTimeResult.hidden = false
//                lblTimeResult.text = getDateFormat(t!)
//            }
//            lblTimeEdit.hidden = true
//            btnClearTime.hidden = true
//        }
//        datePicker.setDate(t!, animated: true)
//        bIsVisibleTimePicker = isExpand
        
        var t = initTime
        t = settingData.time!
        
        lblTimeResult.text = dateFormatter.stringFromDate(t!);
        
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
        refreshViews()
    }
    
    @IBAction func OnTappedDurationStart(sender: UIButton) {
    }
    
    @IBAction func OnTappedDurationReset(sender: UIButton) {
    }
    
    @IBOutlet weak var lblDurationReady1: UILabel!
    @IBOutlet weak var lblDurationReady2: UILabel!
    
    @IBAction func OnTappedDurationOR1(sender: UIButton) {
        bIsExpandedDuration = true
        self.tableView.reloadData()
    }
    
    @IBAction func OnTappedDurationOR2(sender: UIButton) {
        bIsExpandedDuration = false
        self.tableView.reloadData()
    }
    @IBOutlet weak var babysitterButton: UIButton!
    
    @IBAction func babysitterAction(sender: AnyObject) {
        settingData.bBabysitter = !settingData.bBabysitter
        babysitterButton.selected = settingData.bBabysitter
    }
    @IBOutlet weak var doctorButton: UIButton!

    @IBAction func doctorAction(sender: AnyObject) {
        settingData.bDoctor = !settingData.bDoctor
        doctorButton.selected = settingData.bDoctor
    }
    @IBOutlet weak var vwNeededBorder2: UIView!
    
    
    func dataChanged()
    {
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"dataChanged", name: kLogObjectUpdatedNotification, object: nil)
        
        btnDelete.clipsToBounds = true
        btnDelete.layer.cornerRadius = 13
        
        pickerHours.delegate = self
        pickerHours.dataSource = self
        
        pickerMinutes.delegate = self
        pickerMinutes.dataSource = self
        
        initTime = settingData.time
        
        datePicker.addTarget(self, action: "datePickerValueChanged:", forControlEvents: UIControlEvents.ValueChanged)

        vwNeededBorder2.layer.borderWidth = 0.5
        vwNeededBorder2.layer.borderColor = UIColor(red: 224/255.0, green: 224/255.0, blue: 224/255.0, alpha: 1.0).CGColor

        memoTextInput.attributedPlaceholder = NSAttributedString(string: memoTextInput.text!, attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
        
        memoTextInput.text = "";
        
        self.title = "Note Edit"
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //       return UITableViewAutomaticDimension
        let type:kEditNoteContentCell = kEditNoteContentCell(rawValue: indexPath.row)!
        
        switch(type)
        {
        case .TimeLeft:
                return 45
        case .DateTimePicker:
            if bIsVisibleTimePicker == false  {
                return 0
            }
            return 160
        case .Interval:
            if bIsExpandedDuration {
                return 270
            }
            return 0
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
        case .DeleteCell:
            return 57;
        case .SplitterFirst:
            return 35
        case .SplitterLast:
            return 35
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
        tableView.reloadData()
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let t = datePicker.date
        //let hours = pickerHours.selectedRowInComponent(0)
        //let minutes = pickerMinutes.selectedRowInComponent(0)
        let type:kEditNoteContentCell = kEditNoteContentCell(rawValue: indexPath.row)!
        
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
    }
    
    // The number of columns of data
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 60
    }
    
    func setSettingsData(logData : LogEvent!)
    {
        logEvent = logData
        
        // convert LogEvent to NoteMoreSettingData
        settingData.bIsSelectedStar = logData.starMark
        settingData.bIsSelectedExclamation = logData.exclamationMark
        settingData.bBabysitter = logData.babyMark
        settingData.bDoctor = logData.doctorMark
        
        settingData.bIsNotJustNow = logData.bIsJustNow
        settingData.time = NSDate(timeIntervalSinceReferenceDate: logData.time)
        
        if settingData.time == nil {
            settingData.time = NSDate()
        }
        
        if let note = logData.note {
            settingData.strNoteText = note
        }

    }
}