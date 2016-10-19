//
//  InterfaceController.swift
//  Messaging WatchKit Extension
//
//  Created by Kim Topley on 5/30/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var label: WKInterfaceLabel!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        println("will activate")
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        println("Deactivated")
        super.didDeactivate()
    }

    @IBAction func onButtonClicked() {
        let userInfo = ["time" : NSDate()]
        let result = WKInterfaceController.openParentApplication(userInfo,
            reply: { (response, error) in
                if let error = error {
                    self.label.setText("Error: \(error)")
                    println("\(error)")
                } else if let time: NSDate = response["time"] as? NSDate {
                    self.label.setText("\(time)")
                } else {
                    self.label.setText("No time received")
                }
            }
        )
        println("Result = \(result)")
    }
}
