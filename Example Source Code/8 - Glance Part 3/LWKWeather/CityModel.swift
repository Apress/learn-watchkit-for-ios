//
//  CityModel.swift
//  WeatherStuff
//
//  Created by Kim Topley on 12/15/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import Foundation

// A structure that contains the information for a city.
public struct City: Printable {
    // The city code
    public let cityCode: Int
    
    // The city name
    public let name: String
    
    // The city timezone name
    public let timezone: String
    
    // Human-readable description
    public var description: String {
        return "\(name), city code: \(cityCode), TZ: \(timezone)"
    }
}

// Model that holds information for all available cities.
public class CityModel {
    // List of cities, ordered by name.
    public private(set) var cities: [City] = []

    // Holder for the shared instance of this model.
    private static var token: dispatch_once_t = 0
    private static var instance: CityModel?
    
    // Map from city code to city data
    private var citiesByCode: [Int: City] = [:]
    
    // Gets the shared instance of this model.
    public class func sharedInstance() -> CityModel {
        dispatch_once(&token) {
            self.instance = CityModel()
        }
        return instance!
    }
    
    // MARK: Access to city data
    
    // Gets the city with a given code, if one exists
    public func cityForCode(cityCode: Int) -> City? {
        return citiesByCode[cityCode]
    }
    
    // Private initializer. Loads the model from a .plist file.
    private init() {
        loadModel()
    }
    
    // MARK: Model Loading
    private func loadModel() {
        let bundle = NSBundle(forClass: CityModel.self)
        if let cityFileURL = bundle.URLForResource("cities", withExtension: "plist") {
            if let cityDataList = NSArray(contentsOfURL: cityFileURL) as? [[String: AnyObject]] {
                // Each element of the array is a map containing the data for a city.
                for cityData in cityDataList {
                    let code = cityData["code"] as! Int
                    let name = cityData["name"] as! String
                    let timezone = cityData["tz"] as! String
                    let city = City(cityCode: code, name: name, timezone: timezone)
                    
                    citiesByCode[code] = city
                    cities.append(city)
                }
                
                // Sort the cities list by name
                cities.sort({ $0.name < $1.name })
            } else {
                println("cities.plist has invalid content")
            }
        } else {
            println("cities.plist not found")
        }
    }
}

