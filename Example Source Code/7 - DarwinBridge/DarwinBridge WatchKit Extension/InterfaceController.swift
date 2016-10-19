//
//  InterfaceController.swift
//  DarwinBridge WatchKit Extension
//
//  Created by Kim Topley on 5/31/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation
import DarwinBridgeCode

class InterfaceController: WKInterfaceController, DarwinNotificationObserver {
    @IBOutlet weak var label: WKInterfaceLabel!

    func onNotificationReceived(name: String!) {
        label.setText("Received notification")
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        DarwinNotificationCenterBridge.addObserver(self, forName: "TestNotification")
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        DarwinNotificationCenterBridge.removeObserver(self, forName: "TestNotification")
    }

    @IBAction func onButtonClicked() {
        label.setText("No Message")
    }
}
