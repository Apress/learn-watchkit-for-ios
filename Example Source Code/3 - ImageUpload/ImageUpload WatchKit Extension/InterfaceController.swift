//
//  InterfaceController.swift
//  ImageUpload WatchKit Extension
//
//  Created by Kim Topley on 2/24/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var image: WKInterfaceImage!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
//      let sunImage = UIImage(named: "VeryLargeSun")
//      image?.setImage(sunImage)
        
        if let url = NSBundle.mainBundle().URLForResource("SmallSun@2x", withExtension: "png") {
            let data = NSData(contentsOfURL: url)
            image?.setImageData(data)
        }
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
