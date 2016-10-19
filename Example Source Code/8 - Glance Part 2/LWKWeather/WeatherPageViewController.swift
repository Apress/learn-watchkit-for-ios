//
//  WeatherPageViewController.swift
//  WeatherStuff
//
//  Created by Kim Topley on 12/18/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit
import SharedCode

class WeatherPageViewController: UIPageViewController, UIPageViewControllerDataSource, DisplayedCityInfoModelDelegate {
    private var displayedCities: [Int] = []
    private var controllersByCity: [Int : CityWeatherViewController] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 0.176, green: 0.416, blue: 0.478, alpha: 1.0)
        
        dataSource = self
        let displayedCityModel = DisplayedCityInfoModel.sharedInstance()
        displayedCities = DisplayedCityInfoModel.sharedInstance().displayedCities
        displayedCityModel.delegate = self
        AppWeatherModel.sharedInstance().fetchWeatherForCities(displayedCities, always: false)

        let firstController = weatherControllerFor(cityCode: displayedCities[0])
        setViewControllers([firstController], direction: .Forward, animated: false, completion: nil)
        
        UIPageControl.appearance().backgroundColor = UIColor.clearColor()
    }
    
    func displayedCityInfoDidChange(model: DisplayedCityInfoModel) {
        // Get the new list of cities, work out which ones have been removed
        // (if any) and remove their view controllers from controllersByCity.
        let oldDisplayedCities = displayedCities
        displayedCities = DisplayedCityInfoModel.sharedInstance().displayedCities
        let citiesRemoved = oldDisplayedCities.filter({find(self.displayedCities, $0) == nil})
        for cityCode in citiesRemoved {
            controllersByCity.removeValueForKey(cityCode)
        }
        
        AppWeatherModel.sharedInstance().fetchWeatherForCities(displayedCities, always: false)
        
        let currentViewController = viewControllers[0] as! CityWeatherViewController
        var newIndex = find(displayedCities, currentViewController.cityCode)
        if (newIndex == nil) {
            // The currently displayed city has been removed. Reassign the current view controller
            // to the new first city.
            currentViewController.cityCode = displayedCities[0]
        }
        setViewControllers([currentViewController], direction: .Forward, animated: false, completion: nil)
    }
    
    // MARK: UIPageViewControllerDataSource methods
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let controller = viewController as! CityWeatherViewController
        let index = find(displayedCities, controller.cityCode)!
        return index > 0 ? weatherControllerFor(cityCode: displayedCities[index - 1]) : nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let controller = viewController as! CityWeatherViewController
        let index = find(displayedCities, controller.cityCode)!
        return index < displayedCities.count - 1 ? weatherControllerFor(cityCode: displayedCities[index + 1]) : nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return DisplayedCityInfoModel.sharedInstance().displayedCities.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        let cityCode = (pageViewController as! WeatherPageViewController).cityCodeOfCurrentPage()
        return find(displayedCities, cityCode)!
    }
    
    // MARK: Helper Methods
    private func weatherControllerFor(#cityCode: Int) -> CityWeatherViewController {
        var controller = controllersByCity[cityCode]
        if controller == nil {
            let newController = storyboard?.instantiateViewControllerWithIdentifier("CityWeatherViewController") as! CityWeatherViewController
            newController.cityCode = cityCode
            controllersByCity[cityCode] = newController
            controller = newController
        }
         return controller!
    }
    
    private func cityCodeOfCurrentPage() -> Int {
        return (viewControllers[0] as! CityWeatherViewController).cityCode
    }
}
