//
//  WeatherUtilities.swift
//  LWKWeather
//
//  Created by Kim Topley on 5/23/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import Foundation

public class WeatherUtilities {
    // Converts a temperature to display form in either celsius
    // or farenheit, depending on the user's preference.
    public static func temperatureString(temperature: Int) -> String {
        let useCelsius = DisplayedCityInfoModel.sharedInstance().useCelsius
        let displayTemparature = useCelsius ? temperature : Int(round((9.0 * Double(temperature))/5.0 + 32))
        return "\(displayTemparature)\u{00B0}"
    }
    
    // Gets the name of the weather image for a given weather condition.
    public static func selectWeatherImage(condition: WeatherDetails.WeatherCondition, day: Bool, glance: Bool = false) -> String {
        var imageName: String
        switch condition {
        case .Thunder:
            imageName = "Thunder"
            
        case .Drizzle, .LightRain, .Rain, .FreezingRain, .Showers:
            imageName = "Rain"
            
        case .HeavyRain:
            imageName = "HeavyRain"
            
        case .LightSnow, .Snow:
            imageName = "Snow"
            
        case .HeavySnow:
            imageName = "HeavySnow"
            
        case .Sleet:
            imageName = "Sleet"
            
        case .Mist, .Haze, .Fog:
            imageName = "Fog"
            
        case .Clear:
            imageName = day ? "Sun" : "Moon"
            
        case .FewClouds:
            imageName = day ? "FewClouds" : "MoonFewClouds"
            
        case .ScatteredClouds, .BrokenClouds:
            imageName = day ? "Clouds" : "MoonClouds"
            
        case .OvercastClouds:
            imageName = "Overcast"
            
        default:
            imageName = day ? "Clouds" : "MoonClouds"
        }
        return glance ? imageName + "Glance" : imageName
    }
}

