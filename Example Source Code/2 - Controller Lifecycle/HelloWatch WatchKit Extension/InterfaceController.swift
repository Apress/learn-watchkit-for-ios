//
//  InterfaceController.swift
//  HelloWatch WatchKit Extension
//
//  Created by Kim Topley on 1/11/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    override init() {
        super.init()
        NSLog("InterfaceController init() called")
        
        setTitle("Hi!")
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        NSLog("awakeWithContext() called with context \(context)")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        NSLog("willActivate() called")
        
        let device = WKInterfaceDevice.currentDevice()
        NSLog("Scale: \(device.screenScale)")
        NSLog("Screen bounds: \(device.screenBounds)")
        NSLog("Content frame: \(contentFrame)")
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        NSLog("didDeactivate() called")
    }

}
