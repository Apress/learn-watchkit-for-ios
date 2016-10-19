//
//  InterfaceController.swift
//  Sliders WatchKit Extension
//
//  Created by Kim Topley on 3/5/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var slider: WKInterfaceSlider!
    @IBOutlet weak var `switch`: WKInterfaceSwitch!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func onSliderValueChanged(value: Float) {
        println("Slider value is \(value)")
        `switch`.setOn(value < 2)
    }
    
    @IBAction func onSwitchValueChanged(value: Bool) {
        println("Switch value is \(value)")
        slider.setEnabled(value)
    }
}
