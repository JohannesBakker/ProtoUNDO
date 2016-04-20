//
//  ViewController.swift
//  ProtoUNDOTest
//
//  Created by Yury on 18/09/15.
//  Copyright © 2015 Yury. All rights reserved.
//

import UIKit

@objc(ViewController) class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var sections = NewDatasource.activeSections
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableFooter: UIView!
    var undoView:UndoView = UndoView()
    
    // MARK:
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        tabBarItem.title = "Home"
        tabBarItem.image = UIImage(named: "home")
        edgesForExtendedLayout = .Bottom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "SliderTableViewCell", bundle: nil), forCellReuseIdentifier: "CellSlider")
        tableView.registerNib(UINib(nibName: "ActionsTableViewCell", bundle: nil), forCellReuseIdentifier: "CellActions")
        tableView.registerNib(UINib(nibName: "MemoTableViewCell", bundle: nil), forCellReuseIdentifier: "CellMemo")
        
        tableFooter.frame = CGRectMake(0, 0, self.view.bounds.width, 80)
        tableView.tableFooterView = tableFooter

        undoView.hidden = true
        view.addSubview(undoView)
        
    }

    override func viewDidLayoutSubviews() {
        
        let selfSize = view.bounds.size
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        
        undoView.frame = CGRectMake(0, selfSize.height - tabBarHeight - 75, selfSize.width, 75)

        
    }

    override func viewWillAppear(animated: Bool) {
        navigationController!.navigationBarHidden = true
    }
    
    func reloadData() {
        sections = NewDatasource.activeSections
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count + 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < sections.count {
            return sections[section].items.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < sections.count {
            return sections[section].name
        }
        return " "
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == sections.count {
            return 30
        } else {
            return sections[indexPath.section].type == "note" ? 45 : 95
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = sections[indexPath.section].items[indexPath.row]
        
        if let slider = item as? SliderEventItem {
            let cell = tableView.dequeueReusableCellWithIdentifier("CellSlider") as! SliderTableViewCell
            cell.item = slider
            return cell
        } else if item.type == "note" {
            let cell = tableView.dequeueReusableCellWithIdentifier("CellMemo") as! MemoTableViewCell
            cell.item = item
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("CellActions") as! ActionsTableViewCell
            cell.item = item
            return cell
        }
    }
    
    // MARK: - Actions
    func onAccessoryButtonTapped(item: EventItem) {
        let segueName: String
        if item is SliderEventItem {
            segueName = "showValued"
        } else if item.type == "medicine" {
            segueName = "showMedicine"
        } else if item.type == "note" {
            segueName = "showNote"
        } else if item.type == "poop" {
            segueName = "showPoop"
        } else if item.type == "pee" {
            segueName = "showPee"
        } else if item.type == "breast" {
            segueName = "showBreast"
        } else if item.type == "sleep" {
            segueName = ""
            print("Incorrect item type!!!")
            return
        }
        else {
            segueName = ""
            print("Incorrect item type!!!")
        }
        showDetailsForItem(item, segueName: segueName)
    }
    
    func showDetailsForItem(item: EventItem, segueName: String) {
        if segueName == "showMedicine" {
            let storyboard : UIStoryboard = UIStoryboard(name: "MoreViewController", bundle: nil)
            let vc = storyboard.instantiateInitialViewController() as! MoreViewController
            vc.item = item
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        else if segueName == "showNote" {
            
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier(segueName) as! NoteMoreTableViewController
            
            vc.logEvent = LogEvent(customItem: item)
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        else if segueName == "showPoop" {
            
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier(segueName) as! PoopMoreTableViewController
            
            vc.logEvent = LogEvent(customItem: item)
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        else if segueName == "showPee" {
            
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier(segueName) as! PeeMoreTableViewController
            
            vc.logEvent = LogEvent(customItem: item)
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        else if segueName == "showBreast" {
            
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier(segueName) as! BothMoreTableViewController
            
            
            if item.actions[0].name == "Left" {
                vc.optAction = BothMoreSettingData.BreastActions.ActLeft
            }
            else if item.actions[0].name == "Right" {
                vc.optAction = BothMoreSettingData.BreastActions.ActRight
            }
            else {
                vc.optAction = BothMoreSettingData.BreastActions.ActBoth
            }
            
            vc.logEvent = LogEvent(customItem: item)
            
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        
        
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(segueName) as! EventDetailViewController
        vc.event = LogEvent(customItem: item)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func customizeTapped() {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("showCustomize")
        vc.modalTransitionStyle = .CrossDissolve
        presentViewController(vc, animated: true, completion: nil)
    }
    
    var memoInput:MemoInputViewController? = nil
    func showInput(cell: MemoTableViewCell, isPhotoTapped: Bool) {
        memoInput?.view.removeFromSuperview()
        memoInput  = MemoInputViewController(nibName: "MemoInputViewController", bundle: nil);
        memoInput!.loadView()
        memoInput!.viewDidLoad()
        var frame:CGRect = cell.frame
        frame.size.height = memoInput!.view.frame.size.height
        frame =  CGRectOffset(frame, -tableView.contentOffset.x, -tableView.contentOffset.y);
        frame =  CGRectOffset(frame, tableView.frame.origin.x, tableView.frame.origin.y + 13);
        memoInput!.view.frame = frame
        //let window:UIWindow = UIApplication.sharedApplication().windows.first!
        let rootVC = UIApplication.sharedApplication().keyWindow!.rootViewController!
        // backgound view
        let bgView = UIView(frame: rootVC.view.frame);
        bgView.backgroundColor = UIColor(white: 0.0, alpha: 0.5);
        let gr = UITapGestureRecognizer(target: memoInput!, action: "cancelAction:")
        bgView.addGestureRecognizer(gr)
        rootVC.view.addSubview(bgView)
        rootVC.view.addSubview(memoInput!.view)

        if isPhotoTapped {
            memoInput!.photoAction(cell)
        } else {
            memoInput!.textField.becomeFirstResponder()
        }
        memoInput!.backgroundView = bgView
        
        bgView.alpha = 0;
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            bgView.alpha = 0.5
        })
    }
}
