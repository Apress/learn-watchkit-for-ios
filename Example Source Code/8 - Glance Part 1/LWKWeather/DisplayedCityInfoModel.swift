//
//  DisplayedCityInfoModel.swift
//  WeatherStuff
//
//  Created by Kim Topley on 12/22/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//
import Foundation

public class DisplayedCityInfoModel: DarwinNotificationObserver {
    // Holder for the shared instance of this model.
    private static var token: dispatch_once_t = 0
    private static var instance: DisplayedCityInfoModel?
    private static let userCitiesDefaultsKey = "displayedCityInfo"
    private static let useCelsiusDefaultsKey = "useCelsius"
    private static let inExtension: Bool = NSBundle.mainBundle().bundleIdentifier?.hasSuffix("watchkitextension") ?? false
    private static let darwinPath = "DisplayedCityInfoModel"
    
    // Access to user defaults.
    private let userDefaults = NSUserDefaults(suiteName: "group.com.apress.lwkweathertest")!
    
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
        if (DisplayedCityInfoModel.inExtension) {
            DarwinNotificationCenterBridge.addObserver(self, forName: DisplayedCityInfoModel.darwinPath)
        }
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
        if (!DisplayedCityInfoModel.inExtension) {
            userDefaults.setObject(displayedCities, forKey: DisplayedCityInfoModel.userCitiesDefaultsKey)
            userDefaults.synchronize()
        }
    }
    
    // Loads the use-celsius value from the user defaults.
    private func loadUseCelsius() {
        useCelsius = userDefaults.boolForKey(DisplayedCityInfoModel.useCelsiusDefaultsKey)
    }
    
    // Saves the useCelsius value to the user defaults.
    private func saveUseCelsius() {
        if (!DisplayedCityInfoModel.inExtension) {
            userDefaults.setBool(useCelsius, forKey: DisplayedCityInfoModel.useCelsiusDefaultsKey)
            userDefaults.synchronize()
        }
    }
    
    // Notifies the delegate of a change in the model. This call is
    // always made in the main thread.
    private func notifyDelegate() {
        delegate?.displayedCityInfoDidChange(self)
        if (!DisplayedCityInfoModel.inExtension) {
            // Notify extension across Darwin bridge
            DarwinNotificationCenterBridge.postNotificationForName(DisplayedCityInfoModel.darwinPath)
        }
    }
    
    // DarwinNotificationReceiver protocol conformance.
    // Handles notification of a change made in the iOS app.
    // Update the model state. As a side-effect, this will
    // notify the delegate if anything actually changes.
    @objc public func onNotificationReceived(name: String) {
        loadDisplayedCities()
        loadUseCelsius()
    }
}

public protocol DisplayedCityInfoModelDelegate: class {
    func displayedCityInfoDidChange(model: DisplayedCityInfoModel)
}