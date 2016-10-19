//
//  InterfaceController.swift
//  Configuration Table WatchKit Extension
//
//  Created by Kim Topley on 4/24/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var label: WKInterfaceLabel!
    
    private var textAttributes =
                TextAttributes(color: TextAttributes.colors[0],
                               font: TextAttributes.fonts[0])
    private var attributesChanged = true
    private var text = NSMutableAttributedString(string: "Hello, Watch")

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        if attributesChanged {
            let range = NSMakeRange(0, text.length)
            text.addAttribute(NSForegroundColorAttributeName,
                value: textAttributes.color, range: range)
            text.addAttribute(NSFontAttributeName,
                value: textAttributes.font, range: range)
            label.setAttributedText(text)
            attributesChanged = false;
        }
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
        return ConfigurationController.ControllerContext(
                 textAttributes: textAttributes,
                 callback: onCallBack)
    }
    
    func onCallBack(textAttributes: TextAttributes) -> Void {
        if textAttributes.color != self.textAttributes.color
            || textAttributes.font != self.textAttributes.color {
                // Font or color changed
                self.textAttributes = textAttributes
                attributesChanged = true
        }
    }
}
