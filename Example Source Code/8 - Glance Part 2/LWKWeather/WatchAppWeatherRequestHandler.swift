//
//  WatchAppWeatherRequestHandler.swift
//  LWKWeather
//
//  Created by Kim Topley on 6/4/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import Foundation
import SharedCode

public class WatchAppWeatherRequestHandler {
    // Holder for the shared instance of this class.
    private static var token: dispatch_once_t = 0
    private static var instance: WatchAppWeatherRequestHandler?
    
    
    // Gets the shared instance of this class.
    public class func sharedInstance() -> WatchAppWeatherRequestHandler {
        dispatch_once(&token) {
            self.instance = WatchAppWeatherRequestHandler()
        }
        return instance!
    }
    
    // Private initializer to ensure a single instance
    private init() {
        // Register for notifications of weather changes/load errors.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onNotification:",
            name: nil, object: AppWeatherModel.sharedInstance())
    }
    
    // Handles a request from the Watch extension. The command name is extracted from the
    // request dictionary, the request is handled and the reply is stored in a new
    // dictionary, which is returned to the caller. This method must be called in
    // the main thread.
    public func handleWatchExtensionRequest(request: [NSObject : AnyObject]) -> [NSObject : AnyObject] {
        assert(NSThread.isMainThread())
        
        // Create the reply dictionary.
        var reply = [NSObject : AnyObject]()
        
        // Get the city codes for which we need to get weather data.
        if let cityCodes = request[WatchAppWeatherInterface.LoadWeatherCommandName] as? [Int] {
            let timeNow = NSDate()
            var citiesToLoad = [Int]()
            
            // For each requested city, get the current weather state. If
            // there is none or if the weather is old, request a reload.
            for cityCode in cityCodes {
                let currentWeather = AppWeatherModel.sharedInstance().weatherByCity[cityCode]
                if currentWeather == nil || currentWeather!.shouldReload {
                    // No weather or the weather is out of date
                    citiesToLoad.append(cityCode)
                }
            }
            
            // Initiate load for any cities for which we do not have
            // current data. Later, we will get notification of success or
            // failure from the notification center and we will send a message
            // to the WatchKit extension as a Darwin notification
            if !citiesToLoad.isEmpty {
                AppWeatherModel.sharedInstance().fetchWeatherForCities(citiesToLoad, always: false)
            }
            
            // Now get the current state for each requested city.
            var cityWeatherList = [CityWeather]()
            for cityCode in cityCodes {
                if let currentWeather = AppWeatherModel.sharedInstance().weatherByCity[cityCode] {
                    cityWeatherList.append(currentWeather)
                }
            }
            
            // Encode the reply data as NSData and add it to the reply map.
            let data = NSKeyedArchiver.archivedDataWithRootObject(cityWeatherList)
            reply[WatchAppWeatherInterface.LoadWeatherReplyName] = data
        }
        
        return reply
    }
   
    // Handler for notifications from the iOS app weather model.
    @objc public func onNotification(notification: NSNotification) {
        if notification.name == WeatherModel.NotificationNames.weatherModelChanged
            || notification.name == WeatherModel.NotificationNames.weatherModelLoadFailed {
                // Notification that weather data has been loaded or load failed.
                // Send to WatchKit extension via Darwin notification center, if the
                // expected payload is present.
                if let userInfo = notification.userInfo,
                    let cityCodes = userInfo["cityCodes"] as? [Int] {
                        for cityCode in cityCodes {
                            // Send a Darwin center notification using the city code
                            // as the name.
                            DarwinNotificationCenterBridge.postNotificationForName("\(cityCode)")
                        }
                }
        }
    }
}