//
//  MoreViewController.swift
//  Proto-UNDO
//
//  Created by Yury on 27/09/15.
//  Copyright © 2015 Curly Brackets. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let cells = [["DateCell", "QuantityCell"], ["ParentCell"], ["StarCell"], ["NoteCell"],[]]
    
    var item: EventItem! {
        didSet {
            event = LogEvent(customItem: item, _action: 0)
            title = "\(item.actions[0].name.capitalizedString) More"
        }
    }
    var event: LogEvent!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var tableViewBottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.tableFooterView = UIView()
        
        navigationController?.navigationBarHidden = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: Selector("onSave"))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("onCancel"))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.redColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc func onSave() {
        EventsManager.sharedManager.addEvent(event)
        navigationController?.popViewControllerAnimated(true)
    }
    
    @objc func onCancel() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func parentTapped(sender: UIButton) {
        sender.selected = !sender.selected
    }
        
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return cells.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cells[indexPath.section][indexPath.row], forIndexPath: indexPath)
        if let moreTableViewCell = cell as? MoreTableViewCell {
            moreTableViewCell.tableView = tableView
            moreTableViewCell.event = event
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 35 }
        else if section == 1 || section == 2 || section == 3 { return 20 }
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MoreTableViewCell {
            cell.selectCell(true)
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(red:0.936, green:0.936, blue:0.96, alpha:1.0)
        let height = view.bounds.size.height
        let width = view.bounds.size.width
        if section > 0 {
            let topBorder = UIView(frame: CGRectMake(0, 0, width, 1))
            topBorder.backgroundColor = UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.0)
            view.addSubview(topBorder)
        }
        let bottomBorder = UIView(frame: CGRectMake(0, height-1, width, 1))
        bottomBorder.backgroundColor = UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.0)
        view.addSubview(bottomBorder)
    }
    
    // MARK: - Keyboard
    func keyboardWillShow(notification: NSNotification) {
        guard let kbSizeValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        guard let kbDurationNumber = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        
        let lastSection = self.tableView.numberOfSections - 2
        let indexPath = NSIndexPath(forRow: self.tableView.numberOfRowsInSection(lastSection) - 1, inSection: lastSection)
        
        UIView.animateWithDuration(kbDurationNumber.doubleValue){ () -> Void in
            self.tableViewBottom.constant = -kbSizeValue.CGRectValue().height
            self.view.layoutIfNeeded()
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: false)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        guard let kbDurationNumber = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        UIView.animateWithDuration(kbDurationNumber.doubleValue){ () -> Void in
            self.tableViewBottom.constant = 0
            self.view.layoutIfNeeded()
        }
    }
}
