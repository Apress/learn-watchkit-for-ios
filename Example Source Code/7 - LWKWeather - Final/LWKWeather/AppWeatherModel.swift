//
//  AppWeatherModel.swift
//  LWKWeather
//
//  Created by Kim Topley on 5/21/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import Foundation
import CoreLocation
import SharedCode


// MARK: -
// MARK: iOS APPLICATION WEATHER MODEL

// The iOS application implementation of the weather model.
public class AppWeatherModel : WeatherModel {
    
    // Holder for the shared instance of this model.
    private static var token: dispatch_once_t = 0
    private static var instance: AppWeatherModel?
    
    // The completion handler for NSURLSession handling when the app
    // is restarted on completion of the request.
    public var completionHandler: (() -> Void)?
    
    // Determines whether this model can update the persistent storage.
    // Overrides the default to allow updates.
    public override var readOnly: Bool {
        return false
    }
    
    // Gets the shared instance of this model.
    public class func sharedInstance() -> WeatherModel {
        dispatch_once(&token) {
            self.instance = AppWeatherModel()
        }
        return instance!
    }

    // Creates the loader for the weather data. Returns a loader that fetches
    // weather data from openweathermap.org
    public override func createWeatherModelLoader() -> WeatherModelLoader {
        return OpenWeatherMapLoader(model: self)
    }
}

// MARK: -
// MARK: iOS APPLICATION WEATHER MODEL LOADER
private class OpenWeatherMapLoader: NSObject, NSURLSessionDownloadDelegate, WeatherModelLoader {
    private static let sessionId = "com.apress.lwk.weather"
    private static let weatherBase = "http://api.openweathermap.org/data/2.5/forecast"
    private static let weatherBlockTime = 3 * 60 * 60 as NSTimeInterval
    private let model: WeatherModel
    private var session: NSURLSession!
    
    init(model: WeatherModel) {
        self.model = model
        super.init()
        let sessionConfig = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(OpenWeatherMapLoader.sessionId)
        sessionConfig.timeoutIntervalForRequest = 60
        session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
    }
    
    // Requests that the loader obtain weather details for a given
    // set of cities. The loader should at some stage call the model's
    // installNewWeatherForCity(_:weatherDetails:updateFile:) method
    // for each city for which data was received and its
    // notifyWeatherModelLoadFailure(_:cityCodes:) method for cities
    // for which an error occurred while fetching the weather.
    //
    // This method is always called on the main thread.
    //
    // This implementation fetches data from openweathermap.org
    func fetchWeatherForCities(cityCodes: [Int]) {
        for cityCode in cityCodes {
            let urlStr = OpenWeatherMapLoader.weatherBase + "?id=\(cityCode)"
            let request = NSMutableURLRequest(URL: NSURL(string: urlStr)!)
            NSURLProtocol.setProperty(cityCodes, forKey: "cityCodes", inRequest: request)
            let task = session.downloadTaskWithRequest(request)
            task.resume()
        }
    }
    
    // MARK: NSURLSessionDownloadDelegate methods
    @objc func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        let content = NSData(contentsOfURL: location)
        
        if let weatherData = content {
            let result = decodeWeatherData(weatherData)
            if let newWeather: (cityCode: Int, weatherDetails: [WeatherDetails]) = result.weather {
                self.model.installNewWeatherForCity(newWeather.cityCode, weatherDetails: newWeather.weatherDetails)
            } else if let error = result.error {
                let request = downloadTask.originalRequest
                let cityCodes = NSURLProtocol.propertyForKey("cityCodes", inRequest: request) as? [Int]
                self.model.notifyWeatherModelLoadFailure(error, cityCodes: cityCodes)
            }
        }
    }
    
    @objc func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if (error != nil) {
            let request = task.originalRequest
            let cityCodes = NSURLProtocol.propertyForKey("cityCodes", inRequest: request) as? [Int]
            self.model.notifyWeatherModelLoadFailure(error!, cityCodes: cityCodes)
        }
    }
    
    @objc func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        if let appWeatherModel = model as? AppWeatherModel,
            let completionHandler = appWeatherModel.completionHandler {
                appWeatherModel.completionHandler = nil
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler()
                }
        }
    }
    
    // MARK: Weather handling methods
    private func decodeWeatherData(data: NSData) -> (error: NSError?, weather: (Int, [WeatherDetails])?) {
        var result: (error: NSError?, weather: (Int, [WeatherDetails])?) = (nil, nil)
        var error: NSError? = nil
        let jsonResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error)
        
        if let forecastDetails = jsonResult as? [String: AnyObject] {
            if let codeStr = forecastDetails["cod"] as? String {
                if let code = codeStr.toInt() {
                    if (code != 200) {
                        error = NSError(domain: "WeatherDomain", code: code, userInfo: nil)
                    }
                } else {
                    error = NSError(domain: "WeatherDomain", code: -1, userInfo: nil)
                }
            }
            if (error == nil) {
                if let cityDetails = forecastDetails["city"] as? [String : AnyObject] {
                    if let cityCode = cityDetails["id"] as! Int? {
                        let locationName = cityDetails["name"] as? String
                        let coords = cityDetails["coord"] as? [String: AnyObject]
                        let latitude = coords?["lat"] as? Double
                        let longitude = coords?["lon"] as? Double
                        if let forecastSections = forecastDetails["list"] as? [[String: AnyObject]] {
                            var allWeatherDetails: [WeatherDetails] = []
                            let now = NSDate()
                            for forecastSection in forecastSections {
                                // We require the time and weather to be present.
                                if let time = forecastSection["dt"] as? NSTimeInterval {
                                    let startTime = NSDate(timeIntervalSince1970: time)
                                    let endTime = NSDate(timeInterval: OpenWeatherMapLoader.weatherBlockTime, sinceDate: startTime)
                                    if endTime.compare(now) == .OrderedDescending { // Discard entries that have expired
                                        if let weatherArray = forecastSection["weather"] as? [[String: AnyObject]] {
                                            if weatherArray.count > 0 {
                                                let weatherData = weatherArray[0]
                                                let id = weatherData["id"] as? Int
                                                let summary = weatherData["main"] as? String
                                                let description = weatherData["description"] as! String?
                                                let weatherCondition = id == nil ? .Other : weatherConditionFrom(id: id!)
                                                
                                                var location: CLLocationCoordinate2D?
                                                if latitude != nil && longitude != nil {
                                                    location = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                                                }
                                                
                                                var temperature: Int?
                                                var pressure: Float?
                                                var humidity: Int?
                                                if let main = forecastSection["main"] as? [String: AnyObject] {
                                                    if let temp = main["temp"] as? Double {
                                                        // Convert Kelvin to Celsius
                                                        temperature = Int(round(temp - 273.15))
                                                    }
                                                    pressure = main["pressure"] as? Float
                                                    humidity = main["humidity"] as? Int
                                                }
                                                
                                                var clouds: Int?
                                                if let cloudValues = forecastSection["clouds"] as? [String: AnyObject] {
                                                    clouds = cloudValues["all"] as? Int
                                                }
                                                
                                                var windSpeed: Int?
                                                var windDirection: Int?
                                                if let wind = forecastSection["wind"] as? [String: AnyObject] {
                                                    if let speedMps = wind["speed"] as? Double {
                                                        // Convert meters/second to miles/hour
                                                        windSpeed = Int(round(2.23694 * speedMps))
                                                    }
                                                    if let direction = wind["deg"] as? Double {
                                                        windDirection = Int(round(direction))
                                                    }
                                                }
                                                
                                                var day: Bool?
                                                if let sys = forecastSection["sys"] as? [String: AnyObject] {
                                                    if let partOfDay = sys["pod"] as? String {
                                                        if partOfDay == "d" {
                                                            day = true
                                                        } else if partOfDay == "n" {
                                                            day = false
                                                        }
                                                    }
                                                }
                                                var weatherDetails = WeatherDetails(cityCode: cityCode, startTime: startTime,
                                                    endTime: endTime, weather: weatherCondition, weatherSummary: summary,
                                                    weatherDescription: description?.capitalizedString ?? nil,
                                                    locationName: locationName, location: location, temperature: temperature,
                                                    pressure: pressure, humidity: humidity, clouds: clouds, windSpeed: windSpeed,
                                                    windDirection: windDirection, day: day)
                                               
                                                allWeatherDetails.append(weatherDetails)
                                            }
                                        }
                                    }
                                }
                            }

                            // Set the full weather forecast for this city, sorted by start time.
                            if !allWeatherDetails.isEmpty {
                                allWeatherDetails.sort() {(d1: WeatherDetails, d2: WeatherDetails) in
                                    d1.startTime.compare(d2.startTime) == .OrderedAscending
                                }
                                result.weather = (cityCode, allWeatherDetails)
                            }
                        }
                    }
                }
            }
        } else {
            error = NSError(domain: "WeatherDomain", code: -1, userInfo: nil)
        }
        result.error = error
        return result
    }
    
    private func weatherConditionFrom(#id: Int) -> WeatherDetails.WeatherCondition {
        var result: WeatherDetails.WeatherCondition = .Other
        switch id {
        case 200..<300:
            result = .Thunder
            break
            
        case 300..<400:
            result = .Drizzle
            break
            
        case 500, 520:
            result = .LightRain
            break
            
        case 501:
            result = .Rain
            break
            
        case 502...504:
            result = .HeavyRain
            break
            
        case 511:
            result = .FreezingRain
            break
            
        case 520, 521, 522, 531:
            result = .Showers
            break
            
        case 500..<600:  // All other rain cases
            result = .Rain
            break
            
        case 600, 615:
            result = .LightSnow
            break
            
        case 601, 616, 620, 621:
            result = .Snow
            break
            
        case 602, 622:
            result = .HeavySnow
            break
            
        case 611, 612:
            result = .Sleet
            break
            
        case 701:
            result = .Mist
            break
            
        case 721:
            result = .Haze
            break
            
        case 741:
            result = .Fog
            break
            
        case 800:
            result = .Clear
            break
            
        case 801:
            result = .FewClouds
            break
            
        case 802:
            result = .ScatteredClouds
            break;
            
        case 803:
            result = .BrokenClouds
            break
            
        case 804:
            result = .OvercastClouds
            break
            
        default:
            result = .Other
            break
        }
        
        return result
    }
}
