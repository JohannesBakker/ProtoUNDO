//
//  EditPumpTableViewController.swift
//  NoteMore
//
//  Created by Curly Brackets on 9/26/15.
//  Copyright © 2015 Curly Brackets. All rights reserved.
//
enum kEditPumpContentCell : Int {
    case SplitterFirst = 0
    case TimeLeft           //3
    case DateTimePicker     //4
    case QuantityCell
    case Splitter1
    case DurationCell
    case Splitter5
    case StarOrExclamation  //10
    case Splitter3          //11
    case Camera             //12
    case SplitterLast          //13
    case DeleteCell         //14
    
}
import UIKit

class EditPumpTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var logEvent : LogEvent!
    var mSelectedIndex: NSInteger! = 0
    var durationHour: NSInteger! = 0
    var durationMin: NSInteger! = 0
    var bIsVisibleTimePicker:Bool = false
    var bIsExpandedQuantity:Bool = false
    var bIsExpandedDuration:Bool = false
    
    //===============================================
    
    @IBOutlet weak var lblTimeBothText: UILabel!
    
    @IBOutlet weak var lblTimeResult: UILabel!
    
    //============================================
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // ============================================
    @IBOutlet weak var memoTextInput: UITextField!
    
    // ============================================
    
    @IBOutlet weak var btnDelete: UIButton!
    
    // ============================================
    
    @IBOutlet weak var lblQuantityTitle: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var quantitySlider: UISlider!
    
    // ============================================

    @IBOutlet weak var durationHourPickerView: UIPickerView!
    @IBOutlet weak var durationMinPickerView: UIPickerView!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblDurationTitle: UILabel!
    
    // ============================================
    @IBOutlet weak var lblQuantitySeparator: UILabel!
    
    @IBOutlet weak var lblQuantityHeightConstraint: NSLayoutConstraint!
    
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
        activityIndicator.center = self.tableView.center
        activityIndicator.color = UIColor.darkGrayColor()
        tableView.addSubview(activityIndicator)
        
        let alert = UIAlertController(title: "Confirm", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (ACTION :UIAlertAction!) in
            
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!)in
            DataSource.sharedDataSouce.deleteEventWithIndex(self.mSelectedIndex)
            self.activityIndicator.startAnimating()
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
            
            logEvent.image =  memoImageView.image
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
//        logEvent.starMark = settingData.bIsSelectedStar
//        logEvent.exclamationMark = settingData.bIsSelectedExclamation
//        logEvent.babyMark = settingData.bBabysitter
//        logEvent.doctorMark = settingData.bDoctor
//        logEvent.bIsJustNow = settingData.bIsNotJustNow
//        logEvent.noteTime = settingData.time
//        logEvent.image = settingData.memoImage

        // Assign Text
        if let text = memoTextInput.text {
            logEvent.note = text
        }
        else {
            logEvent.note = ""
        }
        
        
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
        logEvent.time = datePicker.date.timeIntervalSinceReferenceDate;
        lblTimeResult.text = dateFormatter.stringFromDate(datePicker.date);
    }
    
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
    
    lazy var dateFormatter : NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
        }()

    
    var oldState = 0
    var initTime:NSDate?
    
    @IBOutlet weak var btnStar: UIButton!
    
    @IBOutlet weak var btnExclamation: UIButton!
    
    @IBOutlet weak var imgStar: UIImageView!
    
    @IBOutlet weak var imgExclamation: UIImageView!
    
    @IBAction func OnStarTapped(sender: UIButton) {
        SetStar(!logEvent.starMark)
    }
    
    @IBAction func OnExclamationTapped(sender: UIButton) {
        SetExclamation(!logEvent.exclamationMark)
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
        logEvent.starMark = isSel
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
        logEvent.exclamationMark = isSel
    }
    
    func refreshDatePicker(isExpand:Bool){
        var t = initTime
        t = NSDate(timeIntervalSinceReferenceDate: logEvent.time)
        
        lblTimeResult.text = dateFormatter.stringFromDate(t!);
        
        datePicker.setDate(t!, animated: true)
        bIsVisibleTimePicker = isExpand
    }
    
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
        
        initTime = NSDate(timeIntervalSinceReferenceDate: logEvent.time)
        
        datePicker.addTarget(self, action: "datePickerValueChanged:", forControlEvents: UIControlEvents.ValueChanged)

        memoTextInput.attributedPlaceholder = NSAttributedString(string: memoTextInput.text!, attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
        
        memoTextInput.text = "";
        
        let event: LogEvent! = DataSource.sharedDataSouce.EventAtIndex(mSelectedIndex);
        lblTimeBothText.text = "Time \(event.subtitle())"
        
        lblQuantity.text = "\(Int(logEvent.value)) oz"
        quantitySlider.value = logEvent.value
        
        lblQuantityTitle.text = "Quantity \(event.subtitle())"
        lblDurationTitle.text = "Duration \(event.subtitle())"
        
        self.title = "\(event.subtitle()) Edit"
        
        lblQuantityHeightConstraint.constant = 0.5
        
        SetDuration()
        
        // by Marko
        // Update UIs according the settings Data
        SetStar(logEvent.starMark)
        SetExclamation(logEvent.exclamationMark)
        
        memoTextInput.text = logEvent.note
        
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
        let type:kEditPumpContentCell = kEditPumpContentCell(rawValue: indexPath.row)!
        
        switch(type)
        {
            
        case .TimeLeft:
            return 45
        case .DateTimePicker:
            if bIsVisibleTimePicker == false {
                return 0
            }
            return 160
        case .QuantityCell:
            if !bIsExpandedQuantity
            {
                return 45
            }
            return 96
        case .DurationCell:
            if !bIsExpandedDuration
            {
                return 45
            }
            return 205
        case .StarOrExclamation:
            return 96
        case .Camera:
            
            if logEvent.image != nil {
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
        tableView.reloadData()
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let t = datePicker.date
        //let hours = pickerHours.selectedRowInComponent(0)
        //let minutes = pickerMinutes.selectedRowInComponent(0)
        let type:kEditPumpContentCell = kEditPumpContentCell(rawValue: indexPath.row)!
        
        switch (type){
        case .TimeLeft:
            if bIsVisibleTimePicker{
                logEvent.time = t.timeIntervalSinceReferenceDate
            }
            refreshDatePicker(!bIsVisibleTimePicker)
            refreshViews()
        case .QuantityCell:
            bIsExpandedQuantity = !bIsExpandedQuantity
            refreshViews()
        case .DurationCell:
            bIsExpandedDuration = !bIsExpandedDuration
            refreshViews()
//        case .Interval:
//            refreshViews()
        default:
            refreshViews()
        }
    }
    
    // MARK: - UISlider
    
    @IBAction func quantityChanged(sender: AnyObject) {
        lblQuantity.text = "\(Int(quantitySlider.value)) oz"
        logEvent.value = quantitySlider.value
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == durationHourPickerView
        {
            return 24
        }
        
        return 60
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == durationHourPickerView
        {
            durationHour = row
        }
        else
        {
            durationMin = row
        }
        
        SetDuration()
    }
    
    func SetDuration()
    {
        if durationHour == 0
        {
            lblDuration.text = "\(durationMin) min"
        }
        else
        {
            lblDuration.text = "\(durationHour) h   \(durationMin) min"
        }

    }

}