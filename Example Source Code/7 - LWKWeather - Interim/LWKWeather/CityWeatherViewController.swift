//
//  CityWeatherViewController.swift
//  WeatherStuff
//
//  Created by Kim Topley on 12/18/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit
import SharedCode

class CityWeatherViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // Background images.
    private static let dayImage = UIImage(named: "DayBackground")
    private static let nightImage = UIImage(named: "NightBackground")
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionsLabel: UILabel!
    @IBOutlet weak var weatherTable: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var settingsButton: UIButton!
    
    // The city for this view controller instance.
    // The assigned city code changes to allow reuse
    // of view controller instances.
    var cityCode: Int = 0 {
        didSet {
            installWeatherForCityCode(cityCode)
        }
    }
    
    // The complete forecast for the current city.
    private var cityWeather: CityWeather?
    
    // The current weather for the current city.
    private var weatherDetails: WeatherDetails?
    
    // Timer used to reload the weather for the current city.
    private var reloadTimer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsButton.setTitle("\u{2699}", forState: UIControlState.Normal)
        
        let model = AppWeatherModel.sharedInstance()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleWeatherModelNotification:", name: nil, object: model)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        installWeatherForCityCode(cityCode)
    }
    
    func handleWeatherModelNotification(notification: NSNotification) {
        if let codes = notification.userInfo?["cityCodes"] as? [Int] {
            // This notification affects us -- reload.
            installWeatherForCityCode(cityCode)
        }
    }
    
    private func installWeatherForCityCode(cityCode: Int) {
        // Do nothing before the view is loaded and our outlets
        // have been set.
        if (isViewLoaded()) {
            var cityName = "Unknown City"
            if let city = CityModel.sharedInstance().cityForCode(cityCode) {
                cityName = city.name
            }
            cityNameLabel.text = cityName
            
            // Get the current weather details for this city, which may
            // not yet exist.
            weatherDetails = nil
            var conditionsText = "No Weather Available"
            self.cityWeather = AppWeatherModel.sharedInstance().weatherByCity[cityCode]
            if let cityWeather = self.cityWeather {
                weatherDetails = cityWeather.currentWeather
                
                switch cityWeather.state {
                case .INIT:
                    // Nothing to do.
                    break
                    
                case .LOADING:
                    conditionsText = "Loading Weather..."
                    
                case .LOADED:
                    if weatherDetails != nil {
                        conditionsText = weatherDetails!.weatherDescription ?? "Unknown Weather"
                    }
                    
                default:
                    // Nothing to do.
                    break
                }
                
                // Start a timer to reload the weather.
                if cityWeather.reloadTime.compare(NSDate()) == .OrderedDescending {
                    reloadTimer?.invalidate()
                    reloadTimer = NSTimer(fireDate: cityWeather.reloadTime, interval: 0, target: self, selector: "reloadWeather:", userInfo: nil, repeats: false)
                    NSRunLoop.currentRunLoop().addTimer(reloadTimer!, forMode: NSDefaultRunLoopMode)
                } else {
                    // Weather has expired -- load new weather.
                    AppWeatherModel.sharedInstance().fetchWeatherForCities([cityCode], always: true)
                }
           }
            
            var temperatureText = ""
            if var temperature = weatherDetails?.temperature {
                temperatureText = WeatherUtilities.temperatureString(temperature)
            }
            temperatureLabel.text = temperatureText
            conditionsLabel.text = conditionsText
            
            // Choose the background based on the time of day.
            let day = weatherDetails?.day ?? true
            self.backgroundImage.image = day ? CityWeatherViewController.dayImage : CityWeatherViewController.nightImage
            
            // Make the forecast table display the latest data.
            weatherTable.reloadData()
         }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        reloadTimer?.invalidate()
    }
    
    func reloadWeather(_: NSTimer) {
         AppWeatherModel.sharedInstance().fetchWeatherForCities([cityCode], always: true)
    }
    
    // MARK: UITableViewDataSource methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return cityWeather?.detailsByDay.count ?? 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return cityWeather?.detailsByDay[section].dayString ?? nil
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityWeather?.detailsByDay[section].details.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CityWeatherCell", forIndexPath: indexPath) as! ForecastCell
        
        if let dayForecast = cityWeather?.detailsByDay[indexPath.section] {
            let weatherDetails = dayForecast.details[indexPath.row]
            cell.timeLabel.text = weatherDetails.timeString ?? nil
            cell.weatherImage.image = selectWeatherImage(weatherDetails.weather, day: weatherDetails.day ?? true)
            cell.tempLabel.text = weatherDetails.temperature == nil
                    ? nil : WeatherUtilities.temperatureString(weatherDetails.temperature!)
            cell.weatherLabel.text = weatherDetails.weatherSummary ?? nil
        } else {
            cell.timeLabel.text = nil
            cell.weatherImage.image = nil
            cell.tempLabel.text = nil
            cell.weatherLabel.text = nil
        }
        
        cell.backgroundColor = UIColor.clearColor()
        return cell;
    }
    
    private func selectWeatherImage(condition: WeatherDetails.WeatherCondition, day: Bool) -> UIImage? {
        return UIImage(named: WeatherUtilities.selectWeatherImage(condition, day: day))
    }
    
    // MARK: UITableViewDelegate methods
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        label.textColor = UIColor.whiteColor()
        label.numberOfLines = 0
        let text = self.tableView(tableView, titleForHeaderInSection: section)
        label.text = "\n    " + (text?.capitalizedString ?? "")
        return label
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2.1 * UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline).lineHeight
    }
}
