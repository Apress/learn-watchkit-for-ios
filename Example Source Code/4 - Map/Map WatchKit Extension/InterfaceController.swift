//
//  InterfaceController.swift
//  Map WatchKit Extension
//
//  Created by Kim Topley on 3/14/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation
import MapKit

class InterfaceController: WKInterfaceController, CLLocationManagerDelegate {
    private var locationMgr: CLLocationManager!
    @IBOutlet weak var map: WKInterfaceMap!
    private var coords: CLLocationCoordinate2D!
    private var lastCoords: CLLocationCoordinate2D!
    private var scaleFactor = 1.0

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
//        coords = CLLocationCoordinate2DMake(37.33233141,-122.03121860)
//        map.addAnnotation(coords, withPinColor: .Green)
        locationMgr = CLLocationManager()
        locationMgr.delegate = self
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        //updateMap()
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            locationMgr.startUpdatingLocation()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        locationMgr.stopUpdatingLocation()
    }

    @IBAction func onSliderValueChanged(value: Float) {
        scaleFactor = pow(2, Double(value))
        updateMap()
    }
    
    func updateMap() -> Void {
        if coords != nil {
            let areaSize = 1 / scaleFactor
            let region = MKCoordinateRegionMake(coords!, MKCoordinateSpanMake(areaSize, areaSize))
            map.setRegion(region)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations[locations.count - 1] as? CLLocation {
            lastCoords = coords
            coords = location.coordinate
            if coords != nil && (lastCoords == nil
                    || coords?.latitude != lastCoords?.latitude
                    || coords?.longitude != lastCoords?.longitude) {
                updateMap()
            }
        }
    }
}
