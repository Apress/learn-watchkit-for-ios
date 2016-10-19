//
//  InterfaceController.swift
//  ImageAnimation1 WatchKit Extension
//
//  Created by Kim Topley on 2/23/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var image: WKInterfaceImage!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        super.willActivate()
        
        image.startAnimating()
    }

    override func didDeactivate() {
        super.didDeactivate()
        
        image.stopAnimating()
    }

}
