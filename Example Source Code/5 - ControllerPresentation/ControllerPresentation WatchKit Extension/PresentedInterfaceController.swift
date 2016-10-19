//
//  PresentedInterfaceController.swift
//  ControllerPresentation
//
//  Created by Kim Topley on 4/17/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class PresentedInterfaceController: WKInterfaceController {
    @IBOutlet weak var label: WKInterfaceLabel!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        let text = context! as! String
        label.setText(text)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func onCloseButtonClicked() {
        dismissController()
    }
}
