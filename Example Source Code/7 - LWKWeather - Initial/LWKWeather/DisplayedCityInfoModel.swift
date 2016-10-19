//
//  DisplayedCityInfoModel.swift
//  WeatherStuff
//
//  Created by Kim Topley on 12/22/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//
import Foundation

public class DisplayedCityInfoModel {
    // Holder for the shared instance of this model.
    private static var token: dispatch_once_t = 0
    private static var instance: DisplayedCityInfoModel?
    private static let userCitiesDefaultsKey = "displayedCityInfo"
    private static let useCelsiusDefaultsKey = "useCelsius"
    
    // Access to user defaults.
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    // The delegate for this model.
    public weak var delegate: DisplayedCityInfoModelDelegate?
    
    // City codes for the cities that are displayed.
    public var displayedCities: [Int] = [] {
        willSet {
            // Can only set in the main thread.
            assert(NSThread.isMainThread())
        }
        
        didSet {
            // New value set: save the updated list and
            // notify delegate.
            if (displayedCities != oldValue) {
                saveDisplayedCities()
                notifyDelegate()
            }
        }
    }
    
    // Whether to display temperatures in celsius
    public var useCelsius: Bool = false {
        didSet {
            // Notify delegate of a change and save the updated
            // value to user defaults.
            if (useCelsius != oldValue) {
                saveUseCelsius()
                notifyDelegate()
            }
        }
    }
    
    // Gets the shared instance of this model.
    public class func sharedInstance() -> DisplayedCityInfoModel {
        dispatch_once(&token) {
            self.instance = DisplayedCityInfoModel()
        }
        return instance!
    }
    
    // Private initializer. Initializes the displayed cities
    // and use celsius properties from user defaults or to default values.
    private init() {
        loadDisplayedCities()
        loadUseCelsius()
    }
    
    // Loads the displayed cities from the user defaults or
    // installs a default set of cities.
    public func loadDisplayedCities() {
        var savedCities = userDefaults.arrayForKey(DisplayedCityInfoModel.userCitiesDefaultsKey) as? [Int]
        if (savedCities == nil) {
            savedCities = [5128581, 4887398, 2147714] // default to New York, Chicago, Sydney
        }
        displayedCities.replaceRange(0..<displayedCities.count, with: savedCities!)
    }
    
    // Saves the updated displayed cities to the user defaults.
    private func saveDisplayedCities() {
        userDefaults.setObject(displayedCities, forKey: DisplayedCityInfoModel.userCitiesDefaultsKey)
    }
    
    // Loads the use-celsius value from the user defaults.
    private func loadUseCelsius() {
        useCelsius = userDefaults.boolForKey(DisplayedCityInfoModel.useCelsiusDefaultsKey)
    }
    
    // Saves the useCelsius value to the user defaults.
    private func saveUseCelsius() {
        userDefaults.setBool(useCelsius, forKey: DisplayedCityInfoModel.useCelsiusDefaultsKey)
    }
    
    // Notifies the delegate of a change in the model. This call is
    // always made in the main thread.
    private func notifyDelegate() {
        delegate?.displayedCityInfoDidChange(self)
    }
}

public protocol DisplayedCityInfoModelDelegate: class {
    func displayedCityInfoDidChange(model: DisplayedCityInfoModel)
}