//
//  InterfaceController.swift
//  Labels WatchKit Extension
//
//  Created by Kim Topley on 2/8/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var label: WKInterfaceLabel!
    private var formatter: NSDateFormatter
    
    override init() {
        formatter = NSDateFormatter()
        formatter.dateStyle = .NoStyle
        formatter.timeStyle = .ShortStyle
        super.init()
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
//        let timeString = formatter.stringFromDate(NSDate())
//        label.setText(timeString)
//        label.setTextColor(UIColor.yellowColor())

        let plainText: NSString = "Red text, Green text"
        let text = NSMutableAttributedString(string: plainText as String)
        
        let redRange = plainText.rangeOfString("Red")
        let greenRange = plainText.rangeOfString("Green")
        text.addAttribute(NSForegroundColorAttributeName,
                          value: UIColor.redColor(), range: redRange)
        text.addAttribute(NSForegroundColorAttributeName,
                          value: UIColor.greenColor(), range: greenRange)
        label.setAttributedText(text)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
