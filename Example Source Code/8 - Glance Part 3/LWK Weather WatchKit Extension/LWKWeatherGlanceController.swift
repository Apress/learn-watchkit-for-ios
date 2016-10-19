//
//  LWKWeatherGlanceController.swift
//  LWKWeather
//
//  Created by Kim Topley on 6/11/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation
import SharedCode

class LWKWeatherGlanceController: WKInterfaceController, DisplayedCityInfoModelDelegate {
    @IBOutlet weak var cityLabel: WKInterfaceLabel!
    @IBOutlet weak var image: WKInterfaceImage!
    @IBOutlet weak var tempLabel: WKInterfaceLabel!
    @IBOutlet weak var conditionLabel: WKInterfaceLabel!
    @IBOutlet weak var footerLabel: WKInterfaceLabel!
    
    private var cityCode = 0 { // Will be set by selectCity()
        didSet {
            if (cityCode != oldValue) {
                // Fetch the weather, if we don't already have it.
                WatchAppWeatherModel.sharedInstance().fetchWeatherForCities([cityCode], always: false)
                
                // Handoff
                if cityCode != 0 {
                    updateUserActivity("com.apress.lwkweather.viewcityweather",
                        userInfo: ["cityCode": cityCode],
                        webpageURL: nil)
                }
            }
        }
    }
    
    // Whether we are using celsius for display.
    private var usingCelsius = false
    
    // Timer used to reload weather.
    private var reloadTimer: NSTimer?
    
    // Timer used for rotating through cities
    private var cityCycleTimer: NSTimer?
    
    // Index for the next city in rotation
    private var nextCityIndex = 0
    
    // Time between cities in rotation, in seconds
    private let rotatingCityInterval: NSTimeInterval = 1

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Load the weather model
        WatchAppWeatherModel.sharedInstance().loadWeatherModel()
        
        // Select the city based on current state
        selectCity()
    }

    override func willActivate() {
        super.willActivate()
        
        // Stir up the random number generator
        arc4random_stir()
        
        // Observe notification of weather model changes.
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "onNotification:", name: nil,
            object: WatchAppWeatherModel.sharedInstance())
        
        // Become the delegate of the DisplayedCityInfoModel
        DisplayedCityInfoModel.sharedInstance().delegate = self
        
        // Set whether we are using celsius.
        usingCelsius = DisplayedCityInfoModel.sharedInstance().useCelsius
        
        // Update the city in case the user used the app
        selectCity()
        
        // Update the view
        updateDetails()
    }

    override func didDeactivate() {
        super.didDeactivate()
        
        cityCycleTimer?.invalidate()
        cityCycleTimer = nil
        reloadTimer?.invalidate()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        DisplayedCityInfoModel.sharedInstance().delegate = nil
        
        invalidateUserActivity()
    }
    
    // DisplayedCityInfoModelDelegate conformance. Redisplay everything
    // if we switched temperature scale.
    func displayedCityInfoDidChange(model: DisplayedCityInfoModel) {
        if DisplayedCityInfoModel.sharedInstance().useCelsius != usingCelsius {
            usingCelsius = !usingCelsius
            updateDetails()
        }
    }
    
    // Method called when weather updates are received. Updates the
    // view if the current city weather has been updated.
    func onNotification(notification: NSNotification) {
        if let cityCodes = notification.userInfo?["cityCodes"] as? [Int] {
            if find(cityCodes, cityCode) != nil {
                updateDetails()
            }
        }
    }
    
    func reloadWeather(_: NSTimer) {
        WatchAppWeatherModel.sharedInstance().fetchWeatherForCities([cityCode], always: false)
        updateDetails()
    }
    
    private func selectCity() {
        var newCityCode: Int?
        
        cityCycleTimer?.invalidate()
        let userDefaults = NSUserDefaults(suiteName: "group.com.apress.lwkweathertest")
        if let preference = userDefaults?.integerForKey("GlancePreference") {
            switch (preference) {
            case 0:  // Last viewed city
                if let lastCityCode = userDefaults?.integerForKey("LastViewedCityCode") where lastCityCode != 0 {
                    newCityCode = lastCityCode
                }
                
            case 1:  // Random city
                let cityCount = DisplayedCityInfoModel.sharedInstance().displayedCities.count
                let index = Int(arc4random()) % cityCount
                newCityCode = DisplayedCityInfoModel.sharedInstance().displayedCities[index]
                
            case 2:  // Rotate through all cities
                displayNextCity()
                
            default:
                println("Unexpected glance preference value: \(preference)")
            }
        }
        
        cityCode = newCityCode ?? 5128581 // By default, show New York weather
    }
    
    private func displayNextCity() {
        let cityCount = DisplayedCityInfoModel.sharedInstance().displayedCities.count
        let index = min(nextCityIndex, cityCount - 1)
        nextCityIndex = (nextCityIndex + 1) % cityCount
        cityCode = DisplayedCityInfoModel.sharedInstance().displayedCities[index]
        updateDetails()
        
        // Schedule a timer for the next city, if we don't have one.
        if cityCycleTimer == nil {
            cityCycleTimer = NSTimer.scheduledTimerWithTimeInterval(rotatingCityInterval, target: self, selector: "onNextCityTimer:", userInfo: nil, repeats: true)
        }
    }
    
    func onNextCityTimer(_: NSTimer) {
        displayNextCity()
    }
    
    private func updateDetails() {
        var imageName: String? = nil
        var temperature = "- -"
        var condition = ""
        var state = "Loading..."
        var reloadTime: NSDate?
        
        let cityName = CityModel.sharedInstance().cityForCode(cityCode)?.name ?? "Unknown City"
        cityLabel.setText(cityName)
        
        if let cityWeather = WatchAppWeatherModel.sharedInstance().weatherByCity[cityCode],
            let weatherDetails = cityWeather.currentWeather
            where cityWeather.state == .LOADED {
                reloadTime = cityWeather.reloadTime
                if reloadTime!.compare(NSDate()) == .OrderedDescending {
                    // Data has not expired...use it
                    if let temp = weatherDetails.temperature {
                        temperature = WeatherUtilities.temperatureString(temp)
                    }
                    imageName = WeatherUtilities.selectWeatherImage(weatherDetails.weather,
                        day: weatherDetails.day ?? true, glance: true)
                    condition = weatherDetails.weatherDescription ?? ""
                    state = ""
                }
        }
        
        image.setImageNamed(nil) // Workaround for WatchKit bug
        image.setImageNamed(imageName)
        tempLabel.setText(temperature)
        conditionLabel.setText(condition)
        footerLabel.setText(state)
        
        reloadTimer?.invalidate()
        if let reloadTime = reloadTime {
            reloadTimer = NSTimer(fireDate: reloadTime, interval: 0, target: self, selector: "reloadWeather:", userInfo: nil, repeats: false)
            NSRunLoop.currentRunLoop().addTimer(reloadTimer!, forMode: NSDefaultRunLoopMode)
        }
    }
}
