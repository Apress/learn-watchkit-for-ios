//
//  WeatherData.swift
//  LWKWeather
//
//  Created by Kim Topley on 5/21/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: -
// MARK: WEATHER DATA STRUCTURES
public class CityWeather: NSObject, NSCoding {
    // Enumeration of weather details states
    public enum WeatherDetailsState: Int {
        case INIT
        case LOADING
        case LOADED
        case ERROR
    }
    
    // The city code.
    public let cityCode: Int
    
    // The state of this data
    public internal(set) var state: WeatherDetailsState
    
    // Time at which weather details should be reloaded.
    public internal(set) var reloadTime: NSDate = NSDate()
    
    // The details for this city, with one entry per day.
    public internal(set) var detailsByDay: [DayForecast] = []
    
    // The current weather
    public var currentWeather: WeatherDetails? {
        return detailsByDay.first?.details.first
    }
    
    // Description property.
    override public var description: String {
        get {
            return "City: \(cityCode), state: \(state), data: \(detailsByDay), "
                + " reload time: \(reloadTime)\n"
        }
    }
    
    // Whether the weather details should be reloaded.
    public var shouldReload: Bool {
        return (state != .LOADED && state != .LOADING) || reloadTime.compare(NSDate()) == .OrderedAscending
    }
   
    // Constructs an instance of this object with default initial state.
    init(cityCode: Int) {
        self.cityCode = cityCode
        self.state = .INIT
    }
    
    required public init(coder: NSCoder) {
        self.cityCode = coder.decodeIntegerForKey("cityCode")
        if let state = WeatherDetailsState(rawValue: coder.decodeIntegerForKey("state")) {
            self.state = state
        } else {
            self.state = .INIT
        }
        self.reloadTime = coder.decodeObjectForKey("reloadTime") as! NSDate
        self.detailsByDay = coder.decodeObjectForKey("detailsByDay") as! [DayForecast]
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeInteger(cityCode, forKey: "cityCode")
        coder.encodeInteger(state.rawValue, forKey: "state")
        coder.encodeObject(reloadTime, forKey: "reloadTime")
        coder.encodeObject(detailsByDay, forKey: "detailsByDay")
    }
}

public class DayForecast: NSObject, NSCoding {
    // The day for this forecast (e.g. Wednesday, May 27)
    public let dayString: String
    
    // The weather details for this day.
    public internal(set) var details: [WeatherDetails]
    
    init(dayString: String) {
        self.dayString = dayString
        self.details = []
    }
    
    public required init(coder aDecoder: NSCoder) {
        dayString = aDecoder.decodeObjectForKey("dayString") as! String
        details = aDecoder.decodeObjectForKey("details") as! [WeatherDetails]
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(dayString, forKey: "dayString")
        aCoder.encodeObject(details, forKey: "details")
    }
}

public class WeatherDetails: NSObject, NSCoding {
    public enum WeatherCondition: Int {
        case Thunder
        case Drizzle
        case LightRain
        case Rain
        case HeavyRain
        case FreezingRain
        case Showers
        case LightSnow
        case Snow
        case HeavySnow
        case Sleet
        case Mist
        case Haze
        case Fog
        case Clear
        case FewClouds
        case ScatteredClouds
        case BrokenClouds
        case OvercastClouds
        case Other
    }
    
    // City to which this weather applies.
    public internal(set) var cityCode: Int
    
    // Start time for weather.
    public internal(set) var startTime: NSDate
    
    // End time for weather.
    public internal(set) var endTime: NSDate
    
    // Day string for these details (e.g. Mon Jan 3)
    public internal(set) var dayString: String?
    
    // Time string for these details, relative to the day (e.g. 3PM)
    public internal(set) var timeString: String?
    
    // Actual or forecast weather
    public internal(set) var weather: WeatherCondition
    
    // Weather condition summary
    public internal(set) var weatherSummary: String?
    
    // Weather condition description
    public internal(set) var weatherDescription: String?
    
    // Name of the location.
    public internal(set) var locationName: String?
    
    // The lat/long for this weather
    public internal(set) var location: CLLocationCoordinate2D?
    
    // Temperature in Celcius
    public internal(set) var temperature: Int?
    
    // Pressure in milllibars
    public internal(set) var pressure: Float?
    
    // Humidity percentage
    public internal(set) var humidity: Int?
    
    // Cloud cover percentage
    public internal(set) var clouds: Int?
    
    // Wind speed, miles per hour
    public internal(set) var windSpeed: Int?
    
    // Wind direction in degrees: North = 0, East = 90
    public internal(set) var windDirection: Int?
    
    // Day or night.
    public internal(set) var day: Bool?
    
    // Description property.
    override public var description: String {
        get {
            return "City: \(cityCode), name: \(locationName), location: \(location),"
                + " start: \(startTime), condition: \(weather), summary: \(weatherSummary),"
                + " description: \(weatherDescription), temp: \(temperature),"
                + " pressure: \(pressure), humidity: \(humidity), clouds: \(clouds)%"
                + " wind: \(windSpeed) mph from \(windDirection)\n"
        }
    }
    
    public init(cityCode: Int, startTime: NSDate, endTime: NSDate, weather: WeatherCondition,
                weatherSummary: String?, weatherDescription: String?, locationName: String?,
                location: CLLocationCoordinate2D?, temperature: Int?, pressure: Float?,
                humidity: Int?, clouds: Int?, windSpeed: Int?, windDirection: Int?,
                day: Bool?) {
        self.cityCode = cityCode
        self.startTime = startTime
        self.endTime = endTime
        self.weather = weather
        self.weatherSummary = weatherSummary
        self.weatherDescription = weatherDescription
        self.locationName = locationName
        self.location = location
        self.temperature = temperature
        self.pressure = pressure
        self.humidity = humidity
        self.clouds = clouds
        self.windSpeed = windSpeed
        self.windDirection = windDirection
        self.day = day
    }
    
    public required init(coder: NSCoder) {
        cityCode = coder.decodeIntegerForKey("cityCode")
        startTime = coder.decodeObjectForKey("startTime") as! NSDate
        endTime = coder.decodeObjectForKey("endTime") as! NSDate
        if coder.containsValueForKey("dayString") {
            dayString = coder.decodeObjectForKey("dayString") as? String
        }
        if coder.containsValueForKey("timeString") {
            timeString = coder.decodeObjectForKey("timeString") as? String
        }
        
        if let weatherCondition = WeatherCondition(rawValue: coder.decodeIntegerForKey("weather")) {
            self.weather = weatherCondition
        } else {
            self.weather = .Other
        }
        
        if coder.containsValueForKey("weatherSummary") {
            weatherSummary = coder.decodeObjectForKey("weatherSummary") as? String
        }
        if coder.containsValueForKey("weatherDescription") {
            weatherDescription = coder.decodeObjectForKey("weatherDescription") as? String
        }
        if coder.containsValueForKey("locationName") {
            locationName = coder.decodeObjectForKey("locationName") as? String
        }
        if coder.containsValueForKey("latitude") && coder.containsValueForKey("longitude") {
            let latitude = coder.decodeDoubleForKey("latitude")
            let longitude = coder.decodeDoubleForKey("longitude")
            location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        if coder.containsValueForKey("temperature") {
            temperature = coder.decodeIntegerForKey("temperature")
        }
        if coder.containsValueForKey("pressure") {
            pressure = coder.decodeFloatForKey("pressure")
        }
        if coder.containsValueForKey("humidity") {
            humidity = coder.decodeIntegerForKey("humidity")
        }
        if coder.containsValueForKey("clouds") {
            clouds = coder.decodeIntegerForKey("clouds")
        }
        if coder.containsValueForKey("windSpeed") {
            windSpeed = coder.decodeIntegerForKey("windSpeed")
        }
        if coder.containsValueForKey("windDirection") {
            windDirection = coder.decodeIntegerForKey("windDirection")
        }
        if coder.containsValueForKey("day") {
            day = coder.decodeBoolForKey("day")
        }
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeInteger(cityCode, forKey: "cityCode")
        coder.encodeObject(startTime, forKey: "startTime")
        coder.encodeObject(endTime, forKey: "endTime")
        if dayString != nil {
            coder.encodeObject(dayString, forKey: "dayString")
        }
        if timeString != nil {
            coder.encodeObject(timeString, forKey: "timeString")
        }
        coder.encodeInteger(weather.rawValue, forKey: "weather")
        if weatherSummary != nil {
            coder.encodeObject(weatherSummary, forKey: "weatherSummary")
        }
        if weatherDescription != nil {
            coder.encodeObject(weatherDescription!, forKey: "weatherDescription")
        }
        if locationName != nil {
            coder.encodeObject(locationName, forKey: "locationName")
        }
        if location != nil {
            coder.encodeDouble(location!.latitude, forKey: "latitude")
            coder.encodeDouble(location!.longitude, forKey: "longitude")
        }
        if temperature != nil {
            coder.encodeInteger(temperature!, forKey: "temperature")
        }
        if pressure != nil {
            coder.encodeFloat(pressure!, forKey: "pressure")
        }
        if humidity != nil {
            coder.encodeInteger(humidity!, forKey: "humidity")
        }
        if clouds != nil {
            coder.encodeInteger(clouds!, forKey: "clouds")
        }
        if windSpeed != nil {
            coder.encodeInteger(windSpeed!, forKey: "windSpeed")
        }
        if windDirection != nil {
            coder.encodeInteger(windDirection!, forKey: "windDirection")
        }
        if day != nil {
            coder.encodeBool(day!, forKey: "day")
        }
        
    }
}
