//
//  InterfaceController.swift
//  ManualAnimation WatchKit Extension
//
//  Created by Kim Topley on 2/22/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var image: WKInterfaceImage!
    private var timer: NSTimer?
    private var size: CGFloat = 0.0
    private var expanding = true
    private let delta: CGFloat = 10

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        super.willActivate()
        
        size = delta
        image.setWidth(size)
        image.setHeight(size)
        expanding = true
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1,
            target: self, selector: "timerFired:",
            userInfo: nil, repeats: true)
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        timer?.invalidate()
        timer = nil
    }
    
    func timerFired(timer: NSTimer) -> Void {
        let maxSize: CGFloat = 120.0
        let delta: CGFloat = 10.0
        if (expanding) {
            if (size >= maxSize) {
                expanding = false
                size -= delta;
            } else {
                size += delta
            }
        } else {
            if (size <= delta) {
                expanding = true
                size += delta
            } else {
                size -= delta
            }
        }
        image.setWidth(size)
        image.setHeight(size)
    }
}
