//
//  WatchAppWeatherInterface.swift
//  LWKWeather
//
//  Created by Kim Topley on 6/3/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import Foundation

public class WatchAppWeatherInterface {
    // Command used to request loading of weather for cities.
    // Data must be an array of city codes.
    public static let LoadWeatherCommandName = "LoadWeatherCommand"
    
    // Reply used to return city weather data. Data is an array
    // of CityWeather objects, archived as NSData.
    public static let LoadWeatherReplyName = "LoadWeatherReply"
}
