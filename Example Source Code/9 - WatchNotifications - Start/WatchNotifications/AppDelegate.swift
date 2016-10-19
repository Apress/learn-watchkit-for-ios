//
//  AppDelegate.swift
//  WatchNotifications
//
//  Created by Kim Topley on 6/15/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let action1 = UIMutableUserNotificationAction()
        action1.identifier = "ACTION1"
        action1.title = "Action 1"
        action1.destructive = false
        action1.authenticationRequired = false
        action1.activationMode = .Background
        
        let action2 = UIMutableUserNotificationAction()
        action2.identifier = "ACTION2"
        action2.title = "Action 2"
        action2.destructive = true
        action2.authenticationRequired = false
        action2.activationMode = .Background
        
        let action3 = UIMutableUserNotificationAction()
        action3.identifier = "ACTION3"
        action3.title = "Action 3"
        action3.destructive = false
        action3.authenticationRequired = false
        action3.activationMode = .Foreground
        
        let actionCategory = UIMutableUserNotificationCategory()
        actionCategory.identifier = "BasicActions"
        actionCategory.setActions([action1, action2, action3], forContext: UIUserNotificationActionContext.Default)
        actionCategory.setActions([action1, action2], forContext: UIUserNotificationActionContext.Minimal)
        
        let settings = UIUserNotificationSettings(forTypes: .Badge | .Alert | .Sound, categories: Set([actionCategory]))
        application.registerUserNotificationSettings(settings)
        
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        println("Received local notification: \(notification)")
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        println("Handling action id \(identifier)")
        completionHandler()
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

