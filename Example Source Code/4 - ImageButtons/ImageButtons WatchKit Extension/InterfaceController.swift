//
//  InterfaceController.swift
//  ImageButtons WatchKit Extension
//
//  Created by Kim Topley on 3/1/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var group1: WKInterfaceGroup!
    @IBOutlet weak var group2: WKInterfaceGroup!
    @IBOutlet weak var group3: WKInterfaceGroup!
    @IBOutlet weak var group4: WKInterfaceGroup!
    lazy var groups: [WKInterfaceGroup] = [self.group1, self.group2, self.group3, self.group4]
    
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

    @IBAction func button1Clicked() {
        hideButton(0)
    }
    
    @IBAction func button2Clicked() {
        hideButton(1)
    }
    
    @IBAction func button3Clicked() {
        hideButton(2)
    }

    @IBAction func button4Clicked() {
        hideButton(3)
    }
    
    private func hideButton(index: Int) -> Void {
        for i in 0..<groups.count {
            groups[i].setAlpha(i == index ? 0 : 1)
        }
    }
}
