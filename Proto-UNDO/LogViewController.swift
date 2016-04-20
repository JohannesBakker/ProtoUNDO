//
//  LogViewController.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 25.07.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import UIKit

class LogViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var topDividerHeightConstraint: NSLayoutConstraint!
    
    var mSelectedIndex: NSInteger!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "LogTableViewCell", bundle: nil), forCellReuseIdentifier: "logCell")
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"dataChanged", name: kLogObjectAddedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"eventRemoved:", name: kLogObjectRemovedNotification, object: nil)
        updateEventsCount()
        //let attributes = [NSFontAttributeName : UIFont(descriptor: UIFontDescriptor(fontAttributes:  [UIFontDescriptorFaceAttribute: "Bold"]), size: 16)]
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.boldSystemFontOfSize(16)]
            //attributes
        self.navigationController!.navigationBar.barTintColor = UIColorFromRGB(0xF7F7F7)
        self.navigationController!.navigationBar.translucent = false

        NSLog("%@", self.navigationController!)
    }
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func viewWillAppear(animated: Bool) {
        DataSource.sharedDataSouce.reloadData()
    }
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.tabBarItem.setCustomBadgeValue(nil)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topDividerHeightConstraint.constant = 0.5
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLogDetailViewController"
        {
            let controller = segue.destinationViewController as! LogDetailViewController
            controller.mSelectedIndex = self.mSelectedIndex
            NSLog("showLogDetailViewController");
           
        }
    }
    
    @objc func dataChanged(){
        tableView.reloadData()
    }
    @objc func eventRemoved(notification:NSNotification){
        let userInfo:Dictionary<String,Int!> = notification.userInfo as! Dictionary<String,Int!>
        let index:Int = userInfo["index"]!
        if index>=0 {
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
        }
        tableView.userInteractionEnabled=true;
        activityIndicator.stopAnimating()
    }
    @IBAction func sortAction(sender: UIBarButtonItem) {
        if DataSource.sharedDataSouce.sortOrder == .TimeDescending {
            DataSource.sharedDataSouce.sortOrder = .TimeAscending
            sender.image = UIImage(named: "sort!")
        }
        else{
            DataSource.sharedDataSouce.sortOrder = .TimeDescending
            sender.image = UIImage(named: "sort")
        }
        DataSource.sharedDataSouce.reloadData()
    }
    
    func updateEventsCount(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let count = DataSource.sharedDataSouce.count()
//            self.eventsLabel.text = "\(count) events"
            self.navigationItem.title = "(\(count)) Logs"
            if count==0 {
                self.overlayView.hidden=false
            }
            else{
                self.overlayView.hidden=true
            }
        })
    }

    //MARK: UITableView DataSource and Delegate Methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cellID:String = "logCell"
        let cell: LogTableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellID) as! LogTableViewCell
        
        return cell
    }
    // staup cell only if displaying
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell2setup  = cell as! LogTableViewCell
        let event:LogEvent? = DataSource.sharedDataSouce.EventAtIndex(indexPath.row)
        if (event != nil){
            cell2setup.setupCell(event!)
            cell2setup.detailButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
            cell2setup.detailButton.addTarget(self, action: "detailAction:", forControlEvents: .TouchUpInside)
            cell2setup.detailButton.tag = indexPath.row
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 96
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        updateEventsCount()
        let count = DataSource.sharedDataSouce.count()
        return count
    }
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false;
    }
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Delete"
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete
        {
            DataSource.sharedDataSouce.deleteEventWithIndex(indexPath.row)
            tableView.userInteractionEnabled=false;
            activityIndicator.startAnimating()
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 57
    }
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if DataSource.sharedDataSouce.canLoadMore(){
            // return more view
            let footer:UIView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 57))
            footer.backgroundColor = UIColor.clearColor()
            
            let btnLoadMore = UIButton(frame: CGRectMake(28, 0, tableView.frame.width - 56, 57))
            btnLoadMore.backgroundColor = UIColor(red: 133.0/255, green: 142.0/255, blue: 153.0/255, alpha: 1.0)
            btnLoadMore.setTitle("Show More", forState: UIControlState.Normal)
            btnLoadMore.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            btnLoadMore.titleLabel?.font = UIFont.systemFontOfSize(20)
            btnLoadMore.userInteractionEnabled = false
            
            btnLoadMore.clipsToBounds = true
            btnLoadMore.layer.cornerRadius = 13
            
            footer.addSubview(btnLoadMore)
            
//            footer.backgroundColor = UIColor(white: 0.9, alpha: 0.2)
//            let title:UILabel = UILabel(frame: footer.frame)
//            title.text = "Show More ..."
//            title.font = UIFont.systemFontOfSize(18)
//            title.textColor = UIColor.blueColor()
//            title.textAlignment = NSTextAlignment.Center
//            footer.addSubview(title)
            let gr:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "loadMore:")
            footer.addGestureRecognizer(gr)
            footer.userInteractionEnabled = true
//            title.userInteractionEnabled=false
            return footer
        }
        return UIView(frame: CGRectZero)
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRectZero)
    }
    @objc func detailAction(sender:UIButton){
        showDetailForIndex(sender.tag)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView .deselectRowAtIndexPath(indexPath, animated: false);
        showDetailForIndex(indexPath.row);
    }
    func showDetailForIndex(index:Int){
        mSelectedIndex = index
         self.navigationItem.title = "Logs"
        self.performSegueWithIdentifier("showLogDetailViewController", sender: self)
    }
    
    @objc func loadMore(sender:UIGestureRecognizer){
        let ai = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        ai.color = UIColor.blackColor()
        sender.view?.addSubview(ai)
        let contentView = sender.view!
        ai.center = CGPointMake(contentView.frame.size.width*0.5, contentView.frame.size.height*0.5)
        ai.startAnimating()
        ai.tag=100
        DataSource.sharedDataSouce.loadData(DataSource.sharedDataSouce.loadPageSize)
    }
    @IBAction func unwindToVC(segue: UIStoryboardSegue) {
    }

}

