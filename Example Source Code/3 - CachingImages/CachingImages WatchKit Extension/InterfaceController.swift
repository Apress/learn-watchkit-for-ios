//
//  InterfaceController.swift
//  CachingImages WatchKit Extension
//
//  Created by Kim Topley on 2/25/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var image: WKInterfaceImage!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        let device = WKInterfaceDevice.currentDevice()
        let cacheKey = "CachedVeryLargeSun"
        if device.cachedImages[cacheKey] == nil {
            if let sunImage = UIImage(named: "VeryLargeSun") {
                if !device.addCachedImage(sunImage, name: cacheKey) {
                    println("Unable to add image to cache");
                }
            }
        }
        image?.setImageNamed(cacheKey)
        
        println(device.cachedImages)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
