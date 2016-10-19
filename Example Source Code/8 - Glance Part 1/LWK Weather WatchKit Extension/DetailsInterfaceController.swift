//
//  DetailsInterfaceController.swift
//  LWKWeather
//
//  Created by Kim Topley on 6/6/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation
import SharedCode

class DetailsInterfaceController: WKInterfaceController {
    @IBOutlet weak var cityNameLabel: WKInterfaceLabel!
    @IBOutlet weak var image: WKInterfaceImage!
    @IBOutlet weak var tempLabel: WKInterfaceLabel!
    @IBOutlet weak var summaryLabel: WKInterfaceLabel!
    @IBOutlet weak var table: WKInterfaceTable!
    
    // Maximum number of days of weather to display
    private static let maxDays = 2
    private var cityCode: Int!
    private var reloadTimer: NSTimer?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        setTitle("Weather")
        
        cityCode = context as! Int
        let cityName = CityModel.sharedInstance().cityForCode(cityCode)?.name ?? "Unknown City"
        cityNameLabel.setText(cityName)
        
        let userDefaults = NSUserDefaults(suiteName: "group.com.apress.lwkweathertest")
        userDefaults?.setInteger(cityCode, forKey: "LastViewedCityCode")
        userDefaults?.synchronize()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // Update the view and arrange to reload weather
        // when it expires.
        updateDetails()
        
        // Observe notification of weather model changes.
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "onNotification:", name: nil,
            object: WatchAppWeatherModel.sharedInstance())
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        reloadTimer?.invalidate()
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
    
    // Updates the view from the current model state
    private func updateDetails() {
        var updateTable = false
        if let cityWeather = WatchAppWeatherModel.sharedInstance().weatherByCity[cityCode] {
            var temperature = " "
            var imageName: String?
            var condition = " "
            
            switch cityWeather.state {
            case .INIT:
                // Nothing to do
                break
            case .LOADING:
                condition = "Loading Weather"
                
            case .ERROR:
                condition = "Failed to Load Weather"
                
            case .LOADED:
                if let weatherDetails = cityWeather.currentWeather {
                    let reloadTime = cityWeather.reloadTime
                    if reloadTime.compare(NSDate()) == .OrderedDescending {
                        // All data is available
                        updateTable = true
                        if let temp = weatherDetails.temperature {
                            temperature = WeatherUtilities.temperatureString(temp)
                        }
                        
                        if let cond = weatherDetails.weatherDescription {
                            condition = cond
                        }
                        imageName = WeatherUtilities.selectWeatherImage(weatherDetails.weather, day: weatherDetails.day ?? true)
                    }
                }
            }
            tempLabel.setText(temperature)
            image.setImageNamed(imageName)
            summaryLabel.setText(condition)
            
            // Start a timer to reload the weather data when it expires.
            reloadTimer?.invalidate()
            reloadTimer = NSTimer(fireDate: cityWeather.reloadTime, interval: 0, target: self, selector: "reloadWeather:", userInfo: nil, repeats: false)
            NSRunLoop.currentRunLoop().addTimer(reloadTimer!, forMode: NSDefaultRunLoopMode)
        } else {
            image.setImage(nil)
            tempLabel.setText(" ")
            summaryLabel.setText("No weather available")
        }
        
        if updateTable {
            // Update the table content from the current weather.
            updateTableContent()
        } else {
            // Clear the table.
            table.setRowTypes([String]())
        }
    }
    
    // Reloads weather data when the current data has expired.
    func reloadWeather(_: NSTimer) {
        WatchAppWeatherModel.sharedInstance().fetchWeatherForCities([cityCode], always: true)
    }
    
    // Updates the table from the current weather information.
    private func updateTableContent() {
        // Define the row controller types
        var rowTypes = [String]()
        var dayCount = 0
        if let cityWeather = WatchAppWeatherModel.sharedInstance().weatherByCity[cityCode] {
            dayCount = min(cityWeather.detailsByDay.count, DetailsInterfaceController.maxDays)
            for dayIndex in 0..<dayCount {
                let dayForecast = cityWeather.detailsByDay[dayIndex]
                rowTypes.append("DateRowController")
                for weatherDetails in dayForecast.details {
                    rowTypes.append("DetailsRowController")
                }
            }
        }
        table.setRowTypes(rowTypes)
        
        // Configure each row
        if let cityWeather = WatchAppWeatherModel.sharedInstance().weatherByCity[cityCode] {
            var rowIndex = 0
            for dayIndex in 0..<dayCount {
                let dateController = table.rowControllerAtIndex(rowIndex++) as! DateRowController
                let dayForecast = cityWeather.detailsByDay[dayIndex]
                dateController.dateLabel.setText(dayForecast.dayString)
                for weatherDetails in dayForecast.details {
                    let detailsController = table.rowControllerAtIndex(rowIndex++) as! DetailsRowController
                    detailsController.timeLabel.setText(weatherDetails.timeString ?? "")
                    
                    var temperature = ""
                    if let temp = weatherDetails.temperature {
                        temperature = WeatherUtilities.temperatureString(temp)
                    }
                    detailsController.tempLabel.setText(temperature)
                    
                    let imageName = WeatherUtilities.selectWeatherImage(weatherDetails.weather, day: weatherDetails.day ?? true)
                    detailsController.image.setImageNamed(imageName)
                }
            }
        }
    }
}
