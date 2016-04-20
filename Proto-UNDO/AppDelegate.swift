//
//  AppDelegate.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 25.07.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import UIKit
import Parse
import SystemConfiguration
import AudioToolbox

let viewController = ViewController()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Parse.setApplicationId("VofcHkpj1hhdTM8r5sLnVIdjHN2iRYw5W4jsYjV4", clientKey: "fjKucKpPEQJv1Zf5pioIt4bvf5mhpaTpce7xRz6r")
//        DataSource.sharedDataSouce
//        EventsManager.sharedManager
//        
//        let navVC = UINavigationController(rootViewController: viewController)
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let logVC = storyboard.instantiateViewControllerWithIdentifier("LogsNavController")
//        let inviteVC = storyboard.instantiateViewControllerWithIdentifier("InviteViewController")
//        
//        let tabVC = UITabBarController()
//        tabVC.viewControllers = [navVC, logVC, inviteVC]
//        
//        window = UIWindow(frame: UIScreen.mainScreen().bounds)
//        window?.rootViewController = tabVC
//        window?.makeKeyAndVisible()
        
        let userDefaults = NSUserDefaults .standardUserDefaults()
        userDefaults.setObject("", forKey: "user_email")
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

