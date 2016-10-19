//
//  WatchAppWeatherModel.swift
//  LWKWeather
//
//  Created by Kim Topley on 6/3/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import UIKit
import WatchKit
import SharedCode

// MARK: -
// MARK: WATCH APP WEATHER MODEL

// The Watch App implementation of the weather model.
class WatchAppWeatherModel : WeatherModel {
    // Holder for the shared instance of this model.
    private static var token: dispatch_once_t = 0
    private static var instance: WatchAppWeatherModel?
    
    // Determines whether this model can update the persistent storage.
    // Overrides the default to not allow updates.
    override var readOnly: Bool {
        return false
    }
    
    // Gets the shared instance of this model.
    class func sharedInstance() -> WeatherModel {
        dispatch_once(&token) {
            self.instance = WatchAppWeatherModel()
        }
        return instance!
    }
    
    // Creates the loader for the weather data. Returns a loader that fetches
    // weather data from the iOS application
    override func createWeatherModelLoader() -> WeatherModelLoader {
        return WatchAppWeatherModelLoader(model: self)
    }
}

// MARK: -
// MARK: WATCH APP WEATHER MODEL LOADER
private class WatchAppWeatherModelLoader: WeatherModelLoader, DarwinNotificationObserver {
    // The model for which this class will load data.
    private let model: WeatherModel
    private var registeredCityCodes = Set<Int>()
    
    init(model: WeatherModel) {
        self.model = model
    }
    
    // Requests that the loader obtain weather details for a given set of cities.
    // This method is always called on the main thread.
    func fetchWeatherForCities(cityCodes: [Int]) {
        let userInfo: [NSObject: AnyObject] = [WatchAppWeatherInterface.LoadWeatherCommandName : cityCodes]
        for cityCode in cityCodes {
            if !registeredCityCodes.contains(cityCode) {
                registeredCityCodes.insert(cityCode)
                DarwinNotificationCenterBridge.addObserver(self, forName: "\(cityCode)")
            }
        }
        let result = WKInterfaceController.openParentApplication(userInfo, reply: { (results, error) in
            if let replyData = results?[WatchAppWeatherInterface.LoadWeatherReplyName] as? NSData {
                if let cityWeatherItems = NSKeyedUnarchiver.unarchiveObjectWithData(replyData) as? [CityWeather] {
                    for cityWeather in cityWeatherItems {
                        let cityCode = cityWeather.cityCode
                        self.model.installNewWeatherForCity(cityCode, detailsByDay: cityWeather.detailsByDay)
                    }
                }
            }
        })
    }
    
    // Handles notification of data received for a city. The
    // name is the city code as a string
    @objc func onNotificationReceived(name: String) {
        if let cityCode = name.toInt(),
            let cityWeather = model.getArchivedWeatherForCity(cityCode) {
                model.installNewWeatherForCity(cityCode, detailsByDay: cityWeather.detailsByDay)
        }
    }
}

