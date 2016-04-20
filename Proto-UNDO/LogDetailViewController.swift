//
//  LogDetailViewController.swift
//  Proto-UNDO
//
//  Created by Alert on 08/10/15.
//  Copyright © 2015 Curly Brackets. All rights reserved.
//

import UIKit
enum kLogDetailCellType:Int{
    case separatorStart = 0
    case Time
    case Quantity
    case separatorQuantity
    case TimeSecond
    case separatorTimeSecond
    case Duration
    case separatorDuration
    case DurationSecond
    case separatorDurationSecond
    case Type
    case  separatorType
    case Color
    case separatorColor
    case Tags
    case separatorTags
    case TextAndPhoto
    case separatorTextAndPhoto
}

class LogDetailViewController: UITableViewController {

    //MARK: Outlets
   // @IBOutlet weak var lblTitle: UILabel!
    //@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var timeTitle: UILabel!
    @IBOutlet weak var timeValue: UILabel!

    @IBOutlet weak var quantityTitle: UILabel!
    @IBOutlet weak var quanttityValue: UILabel!
    
    @IBOutlet weak var timeSecondTitle: UILabel!
    @IBOutlet weak var timeSecondValue: UILabel!
    
    @IBOutlet weak var durationTitle: UILabel!
    @IBOutlet weak var durationValue: UILabel!

    @IBOutlet weak var durationSecondTitle: UILabel!
    @IBOutlet weak var durationSecondValue: UILabel!

    @IBOutlet weak var typeTitle: UILabel!
    @IBOutlet weak var typeValue: UILabel!
    
    @IBOutlet weak var colorTitle: UILabel!
    @IBOutlet weak var colorValue: UILabel!
    
    @IBOutlet weak var marksView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UILabel!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var textHeight: NSLayoutConstraint!
    @IBOutlet weak var imageTextSeparator: NSLayoutConstraint!

    @IBOutlet weak var navigateBackItem: UIBarButtonItem!
    //@IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var btnDelete: UIButton!
    
    var event:LogEvent! = LogEvent()
    //MARK: Properties
    
    
    var mSelectedIndex: NSInteger! = 0
    // MARKL appearance constants
    
    let marksViewHeight:CGFloat = 95
    let marksSpacing:CGFloat = 4.0
    override func viewDidLoad() {
        super.viewDidLoad()

        // register eventRemoved Action
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"eventRemoved:", name: kLogObjectRemovedNotification, object: nil)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // load Data
        let _event: LogEvent! = DataSource.sharedDataSouce.EventAtIndex(mSelectedIndex);
        if _event != nil
        {
            self.event = _event;
        }
        
        self.view.layoutSubviews()
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        loadData()
        
        // add Delete button
        let delBtn = UIButton(type: .Custom);
        let window = UIApplication.sharedApplication().keyWindow!
        let frame = CGRectMake(-1, window.frame.height-58, window.frame.width+4, 60)
        delBtn.frame = frame
        delBtn.layer.borderWidth = 0.5;
        delBtn.layer.borderColor = UIColor(red: 255/255.0, green: 59/255.0, blue: 48/255.0, alpha: 1.0).CGColor
        delBtn.addTarget(self, action: "btnDeletePressed:", forControlEvents: .TouchUpInside)
        delBtn.setTitle("Delete", forState: .Normal)
        delBtn.setTitleColor(UIColor(red: 255/255.0, green: 59/255.0, blue: 48/255.0, alpha: 1.0), forState: .Normal)
        delBtn.backgroundColor = UIColor.whiteColor()
        self.btnDelete = delBtn
        delBtn.alpha = 0
        UIView.animateWithDuration(0.2) { () -> Void in
            delBtn.alpha = 1
        }
        window.addSubview(delBtn)
    }
    override func viewDidDisappear(animated: Bool) {
        btnDelete.removeFromSuperview()
        self.btnDelete = nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - subroutunes
    func heightforCellIndex(cellIndex:kLogDetailCellType) -> CGFloat{

        if (cellIndex == .TextAndPhoto){
            if (event.image != nil || event.imageFile != nil || event.note != nil){
                var result:CGFloat = 20.0
                if (event.image != nil || event.imageFile != nil){
                    result = result + imageHeight.constant + CGFloat(20.0)
                }
                if (event.note != nil){
                    if (event.note!.isEmpty){
                        if (result == 20.0){
                            return 0
                        }
                    }
                    else{
                        result = result + textHeight.constant + 20.0
                    }
                }
                return result
            }
            else{
                return 0
            }
        }
        
        if (cellIndex == .separatorTextAndPhoto){
            if (heightforCellIndex(.TextAndPhoto) == 0 ){
                return 0
            }
            return 45
        }
        
        let defaultCellHeight:CGFloat = tableView.rowHeight
        let defaultSeparatorHeight:CGFloat = 20.0
        
        // unmutable cells
        switch (cellIndex) {
            case .separatorStart:
                return 35
            
            case .Time:
                return defaultCellHeight
            
            case .Tags:
                if (marksView.subviews.count == 0) {
                    return 0
                }
                else{
                    return marksViewHeight
                }
            
            case .separatorTags:
                if (heightforCellIndex(.TextAndPhoto) == 0){
                    return 0
                }
                return defaultSeparatorHeight
            
            
            case .TimeSecond, .DurationSecond:
                if event.type.isEqualToString("breast") {
                    break
                }
                return 0
            
            case .separatorTimeSecond, .separatorDurationSecond:
                if event.type.isEqualToString("breast") {
                    break
                }
                return 0
            
            default:
                break
        }


        
        switch(event.type) {
            case kUndefined:
                return 0
        
            case "bottle":
                switch (cellIndex) {
                    case .Quantity:
                        return defaultCellHeight
                    
                    case .separatorQuantity:
                        return defaultSeparatorHeight
                    
                    case .Duration:
                        return defaultCellHeight
                    
                    case .separatorDuration:
                        if heightforCellIndex(.TextAndPhoto) == 0 && heightforCellIndex(.Tags) == 0 {
                            return 0
                        }
                        return defaultSeparatorHeight
                    
                    case .Type:
                        return 0
                    
                    case .separatorType:
                        return 0
                    
                    case .Color:
                        return 0
                    
                    case .separatorColor:
                        return 0
                    
                    default:
                        return defaultCellHeight
                }
            
            case "breast":
                let szLeft = event.timeString(event.leftHours, mins: event.leftMins)
                let szRight = event.timeString(event.rightHours, mins: event.rightMins)
                
                switch (cellIndex) {
                    case .Quantity:
                        return 0
                    
                    case .separatorQuantity:
                        if event.action.isEqualToString("both") {
                            return defaultSeparatorHeight
                        }
                        return 0
                        
                    case .TimeSecond:
//                        if event.action.isEqualToString("both") && event.timeRight != nil {
                        if event.action.isEqualToString("both") {
                            
                            return defaultCellHeight
                        }
                        return 0
                    
                    case .separatorTimeSecond:
                        if szLeft  == "" && szRight == "" {
                            return 0
                        }
                        return defaultSeparatorHeight
                    
                    case .Duration:
                        if szLeft == "" && szRight == "" {
                            return 0
                        }
                        return defaultCellHeight
                    
                    case .separatorDuration:
                        // check below
                        if szLeft != "" && szRight != "" {
                            return defaultSeparatorHeight
                        }
                        return 0
                    
                    case.DurationSecond:
                        if szLeft != "" && szRight != "" {
                            return defaultCellHeight
                        }
                        return 0
                    
                    case.separatorDurationSecond:
                        if heightforCellIndex(.Tags) == 0 {
                            return 0
                        }                        
                        return defaultSeparatorHeight
                    
                    case .Type:
                        return 0
                    
                    case .separatorType:
                        return 0
                    
                    case .Color:
                        return 0
                    
                    case .separatorColor:
                        return 0
                    
                    default:
                        return defaultCellHeight
                }
            
                case "medicine":
                    switch (cellIndex) {
                        case .Quantity:
                            return defaultCellHeight
                        
                        case .separatorQuantity:
                            if heightforCellIndex(.TextAndPhoto) == 0 && heightforCellIndex(.Tags) == 0 {
                                return 0
                            }
                            return defaultSeparatorHeight
                        
                        case .Duration:
                            return 0
                        
                        case .separatorDuration:
                            return 0
                        
                        case .Type:
                            return 0
                        
                        case .separatorType:
                            return 0
                        
                        case .Color:
                            return 0
                        
                        case .separatorColor:
                            return 0
                        
                        default:
                            return defaultCellHeight
                    }
            
                case kNote:
                    switch (cellIndex) {
                        case .Quantity:
                            return 0
                        
                    case .separatorQuantity:
                        // check below
                        if heightforCellIndex(.TextAndPhoto) == 0 && heightforCellIndex(.Tags) == 0 {
                            return 0
                        }
                        return defaultSeparatorHeight
                        
                    case .Duration:
                        return 0
                        
                    case .separatorDuration:
                        return 0
                        
                    case .Type:
                        return 0
                        
                    case .separatorType:
                        return 0
                        
                    case .Color:
                        return 0
                        
                    case .separatorColor:
                        return 0
                        
                    default:
                        return defaultCellHeight
                }
            
            case  "pee":
                switch (cellIndex) {
                    case .Quantity:
                        return 0
                    
                    case .separatorQuantity:
                        return 0
                    
                    case .Duration:
                        return 0
                    
                    case .separatorDuration:
                        return 0
                    
                    case .Type:
                        return 0
                    
                    case .separatorType:
                        if event.optValue != nil &&
                            (event.optValue >= PeeMoreSettingData.PeeOptions.Just.rawValue && event.optValue <= PeeMoreSettingData.PeeOptions.PaleYello.rawValue) {
                                return defaultSeparatorHeight
                        }
                        return 0
//                        return defaultSeparatorHeight
                    
                    case .Color:
                        if event.optValue != nil &&
                            (event.optValue >= PeeMoreSettingData.PeeOptions.Just.rawValue && event.optValue <= PeeMoreSettingData.PeeOptions.PaleYello.rawValue) {
                            return defaultCellHeight
                        }
                        return 0
                    
                    case .separatorColor:
                        // check below
                        if heightforCellIndex(.TextAndPhoto) != 0 || heightforCellIndex(.Tags) != 0 {
                            return defaultSeparatorHeight
                        }
                        return 0
                    
                    default:
                        return defaultCellHeight
                }

            case "poop":
                switch (cellIndex) {
                    case .Quantity:
                        return 0
                    
                    case .separatorQuantity:
                        return 0
                    
                    case .Duration:
                        return 0
                    
                    case .separatorDuration:
                        if event.optValue != nil &&
                            (event.optValue >= PoopMoreSettingData.PoopOptions.Just.rawValue && event.optValue <= PoopMoreSettingData.PoopOptions.Diarrhea.rawValue) {
                                return defaultSeparatorHeight
                        }
                        return 0
//                        return defaultSeparatorHeight
                    
                    case .Type:
                        if event.optValue != nil &&
                            (event.optValue >= PoopMoreSettingData.PoopOptions.Just.rawValue && event.optValue <= PoopMoreSettingData.PoopOptions.Diarrhea.rawValue) {
                                return defaultCellHeight
                        }
                        return 0
                    
                    case .separatorType:
                        // check below
                        if heightforCellIndex(.TextAndPhoto) != 0 || heightforCellIndex(.Tags) != 0 {
                            return defaultSeparatorHeight
                        }
                        return 0
                    
                    case .Color:
                        return 0
                    
                    case .separatorColor:
                        return 0
                    
                    default:
                        return defaultCellHeight
                }
            
            case "pump":
                switch (cellIndex) {
                    case .Quantity:
                        return defaultCellHeight
                    
                    case .separatorQuantity:
                        return defaultSeparatorHeight
                    
                    case .Duration:
                        return defaultCellHeight
                    
                    case .separatorDuration:
                        // check below
                        if heightforCellIndex(.TextAndPhoto) == 0 && heightforCellIndex(.Tags) == 0 {
                            return 0
                        }
                        return defaultSeparatorHeight
                    
                    case .Type:
                        return 0
                    
                    case .separatorType:
                        return 0
                    
                    case .Color:
                        return 0
                    
                    case .separatorColor:
                        return 0
                    
                    default:
                        return defaultCellHeight
                }
            
            case "sleep":
                switch (cellIndex) {
                    case .Quantity:
                        return 0
                    
                    case .separatorQuantity:
                        return defaultSeparatorHeight
                    
                    case .Duration:
                        return defaultCellHeight
                    
                    case .separatorDuration:
                        // check below
                        if heightforCellIndex(.TextAndPhoto) == 0 && heightforCellIndex(.Tags) == 0 {
                            return 0
                        }
                        return defaultSeparatorHeight
                    
                    case .Type:
                        return 0
                    
                    case .separatorType:
                        return 0
                    
                    case .Color:
                        return 0
                    
                    case .separatorColor:
                        return 0
                    
                    default:
                        return defaultCellHeight
                }
            
            default:
                return defaultCellHeight
        }
    }
    
    //MARK: - Methods
    
    func loadData()
    {
        NSLog("loadData")
        NSLog("%ld", mSelectedIndex)

        if event != nil
        {

          //  lblTitle.text = String(format: "%@ Detail", event.name.capitalizedString)
            self.title = String(format: "%@ Detail", event.subtitle().capitalizedString);

            // time
            timeTitle.text = String(format: "Time %@", event.subtitle().capitalizedString)
            timeValue.text = event.dateTimeString(event.time)
            
            //quantity
            quantityTitle.text  = String(format: "Quantity %@" ,event.subtitle()
            .capitalizedString)
            quanttityValue.text = event.formatedValue()
            
            // Duration
            if event.type.isEqualToString("breast") {
                let szLeft = event.timeString(event.leftHours, mins: event.leftMins)
                let szRight = event.timeString(event.rightHours, mins: event.rightMins)
                
                var szDurationTitle:String = ""
                var szDurationValue:String = ""
                var szDurationSecondTitle:String = ""
                var szDurationSecondValue:String = ""
                var szTimeTitle:String = ""
                var szTimeValue:String = ""
                var szTimeSecondTitle:String = ""
                var szTimeSecondValue:String = ""
                
                if event.action.isEqualToString("both") {
                    
                    szTimeTitle = "Time Breast Left"
                    szTimeSecondTitle = "Time Breast Right"
                    
                    if event.timeLeft == nil {
                        event.timeLeft = NSDate(timeIntervalSinceReferenceDate: event.time)
                    }
                    
                    if event.timeRight == nil {
                        event.timeRight = NSDate(timeIntervalSinceReferenceDate: event.time)
                    }
                    
                    szTimeValue = event.dateTimeStringFromDate(event.timeLeft!)
                    szTimeSecondValue = event.dateTimeStringFromDate(event.timeRight!)
                }
                else if event.action.isEqualToString("left") {
                    if event.timeLeft == nil {
                        event.timeLeft = NSDate(timeIntervalSinceReferenceDate: event.time)
                    }
                    szTimeTitle = "Time Breast Left"
                    szTimeValue = event.dateTimeStringFromDate(event.timeLeft!)
                }
                else {
                    if event.timeRight == nil {
                        event.timeRight = NSDate(timeIntervalSinceReferenceDate: event.time)
                    }

                    szTimeTitle = "Time Breast Right"
                    szTimeValue = event.dateTimeStringFromDate(event.timeRight!)
                }
                
                timeTitle.text = szTimeTitle
                timeValue.text = szTimeValue

                timeSecondTitle.text = szTimeSecondTitle
                timeSecondValue.text = szTimeSecondValue
                
                
                if szLeft == "" && szRight == "" {
                    // hide
                }
                else if szLeft != "" && szRight != "" {
                    szDurationTitle = "Duration Breast Left"
                    szDurationValue = String(format: "%@", szLeft)
                    szDurationSecondTitle = "Duration Breast Right"
                    szDurationSecondValue = String(format: "%@", szRight)
                }
                else {
                    szDurationTitle = String(format: "Duration %@", event.subtitle())
                    szDurationValue = String(format: "%@%@", szLeft, szRight)
                }
                
                durationTitle.text = szDurationTitle
                durationValue.text = szDurationValue
                durationSecondTitle.text = szDurationSecondTitle
                durationSecondValue.text = szDurationSecondValue
            }

            //type
            typeTitle.text = "Type"
            if event.type.isEqualToString("poop") {
                
                if event.detailName != nil {
                    typeValue.text = String(format: "%@", event.detailName!)
                }
                else {
                    if event.action == "diarrhea" {
                        event.optValue = PoopMoreSettingData.PoopOptions.Diarrhea.rawValue
                        typeValue.text = "Diarrhea"
                    }
                    else if event.optValue != nil && event.optValue == PoopMoreSettingData.PoopOptions.None.rawValue {
                        typeValue.text = ""
                    }
                    else {
                        event.optValue = PoopMoreSettingData.PoopOptions.Just.rawValue
                        typeValue.text = "Just Poop"
                    }
                }
            }
            
            // color
            colorTitle.text = "Color"
            if event.type.isEqualToString("pee") {
                if event.detailName != nil {
                    colorValue.text = String(format: "%@", event.detailName!)
                }
                else {
                    if event.optValue != nil && event.optValue == PeeMoreSettingData.PeeOptions.None.rawValue {
                        colorValue.text = String(format:"%@", "")
                    }
                    else {
                        colorValue.text = String(format:"%@", "Just Pee")
                        event.optValue = PeeMoreSettingData.PeeOptions.Just.rawValue
                    }
                    
                }
            }
            

            // Text and Photo
            if (event.image != nil || event.imageFile != nil){
                // do image
                if (event.image != nil){
                    imageView.image = event.image
                }
                else{
                    event.getImage({ (image:UIImage?, error:NSError?) -> Void in
                        if (image != nil){
                            self.imageView.image = image
                        }
                    })
                }
            }
            else{
                imageHeight.constant = 0
                imageTextSeparator.constant = 0
            }
            if (event.note != nil){
                textView.text = event.note
                let size:CGSize = textView.sizeThatFits(textView.frame.size)
                textHeight.constant = size.height
            }
            else {
                textHeight.constant = 0
            }
            textView.superview?.updateConstraints()
            // tags
            makeTagsView()
            
            tableView.reloadData()
        }
    }
    func makeTagsView() {
        // Tags
        var marksPicures:[UIImageView] = []
        let rect = CGRectMake(0, 0, 35, 35)
        
        if (event.parentMark) {
            let iv = UIImageView(frame: rect);
            iv.contentMode = UIViewContentMode.Center
            iv.image = UIImage(named: "parent_log_detail")
            marksPicures.append(iv)
        }
        
        if (event.starMark) {
            let iv = UIImageView(frame:rect);
            iv.contentMode = UIViewContentMode.Center
            iv.image = UIImage(named: "star_log_detail")
            marksPicures.append(iv)
        }
        
        if (event.exclamationMark) {
            let iv = UIImageView(frame:rect);
            iv.contentMode = UIViewContentMode.Center
            iv.image = UIImage(named: "exclamation_log_detail")
            marksPicures.append(iv)
        }
        
        if (event.babyMark){
            let iv = UIImageView(frame:rect);
            iv.contentMode = UIViewContentMode.Center
            iv.image = UIImage(named: "babysitter_log_detail")
            marksPicures.append(iv)
        }
        if (event.doctorMark){
            let iv = UIImageView(frame:rect);
            iv.contentMode = UIViewContentMode.Center
            iv.image = UIImage(named: "doctor_log_detail")
            marksPicures.append(iv)
        }
        
        // remove sub views on marksview
        if marksView.subviews.count > 0 {
            
            for smallView in marksView.subviews {
                smallView.removeFromSuperview()
            }
        }
        
        if (marksPicures.count>0) {
            var allwidth:CGFloat = (rect.width) * CGFloat(marksPicures.count)
            allwidth  =  allwidth + (marksSpacing * CGFloat(marksPicures.count-1))
            var startingX:CGFloat = (marksView.frame.width - allwidth)*0.5
            let stepX:CGFloat = rect.width + marksSpacing
            let offsetY:CGFloat = (marksViewHeight - rect.height)*0.5
            for iv:UIImageView in marksPicures{
                marksView.addSubview(iv)
                iv.frame = CGRectMake(startingX, offsetY, rect.width, rect.height);
                startingX = startingX + stepX
            }
        }
    }

    
    @objc func eventRemoved(notification:NSNotification){
      //  activityIndicator.stopAnimating()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func btnLogsPressed(sender: AnyObject) {
        self .dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnEditPressed(sender: AnyObject) {
        NSLog("btnEditPressed")
        
        let event: LogEvent! = DataSource.sharedDataSouce.EventAtIndex(mSelectedIndex);
        
        if event.type.isEqualToString("note")
        {
            self.performSegueWithIdentifier("EditNoteSegue", sender: self)
        }
        else if event.type.isEqualToString("medicine")
        {
            self.performSegueWithIdentifier("EditMedicineSegue", sender: self)
        }
        else  if event.type.isEqualToString("sleep")
        {
            self.performSegueWithIdentifier("EditSleepSegue", sender: self)
        }
        else if event.type.isEqualToString("bottle")
        {
            self.performSegueWithIdentifier("EditBottleSegue", sender: self)
        }
        else if event.type.isEqualToString("pump")
        {
            self.performSegueWithIdentifier("EditPumpSegue", sender: self)
        }
        else if event.type.isEqualToString("poop")
        {
            self.performSegueWithIdentifier("EditPoopSegue", sender: self)
        }
        else if event.type.isEqualToString("pee")
        {
            self.performSegueWithIdentifier("EditPeeSegue", sender: self)
        }
        else if event.type.isEqualToString("breast")
        {
            self.performSegueWithIdentifier("EditBreastSegue", sender: self)
        }
        

    }
    
    @IBAction func btnDeletePressed(sender: AnyObject) {
        let alert = UIAlertController(title: "Confirm", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (ACTION :UIAlertAction!) in
            
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!)in
            DataSource.sharedDataSouce.deleteEventWithIndex(self.mSelectedIndex)
         //   self.activityIndicator.startAnimating()
            delay(1, closure: { () -> () in
                 self.navigationController?.popViewControllerAnimated(true)
            })
           
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - prepareForSegue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "EditNoteSegue"
        {
            let controller = segue.destinationViewController as! EditNoteTableViewController
            let event: LogEvent! = DataSource.sharedDataSouce.EventAtIndex(mSelectedIndex);
            controller.setSettingsData(event)
            controller.mSelectedIndex = mSelectedIndex
        }
        else if segue.identifier == "EditMedicineSegue"
        {
            let controller = segue.destinationViewController as! EditMedicineTableViewController
            let event: LogEvent! = DataSource.sharedDataSouce.EventAtIndex(mSelectedIndex);
            controller.logEvent = event
            controller.mSelectedIndex = mSelectedIndex
        }
        else if segue.identifier == "EditSleepSegue"
        {
            let controller = segue.destinationViewController as! EditSleepTableViewController
            let event: LogEvent! = DataSource.sharedDataSouce.EventAtIndex(mSelectedIndex);
            controller.logEvent = event
            controller.mSelectedIndex = mSelectedIndex
        }
        else if segue.identifier == "EditBottleSegue"
        {
            let controller = segue.destinationViewController as! EditBottleTableViewController
            let event: LogEvent! = DataSource.sharedDataSouce.EventAtIndex(mSelectedIndex);
            controller.logEvent = event
            controller.mSelectedIndex = mSelectedIndex
        }
        else if segue.identifier == "EditPumpSegue"
        {
            let controller = segue.destinationViewController as! EditPumpTableViewController
            let event: LogEvent! = DataSource.sharedDataSouce.EventAtIndex(mSelectedIndex);
            controller.logEvent = event
            controller.mSelectedIndex = mSelectedIndex
        }
        else if segue.identifier == "EditPoopSegue"
        {
            let controller = segue.destinationViewController as! EditPoopTableViewController
            let event: LogEvent! = DataSource.sharedDataSouce.EventAtIndex(mSelectedIndex);
            controller.setSettingsData(event)
            controller.mSelectedIndex = mSelectedIndex
        }
        else if segue.identifier == "EditPeeSegue"
        {
            let controller = segue.destinationViewController as! EditPeeTableViewController
            let event: LogEvent! = DataSource.sharedDataSouce.EventAtIndex(mSelectedIndex);
            controller.setSettingsData(event)
            controller.mSelectedIndex = mSelectedIndex
        }
        else if segue.identifier == "EditBreastSegue"
        {
            let controller = segue.destinationViewController as! EditBreastTableViewController
            let event: LogEvent! = DataSource.sharedDataSouce.EventAtIndex(mSelectedIndex);
            
            if event.action.isEqualToString("left") {
                controller.optAction = BothMoreSettingData.BreastActions.ActLeft
            }
            else if event.action.isEqualToString("right") {
                controller.optAction = BothMoreSettingData.BreastActions.ActRight
            }
            else {
                controller.optAction = BothMoreSettingData.BreastActions.ActBoth
            }
            
            controller.setSettingsData(event)
            controller.mSelectedIndex = mSelectedIndex
        }
    }
    // MARK: table view
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cellType:kLogDetailCellType! = kLogDetailCellType(rawValue: indexPath.row)
        if (cellType == .separatorTextAndPhoto){
            // separator for last cell
            if (cell.respondsToSelector("setSeparatorInset:")){
                cell.separatorInset = UIEdgeInsets(top: 0, left: 2000, bottom: 0, right: 0)
            }
            return
        }
        if (cellType != .Time || (cellType == .Time && heightforCellIndex(.Quantity) == 0 )){
            // Remove seperator inset
            if (cell.respondsToSelector("setSeparatorInset:")){
                cell.separatorInset = UIEdgeInsetsZero
            }
            // Prevent the cell from inheriting the Table View's margin settings
            if (cell.respondsToSelector("setPreservesSuperviewLayoutMargins:")){
                cell.preservesSuperviewLayoutMargins = false
            }
            
            // Explictly set your cell's layout margins
            
            if (cell.respondsToSelector("setPreservesSuperviewLayoutMargins:")){
                cell.layoutMargins = UIEdgeInsetsZero
            }
        }
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellType:kLogDetailCellType! = kLogDetailCellType(rawValue: indexPath.row)
        return heightforCellIndex(cellType)
    }
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
}
