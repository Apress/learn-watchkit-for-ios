//
//  AppDelegate.swift
//  LWKWeather
//
//  Created by Kim Topley on 1/7/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import UIKit
import SharedCode

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Load cached weather.
        NSKeyedUnarchiver.setClass(CityWeather.self, forClassName: "LWKWeather.CityWeather")
        NSKeyedUnarchiver.setClass(DayForecast.self, forClassName: "LWKWeather.DayForecast")
        NSKeyedUnarchiver.setClass(WeatherDetails.self, forClassName: "LWKWeather.WeatherDetails")
        
        AppWeatherModel.sharedInstance().loadWeatherModel()

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

    
    // MARK: handler for completion of background downloads.
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        let modelInstance = AppWeatherModel.sharedInstance() as! AppWeatherModel // Creates the session!
        modelInstance.completionHandler = completionHandler
    }
    
    // MARK: -
    // MARK: Handler for requests from the WatchKit extension
    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {
        var taskId: UIBackgroundTaskIdentifier = 0
        taskId = application.beginBackgroundTaskWithExpirationHandler({
            // Out of time -- just send a nil reply.
            reply(nil)
            application.endBackgroundTask(taskId)
        })
        
        dispatch_async(dispatch_get_main_queue(), {
            let results = WatchAppWeatherRequestHandler.sharedInstance().handleWatchExtensionRequest(userInfo!)
            reply(results)
            
            let endTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC))
            dispatch_after(endTime, dispatch_get_main_queue(), {
                application.endBackgroundTask(taskId);
            })
        });
    }
}


