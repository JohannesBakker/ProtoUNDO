//
//  PeeMoreTableViewController.swift
//  PeeMore
//
//  Created by Lee Xiaoxiao on 9/26/15.
//  Copyright © 2015 Lee Xiaoxiao. All rights reserved.
//

import UIKit


enum kPeeContentCell : Int {
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
    case SeperateEnd        // 17
}


class PeeDetailItem {
    var itemIndex: Int
    var name: String
    var hasDesc: Bool
    var analogy: String
    
    init(itemIndex: Int, name: String, hasDesc: Bool, analogy: String) {
        self.itemIndex = itemIndex
        self.name = name
        self.hasDesc = hasDesc
        self.analogy = analogy
    }
}


class PeeMoreTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var settingData:PeeMoreSettingData = PeeMoreSettingData()
    var bIsVisibleTimePicker:Bool = false
    var bIsDisplayDescriptions:Bool = false
    
    //===============================================
    
    @IBOutlet weak var lblTimeResult: UILabel!
    
    @IBOutlet weak var lblTimeNotSet: UILabel!
    
    @IBOutlet weak var lblTimeEdit: UILabel!
    
    @IBOutlet weak var btnClearTime: UIButton!
    
    //============================================
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // ==========================================
    
    func datePickerValueChanged(sender: UIDatePicker)
    {
        if !lblTimeNotSet.hidden {
            lblTimeNotSet.hidden = true
            lblTimeEdit.hidden = false
            btnClearTime.hidden = false
        }
        lblTimeEdit.text = getDateFormat(datePicker.date)
        
        settingData.timePee = datePicker.date
        
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
    
    var initTime:NSDate?
    
    @IBAction func OnTappedClearTime(sender: UIButton) {
        settingData.timePee = initTime
        refreshDatePicker(false)
        
        // Marko
        checkItemChanged()
    }

    func refreshDatePicker(isExpand:Bool){
        let t = settingData.timePee
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

    
   //=============================================
    
    @IBOutlet weak var btnStar: UIButton!
    
    @IBOutlet weak var btnExclamation: UIButton!
    
    @IBOutlet weak var imgStar: UIImageView!
    
    @IBOutlet weak var imgExclamation: UIImageView!
    
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
    
    //===============================================
    
    
    @IBOutlet weak var swNotJustNow: UISwitch!
    
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
    
    
    @IBOutlet weak var swOptionsJust: MyCheckBox!

    @IBOutlet weak var swOptionsOrange: MyCheckBox!
   
    @IBOutlet weak var swOptionsLighterOrange: MyCheckBox!
    
    @IBOutlet weak var swOptionsBrightYelloToOrange: MyCheckBox!
    
    @IBOutlet weak var swOptionsBrightLemony: MyCheckBox!
    
    @IBOutlet weak var swOptionsPaleYello: MyCheckBox!
    
    func RefreshPeeOptions() {
        swOptionsJust.isChecked = settingData.optPee == PeeMoreSettingData.PeeOptions.Just
        swOptionsOrange.isChecked = settingData.optPee == PeeMoreSettingData.PeeOptions.Orange
        swOptionsLighterOrange.isChecked = settingData.optPee == PeeMoreSettingData.PeeOptions.LighterOrange
        swOptionsBrightYelloToOrange.isChecked = settingData.optPee == PeeMoreSettingData.PeeOptions.BrightYellowToOrange
        swOptionsBrightLemony.isChecked = settingData.optPee == PeeMoreSettingData.PeeOptions.BrightLemony
        swOptionsPaleYello.isChecked = settingData.optPee == PeeMoreSettingData.PeeOptions.PaleYello
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RefreshPeeOptions()
        
        datePicker.addTarget(self, action: "datePickerValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        initTime = settingData.timePee
        
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let cellHeight:kPeeContentCell = kPeeContentCell(rawValue: indexPath.row)!
        
        switch(cellHeight)
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
            
        case .SeperateEnd:
            return 70
            
        default:
            return 20
        }
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath.row == 2 {            
            if bIsVisibleTimePicker {
                settingData.timePee = datePicker.date
            }
            refreshDatePicker(!bIsVisibleTimePicker)
        }
        
        if indexPath.row == 7 {
            selectPee(PeeMoreSettingData.PeeOptions.Just)
        }

        if indexPath.row == 8 {
            selectPee(PeeMoreSettingData.PeeOptions.Orange)
        }
        
        if indexPath.row == 9 {
            selectPee(PeeMoreSettingData.PeeOptions.LighterOrange)
        }
        
        if indexPath.row == 10 {
            selectPee(PeeMoreSettingData.PeeOptions.BrightYellowToOrange)
        }
        
        if indexPath.row == 11 {
            selectPee(PeeMoreSettingData.PeeOptions.BrightLemony)
        }
        
        if indexPath.row == 12 {
            selectPee(PeeMoreSettingData.PeeOptions.PaleYello)
        }
        
        // Marko
        checkItemChanged()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
      
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
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
        
    }


    // MARK: - Table view data source
/*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
*/

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    //===============================================
    // Marko
    //===============================================
    
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var memoTextInput: UITextField!
    @IBOutlet weak var memoImageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    
    //===============================================
    
    let NVItemSaveColor:UIColor = UIColor(red:255.0/255.0, green:59.0/255.0, blue:48.0/255.0, alpha:1.0) // #FF3B30
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
    
    var bItemChanged:Bool = false
    var init_settingData:PeeMoreSettingData = PeeMoreSettingData()
    
    
    // Activity Indicator
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    //===============================================
    
    
    
    
    
    //===============================================
    
    
    // MARK: - View life cycle
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden=false
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
    
    func dismiss() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    func checkItemChanged() {
        
        // check all any item changed
        bItemChanged = false
        
        repeat {
            let formatter : NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateInit = formatter.stringFromDate(init_settingData.timePee!)
            let dateSetting = formatter.stringFromDate(settingData.timePee!)
            
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
            
            if init_settingData.optPee != settingData.optPee {
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
    
    var logEvent = LogEvent() {
        didSet {
            
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
            
            
            // save initialize setting data
            init_settingData.bIsNotJustNow = settingData.bIsNotJustNow
            init_settingData.timePee = NSDate.init(timeInterval: 0, sinceDate: settingData.timePee!)
            
            init_settingData.bDisplayDescription = settingData.bDisplayDescription
            init_settingData.bIsSelectedStar = settingData.bIsSelectedStar
            init_settingData.bIsSelectedExclamation = settingData.bIsSelectedExclamation
            init_settingData.optPee = settingData.optPee
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
 
    func getPeeDetailIem(index: Int) ->PeeDetailItem? {
        let itemArray:[PeeDetailItem] = [justPee, orangeColorPee, LighterOrangePee, brightYellowToPee, brightLemonyPee, paleYellowPee]
        
        if index >= 0 && index < itemArray.count {
            return itemArray[index]
        }
        
        return nil
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