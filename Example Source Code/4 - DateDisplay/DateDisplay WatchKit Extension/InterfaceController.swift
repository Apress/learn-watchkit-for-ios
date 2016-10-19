//
//  InterfaceController.swift
//  DateDisplay WatchKit Extension
//
//  Created by Kim Topley on 3/7/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var date: WKInterfaceDate!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        let timezone = NSTimeZone(abbreviation: "CST")
        date.setTimeZone(timezone)
        
        date.setCalendar(NSCalendar(identifier: NSCalendarIdentifierHebrew))
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
