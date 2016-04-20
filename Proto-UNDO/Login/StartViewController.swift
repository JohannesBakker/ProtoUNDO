//
//  StartViewController.swift
//  Proto-UNDO
//
//  Created by Tomasz on 10/16/15.
//  Copyright © 2015 Curly Brackets. All rights reserved.
//

import UIKit

class StartViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var swipeScrollView: UIScrollView!
    
    @IBOutlet weak var firstSwipeContentView: UIView!
    @IBOutlet weak var secondSwipeContentView: UIView!
    @IBOutlet weak var thirdSwipeContentView: UIView!
    
    @IBOutlet weak var secondSwipeViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var thirdSwipeViewLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        makeBoundRect(firstSwipeContentView)
        makeBoundRect(secondSwipeContentView)
        makeBoundRect(thirdSwipeContentView)
        
        swipeScrollView.pagingEnabled = true
        swipeScrollView.delegate = self
        swipeScrollView.showsHorizontalScrollIndicator = false
        swipeScrollView.backgroundColor = UIColor.blackColor()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let displayView = NSUserDefaults.standardUserDefaults().objectForKey("display_view") as! String!
        
        if displayView != nil
        {
            if displayView == "login"
            {
                self.performSegueWithIdentifier("LoginSegue", sender: nil)
            }
            else if displayView == "signup"
            {
                self.performSegueWithIdentifier("SignupSegue", sender: nil)
            }
        }
        
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "display_view")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        swipeScrollView.contentSize = CGSizeMake(swipeScrollView.bounds.size.width * 3, swipeScrollView.bounds.size.height)
        
        secondSwipeViewLeftConstraint.constant = swipeScrollView.bounds.size.width
        thirdSwipeViewLeftConstraint.constant = swipeScrollView.bounds.size.width * 2
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Other Methods

    func makeBoundRect(view : UIView!)
    {
        view.clipsToBounds = true
        view.layer.cornerRadius = 11
    }
    
    @IBAction func onPageChanged(sender: AnyObject) {
        swipeScrollView.setContentOffset(CGPointMake(swipeScrollView.bounds.size.width * CGFloat(pageControl.currentPage), 0), animated: false)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageNumber = Int(swipeScrollView.contentOffset.x / swipeScrollView.bounds.size.width)
        pageControl.currentPage = pageNumber
    }
}
