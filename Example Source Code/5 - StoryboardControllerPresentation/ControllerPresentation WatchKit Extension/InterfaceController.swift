//
//  InterfaceController.swift
//  ControllerPresentation WatchKit Extension
//
//  Created by Kim Topley on 4/17/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

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
    
    override func contextsForSegueWithIdentifier(segueIdentifier: String) -> [AnyObject]? {
        return ["Presented Controller #1", "Presented Controller #2"]
    }
}
