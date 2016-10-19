//
//  WeatherModel.swift
//  WeatherStuff
//
//  Created by Kim Topley on 12/8/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//
import Foundation

// MARK: -
// MARK: WEATHER MODEL BASE CLASS
// Base class for weather models. This class is not intended
// to be instantiated -- use an instance of a subclass instead.
public class WeatherModel {
    // Notification names.
    public struct NotificationNames {
        // Sent for any change to the weather model. UserInfo includes
        // the city codes that were affected under the key "cityCodes"
        public static let weatherModelChanged = "WeatherModelChanged"
        
        // Sent when a load operation fails. UserInfo includes
        // the city codes that were affected under the key "cityCodes"
        public static let weatherModelLoadFailed = "WeatherModelLoadFailed"
    }
    
    // Map from city code to the weather for that city.
    public private(set) var weatherByCity = [Int: CityWeather]()
    
    // Constants
    private static let timeUnitsMask: NSCalendarUnit = .CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond
    private static let formatter: NSDateFormatter = NSDateFormatter()
    private static let dayMonthDateFormat = "EEEE, MMMM dd"  // Day, month, date
    private static let timeFormat = "ha"  // e.g. 3PM
    
    // The loader for this model. Different subclasses can use
    // different loaders.
    private lazy var loader: WeatherModelLoader = {
        return self.createWeatherModelLoader()
    }()
    
    // Determines whether this model can update the persistent storage.
    // By default, update is not allowed. Subclasses should override to change.
    public var readOnly: Bool {
        return true
    }
    
    // URL for the directory holding the stored weather files.
    private let weatherDirURL: NSURL
    
    // Time for which weather data should be considered valid, in seconds.
    private let weatherDataValidTime: NSTimeInterval = 60 * 60  // 60 minutes
    private let shortReloadTime: NSTimeInterval = 15;
    
    // Initializer. Needs to be public to allow subclassing.
    public init() {
        // Files are stored in the "/Library/Caches/LWKWeather" directory of the app sandbox.
        let baseURL = NSFileManager.defaultManager().URLsForDirectory(
                            NSSearchPathDirectory.CachesDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        weatherDirURL = baseURL.URLByAppendingPathComponent("LWKWeather")
        
        // Create the directory if it doesn't exist. Do this only if this is not
        // a read-only model.
        if !readOnly {
            let fm = NSFileManager.defaultManager()
            if let path = weatherDirURL.path {
                if !fm.fileExistsAtPath(path) {
                    var error: NSError? = nil
                    fm.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: &error)
                    if error != nil {
                        println("Failed to create weather data directory: \(error)")
                    }
                }
            }
        }

        WeatherModel.formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    }
    
    // Creates the loader for the weather data. Must be overridden by subclasses
    // to create a loader of the appropriate type.
    public func createWeatherModelLoader() -> WeatherModelLoader {
        preconditionFailure("This method must be overridden")
    }
    
    // Loads the weather model from persistent storage, replacing any current state.
    public func loadWeatherModel() {
        assert(NSThread.isMainThread())
        weatherByCity.removeAll(keepCapacity: true)
        
        let fm = NSFileManager.defaultManager()
        let weatherDirPath = weatherDirURL.path!
        if let subPaths = fm.subpathsAtPath(weatherDirPath) as? [String] {
            for subPath in subPaths {
                if subPath.pathExtension == "weather" {
                    let cityCodeStr = subPath.stringByDeletingPathExtension
                    if let cityCode = cityCodeStr.toInt(),
                        let cityWeather = getArchivedWeatherForCity(cityCode) {
                        // Data is valid -- install it.
                        weatherByCity[cityCode] = cityWeather
                    }
                }
            }
        }
    }
    
    // Loads new weather for zero or more cities, sending a notification
    // as each city's data is received. When all of the weather has been
    // received, the new weather model state is saved. 
    // New data is not loaded if the existing data is still
    // current, unless "always" is true
    public func fetchWeatherForCities(cityCodes: [Int], always: Bool) {
        assert(NSThread.isMainThread())
        var cityCodesToLoad = [Int]()
        for cityCode in cityCodes {
            // Load data for this city only if not already loaded, or
            // if loaded but the data has expired, or if "always" is true.
            var load = true
            if !always {
                if let cityWeather = weatherByCity[cityCode] {
                    load = cityWeather.shouldReload
                }
            }
            if (load) {
                cityCodesToLoad.append(cityCode)
            }
        }
        
        if (!cityCodesToLoad.isEmpty) {
            // Set loading state for each city for which weather
            // is about to be loaded.
            for cityCode in cityCodesToLoad {
                if let cityWeather = weatherByCity[cityCode] {
                    cityWeather.state = .LOADING
                } else {
                    let cityWeather = CityWeather(cityCode: cityCode)
                    cityWeather.state = .LOADING
                    weatherByCity[cityCode] = cityWeather
                }
                
                // Temporarily set a reload time a short time ahead to
                // ensure that we don't get immediate reload attempts.
                weatherByCity[cityCode]?.reloadTime = NSDate(timeIntervalSinceNow: shortReloadTime)
            }
        
            // Have the loader fetch the data in a background thread.
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                self.loader.fetchWeatherForCities(cityCodesToLoad)
            })
        }
    }
    
    // Gets the archived weather for a city with a given city code,
    // if it exists.
    public func getArchivedWeatherForCity(cityCode: Int) -> CityWeather? {
        var cityWeather: CityWeather?
        let weatherDirPath = weatherDirURL.path
        if let weatherFilePath = weatherDirPath?.stringByAppendingPathComponent("\(cityCode).weather") {
            let fm = NSFileManager.defaultManager()
            if (fm.fileExistsAtPath(weatherFilePath)) {
                let fileData = NSData(contentsOfFile: weatherFilePath)
                if (fileData != nil) {
                    cityWeather = NSKeyedUnarchiver.unarchiveObjectWithData(fileData!) as? CityWeather
                }
            }
        }
        return cityWeather
    }
    
    // Installs new weather data for a city, saving to persistent storage
    // if permitted. Sends a notification with name NotificationNames.weatherModelChanged 
    // with a userInfo object that has the city code as the single element of an Int array
    // with key "cityCodes".
    public func installNewWeatherForCity(cityCode: Int, weatherDetails: [WeatherDetails]) {
        installNewWeatherForCity(cityCode, detailsByDay: WeatherModel.buildDetailsByDay(cityCode, weatherDetails: weatherDetails))
    }
    
    // Installs new weather data for a city, saving to persistent storage
    // if permitted. Sends a notification with name NotificationNames.weatherModelChanged
    // with a userInfo object that has the city code as the single element of an Int array
    // with key "cityCodes".
    public func installNewWeatherForCity(cityCode: Int, detailsByDay: [DayForecast]) {
        dispatch_async(dispatch_get_main_queue(), {
            let weather = self.weatherByCity[cityCode] ?? CityWeather(cityCode: cityCode)
            
            weather.state = .LOADED
            weather.reloadTime = NSDate(timeIntervalSinceNow: self.weatherDataValidTime)
            weather.detailsByDay = detailsByDay
            self.weatherByCity[cityCode] = weather
            self.saveWeatherForCity(cityCode)
            
            NSNotificationCenter.defaultCenter().postNotificationName(
                                    NotificationNames.weatherModelChanged, object: self,
                                    userInfo: ["cityCodes": [cityCode]])
        })
    }
    
    // Sends a notification that weather loading failed for one or more cities.
    // Sends a notification with name NotificationNames.weatherModelLoadFailed
    // with a userInfo object that has the city codes in an Int array
    // with key "cityCodes".
    public func notifyWeatherModelLoadFailure(error: NSError, cityCodes: [Int]?) {
        dispatch_async(dispatch_get_main_queue(), {
            if (cityCodes != nil) {
                for cityCode in cityCodes! {
                    if let cityWeather = self.weatherByCity[cityCode] {
                        cityWeather.state = .ERROR
                        self.saveWeatherForCity(cityCode)
                    }
                }
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(
                                    NotificationNames.weatherModelLoadFailed, object: self,
                                    userInfo: ["cityCodes": cityCodes ?? [Int]()])
        })
    }
    
    // MARK: -
    // MARK: IMPLEMENTATION DETAILS
   
    // Saves the weather data for a given city, unless the model is read-only
    private func saveWeatherForCity(cityCode: Int) {
        assert(NSThread.isMainThread())
        
        if !self.readOnly, let cityWeather = weatherByCity[cityCode] {
            let data = NSKeyedArchiver.archivedDataWithRootObject(cityWeather)
            let fileURL = getWeatherFileURLForCity(cityCode)
            data.writeToURL(fileURL, atomically: true)
        }
    }
    
    // Creates a day forecast array from the forecast details for
    // a given CityWeather object
    private static func buildDetailsByDay(cityCode: Int, weatherDetails: [WeatherDetails]) -> [DayForecast] {
        var detailsByDay: [DayForecast] = []
        if !weatherDetails.isEmpty {
            let calendar = NSCalendar.currentCalendar()
            if let cityData = CityModel.sharedInstance().cityForCode(cityCode) {
                let tzName = cityData.timezone
                if let cityTimeZone = NSTimeZone(name: tzName) {
                    calendar.timeZone = cityTimeZone
                    WeatherModel.formatter.timeZone = cityTimeZone
                    let secondsPerDay: NSTimeInterval = 24 * 60 * 60
                    var nextDayEnd = NSDate.distantPast() as! NSDate
                    var dayForecast: DayForecast?
                    for weatherDetails in weatherDetails {
                        if (dayForecast == nil ||
                                weatherDetails.startTime.compare(nextDayEnd) != .OrderedAscending) {
                            // This entry corresponds to a new day or the first day.
                            // Create a new DayForecast object for it.
                            let components = calendar.components(WeatherModel.timeUnitsMask, fromDate: weatherDetails.startTime)
                            components.hour = 0
                            components.minute = 0
                            components.second = 0
                            let startOfDayDate = calendar.dateFromComponents(components)! // Start of day time at location, in UTC
                            nextDayEnd = startOfDayDate.dateByAddingTimeInterval(secondsPerDay) // End of day time in location, in UTC
                                    
                            // Create a DayForecast object with the correct day description.
                            WeatherModel.formatter.dateFormat = WeatherModel.dayMonthDateFormat
                            dayForecast = DayForecast(dayString: WeatherModel.formatter.stringFromDate(startOfDayDate))
                            detailsByDay.append(dayForecast!)
                        }
                        
                        WeatherModel.formatter.dateFormat = WeatherModel.dayMonthDateFormat
                        weatherDetails.dayString = WeatherModel.formatter.stringFromDate(weatherDetails.startTime)
                        WeatherModel.formatter.dateFormat = WeatherModel.timeFormat
                        weatherDetails.timeString = WeatherModel.formatter.stringFromDate(weatherDetails.startTime)
                        dayForecast!.details.append(weatherDetails)
                    }
                }
            }
        }
        return detailsByDay
    }
    
    // Gets the URL for the weather data file for a city.
    private func getWeatherFileURLForCity(cityCode: Int) -> NSURL {
        return weatherDirURL.URLByAppendingPathComponent("\(cityCode).weather")
    }
}

// MARK: -
// MARK: WEATHER MODEL LOADER PROTOCOL.

// Requests that the loader obtain weather details for a given
// set of cities. The loader should at some stage call the model's
// installNewWeatherForCity(_:weatherDetails:updateFile:) method
// for each city for which data was received and its
// notifyWeatherModelLoadFailure(_:cityCodes:) method for cities
// for which an error occurred while fetching the weather.
//
// This method is always called on the main thread.
public protocol WeatherModelLoader {
    func fetchWeatherForCities(cityCodes: [Int])
}

