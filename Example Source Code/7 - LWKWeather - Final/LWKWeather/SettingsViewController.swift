//
//  SettingsViewController.swift
//  WeatherStuff
//
//  Created by Kim Topley on 12/22/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit
import SharedCode

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private static let cellFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    private static let cellColor = UIColor.whiteColor()
    
    @IBOutlet weak var temperatureControl: UISegmentedControl!
    @IBOutlet weak var displayedCitiesTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let useCelsius = DisplayedCityInfoModel.sharedInstance().useCelsius
        temperatureControl.selectedSegmentIndex = useCelsius ? 0 : 1
        displayedCitiesTable.setEditing(true, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        displayedCitiesTable.reloadData()
    }

    @IBAction func doneButtonClicked(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func temperatureControlChanged(sender: UISegmentedControl) {
        let useCelsius = sender.selectedSegmentIndex == 0
        DisplayedCityInfoModel.sharedInstance().useCelsius = useCelsius
    }
    
    // MARK: UITableViewDataSource methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DisplayedCityInfoModel.sharedInstance().displayedCities.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CityTableCell", forIndexPath: indexPath) as! UITableViewCell
        let cityCode = DisplayedCityInfoModel.sharedInstance().displayedCities[indexPath.row]
        let city = CityModel.sharedInstance().cityForCode(cityCode)
        cell.textLabel!.text = city?.name ?? "Unknown"
        cell.textLabel!.font = SettingsViewController.cellFont
        cell.textLabel!.textColor = SettingsViewController.cellColor
        cell.showsReorderControl = true
        
        return cell
    }
    
    // MARK: UITableViewDelegate methods
    
    // Hide the delete control, leaving only the reordering control
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
    
    // Do not indent, since we are not showing the edit control
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    // Called when rows are rearranged -- reflect the change in the displayed cities model.
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        var displayedCities = DisplayedCityInfoModel.sharedInstance().displayedCities
        let fromRow = sourceIndexPath.row
        let toRow = destinationIndexPath.row
        
        let fromCityCode = displayedCities.removeAtIndex(fromRow)
        displayedCities.insert(fromCityCode, atIndex: toRow)
        DisplayedCityInfoModel.sharedInstance().displayedCities = displayedCities
    }
}
