//
//  InterfaceController.swift
//  Buttons WatchKit Extension
//
//  Created by Kim Topley on 2/28/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var button1: WKInterfaceButton!
    @IBOutlet weak var button2: WKInterfaceButton!
    var button1Enabled = true

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

    @IBAction func buttonClicked() {
        println("Button clicked")
    }
    
    @IBAction func button2Clicked() {
        button1Enabled = !button1Enabled
        button1.setEnabled(button1Enabled)
        button2.setTitle(button1Enabled ? "Disable Button 1"
                                        : "Enable Button 1")
    }
}
