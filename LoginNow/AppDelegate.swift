//
//  AppDelegate.swift
//  LoginNow
//
//  Created by Martin Brunner on 29.01.15.
//  Copyright (c) 2015 Martin Brunner. All rights reserved.
//

import UIKit


protocol DoLogonDelegate {
    func doLogon(#isTimer: Bool) -> Bool
}
var delegate: DoLogonDelegate?


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if let timerInterval:NSString = NSUserDefaults.standardUserDefaults().stringForKey(kTimer)  {
            println("Starting Timer with: \(timerInterval)")
            application.setMinimumBackgroundFetchInterval(timerInterval.doubleValue)
        }
        return true
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler:
        ((UIBackgroundFetchResult) -> Void)) {
            
            if let success = delegate?.doLogon(isTimer: true) {
                if success  {
                    println("Delegate called: True")
                    completionHandler(UIBackgroundFetchResult.NewData)
                } else {
                    println("Delegate called: false")
                    completionHandler(UIBackgroundFetchResult.NoData)
                }
            }
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        println("Did enter background")
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

