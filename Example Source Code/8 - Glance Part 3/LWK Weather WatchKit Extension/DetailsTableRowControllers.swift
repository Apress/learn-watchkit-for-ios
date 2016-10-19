//
//  DetailsTableRowControllers.swift
//  LWKWeather
//
//  Created by Kim Topley on 6/6/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import Foundation
import WatchKit

// Table row that contains the date.
public class DateRowController : NSObject {
    @IBOutlet weak var dateLabel: WKInterfaceLabel!
}

// Table row that contains the weather details for
// part of a day.
public class DetailsRowController : NSObject {
    @IBOutlet weak var timeLabel: WKInterfaceLabel!
    @IBOutlet weak var tempLabel: WKInterfaceLabel!
    @IBOutlet weak var image: WKInterfaceImage!
}
