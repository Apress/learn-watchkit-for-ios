//
//  InterfaceController.swift
//  LWK Weather WatchKit Extension
//
//  Created by Kim Topley on 6/1/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation
import SharedCode

class InterfaceController: WKInterfaceController, DisplayedCityInfoModelDelegate {
    @IBOutlet weak var table: WKInterfaceTable!
    
    // The cities for which data is currently displayed.
    private var displayedCityCodes = [Int]()
        
    // Timer used to reload weather.
    private var reloadTimer: NSTimer?
        
    // Next city for which data should be reloaded.
    private var reloadCityCode: Int?
        
    // MARK: -
    // MARK: Initialization
    override init() {
        super.init()
        WatchAppWeatherModel.sharedInstance().loadWeatherModel()
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        setTitle("Weather")
        
        // Configure interface objects here.
        // Build the table based on the current displayed
        // cities.
        checkAndRebuildTable()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // Listen to changes in the displayed city list and
        // the celsius/farenheit setting.
        DisplayedCityInfoModel.sharedInstance().delegate = self
        
        // Rebuild the table if the displayed cities list or the
        // temperature setting has changed. Update based on the
        // current weather data.
        checkAndRebuildTable()
        updateTable()
        
        // Observe notification of weather model changes.
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "onNotification:", name: nil,
            object: WatchAppWeatherModel.sharedInstance())
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        DisplayedCityInfoModel.sharedInstance().delegate = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
        reloadTimer?.invalidate()
    }
    
    // MARK: -
    // MARK: HANDOFF
    override func handleUserActivity(userInfo: [NSObject : AnyObject]?) {
        if let dictionary = userInfo as? [String: AnyObject],
            let cityCode = dictionary["cityCode"] as? Int {
                pushControllerWithName("DetailsInterfaceController", context: cityCode)
        }
    }
    
    // MARK: -
    // MARK: DisplayedCityInfoModelDelegate implementation
    // Method called when the list of displayed cities or the temperature
    // setting changes. Rebuild the table if necessary and update the
    // table content.
    func displayedCityInfoDidChange(model: DisplayedCityInfoModel) {
        checkAndRebuildTable()
        updateTable()
    }
    
    // MARK: -
    // MARK: Notification handling
    // Handles a notification, which means that some data
    // in the weather model has changed. If it affects any of
    // the cities that we are displaying, update the table.
    func onNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let cityCodes = userInfo["cityCodes"] as? [Int] {
                for cityCode in cityCodes {
                    if find(displayedCityCodes, cityCode) != nil {
                        updateTable()
                        break
                    }
                }
        }
    }
    
    // MARK: -
    // MARK: Table construction
    // Rebuilds the table rows if the displayed cities list
    // changes and recreates the table data if so.
    private func checkAndRebuildTable() {
        DisplayedCityInfoModel.sharedInstance().loadDisplayedCities()
        let cityCodes = DisplayedCityInfoModel.sharedInstance().displayedCities
        let citiesChanged = cityCodes != displayedCityCodes
        if citiesChanged {
            // Cities changing.
            displayedCityCodes = cityCodes
            table.setNumberOfRows(displayedCityCodes.count, withRowType: "CityTableRowController")
            WatchAppWeatherModel.sharedInstance().fetchWeatherForCities(displayedCityCodes, always: false)
        }
    }
    
    // MARK: -
    // MARK: Table updates
    // Updates the table based on the current weather data.
    private func updateTable() {
        var reloadTime = NSDate.distantFuture() as! NSDate
        reloadCityCode = nil;
        for index in 0..<displayedCityCodes.count {
            var imageName: String? = nil
            var temperature = ""
            let rowController = table.rowControllerAtIndex(index) as! CityTableRowController
            let cityCode = displayedCityCodes[index]
            let cityName = CityModel.sharedInstance().cityForCode(cityCode)?.name ?? "Unknown City"
            if let cityWeather = WatchAppWeatherModel.sharedInstance().weatherByCity[cityCode],
                let weatherDetails = cityWeather.currentWeather
                        where cityWeather.state == .LOADED {
                    if let temp = weatherDetails.temperature {
                        temperature = WeatherUtilities.temperatureString(temp)
                    }
                    imageName = WeatherUtilities.selectWeatherImage(weatherDetails.weather, day: weatherDetails.day ?? true)
                    
                    // Update the reloadTime to the earliest reload time
                    // encountered so far
                    let thisReloadTime = cityWeather.reloadTime
                    if thisReloadTime.compare(reloadTime) == .OrderedAscending {
                        reloadTime = thisReloadTime
                        reloadCityCode = cityCode
                    }
            }
            
            rowController.cityLabel.setText(cityName)
            rowController.temperatureLabel.setText(temperature)
            rowController.image.setImageNamed(imageName)
        }
        
        // Start a timer so that the weather is reloaded when it expires.
        if (reloadCityCode != nil) {
            if (reloadTimer == nil || !reloadTimer!.valid || reloadTimer!.fireDate.compare(reloadTime) == .OrderedDescending) {
                reloadTimer?.invalidate()
                reloadTimer = NSTimer(fireDate: reloadTime, interval: 0, target: self, selector: "reloadWeather:", userInfo: nil, repeats: false)
                NSRunLoop.currentRunLoop().addTimer(reloadTimer!, forMode: NSDefaultRunLoopMode)
            }
        }
    }
    
    // Reloads data for the all cities for which the weather
    // data has expired.
    func reloadWeather(_: NSTimer) {
        var citiesToReload = [Int]()
        let cityCodes = DisplayedCityInfoModel.sharedInstance().displayedCities
        for cityCode in cityCodes {
            if let cityWeather = WatchAppWeatherModel.sharedInstance().weatherByCity[cityCode] {
                if cityWeather.shouldReload {
                    citiesToReload.append(cityCode)
                }
            }
        }
        
        if citiesToReload.count > 0 {
            WatchAppWeatherModel.sharedInstance().fetchWeatherForCities(citiesToReload, always: true)
        }
    }
    
    // Gets the context for the segue from a table row.
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        return DisplayedCityInfoModel.sharedInstance().displayedCities[rowIndex]
    }
}
