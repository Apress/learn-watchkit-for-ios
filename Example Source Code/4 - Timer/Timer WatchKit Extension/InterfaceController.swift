//
//  InterfaceController.swift
//  Timer WatchKit Extension
//
//  Created by Kim Topley on 3/10/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var timer: WKInterfaceTimer!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        timer.setDate(NSDate(timeIntervalSinceNow: -120))
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func onStart() {
        timer.start()
    }
    
    @IBAction func onStop() {
        timer.stop()
    }
    
    @IBAction func onReset() {
        timer.setDate(NSDate(timeIntervalSinceNow: -120))
    }
}
