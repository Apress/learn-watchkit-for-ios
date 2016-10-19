//
//  TableRowControllers.swift
//  Configuration Table
//
//  Created by Kim Topley on 4/27/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit

class HeaderRowController : NSObject {
    @IBOutlet weak var label: WKInterfaceLabel!
}

class BodyRowController : NSObject {
    @IBOutlet weak var label: WKInterfaceLabel!
    @IBOutlet weak var checkImage: WKInterfaceImage!
    
    var attributeValue: AnyObject?
}
