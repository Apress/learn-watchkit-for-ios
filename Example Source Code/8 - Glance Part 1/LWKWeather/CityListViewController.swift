//
//  CityListViewController.swift
//  WeatherStuff
//
//  Created by Kim Topley on 12/22/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit
import SharedCode

class CityListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private static let cellFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    private static let cellColor = UIColor.whiteColor()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneButtonClicked(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UITableViewDataSource methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CityModel.sharedInstance().cities.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FullCityTableCell", forIndexPath: indexPath) as! UITableViewCell
        let city = CityModel.sharedInstance().cities[indexPath.row]
        cell.textLabel!.text = city.name
        cell.textLabel!.font = CityListViewController.cellFont
        cell.textLabel!.textColor = CityListViewController.cellColor
        
        // Check the cell if this city is currently displayed
        let displayed = find(DisplayedCityInfoModel.sharedInstance().displayedCities, city.cityCode) != nil
        cell.accessoryType = displayed ? .Checkmark : .None
        
        return cell
    }
    
    // MARK: UITableViewDelegate methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let city = CityModel.sharedInstance().cities[indexPath.row]
        var displayedList = DisplayedCityInfoModel.sharedInstance().displayedCities
        if let index = find(displayedList, city.cityCode) {
            // Currently displayed -- remove it from the displayed list, unless
            // there is only one city selected.
            if (displayedList.count > 1) {
                displayedList.removeAtIndex(index)
            }
        } else {
            // Not displayed -- add it to the displayed list.
            displayedList.append(city.cityCode)
        }
        DisplayedCityInfoModel.sharedInstance().displayedCities = displayedList
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
}
