//
//  ViewController.swift
//  Map
//
//  Created by Kim Topley on 3/14/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    private var locationMgr: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.locationServicesEnabled()
                && CLLocationManager.authorizationStatus() == .NotDetermined {
            locationMgr = CLLocationManager()
            locationMgr.delegate = self
            locationMgr.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(manager: CLLocationManager!,
            didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        println("Location manager auth status changed to \(status.rawValue)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

