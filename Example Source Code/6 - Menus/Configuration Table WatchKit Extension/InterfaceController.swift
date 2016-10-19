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
            updateLabelWithAttributes(textAttributes)
            attributesChanged = false;
        }
        super.willActivate()
    }
    
    private func updateLabelWithAttributes(attributes: TextAttributes) {
        let range = NSMakeRange(0, text.length)
        text.addAttribute(NSForegroundColorAttributeName,
                          value: attributes.color, range: range)
        text.addAttribute(NSFontAttributeName,
                          value: attributes.font, range: range)
        label.setAttributedText(text)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func onCallBack(textAttributes: TextAttributes) -> Void {
        if textAttributes.color != self.textAttributes.color
            || textAttributes.font != self.textAttributes.color {
                // Font or color changed
                self.textAttributes = textAttributes
                attributesChanged = true
        }
    }
    
    @IBAction func onConfigureClicked() {
        presentControllerWithName("Configuration",
                context: ConfigurationController.ControllerContext(
                            textAttributes: textAttributes,
                            callback: onCallBack))
    }
    
    @IBAction func onResetClicked() {
        let attributes = TextAttributes(color: TextAttributes.colors[0],
            font: TextAttributes.fonts[0])
        textAttributes = attributes  // set as the current attributes
        updateLabelWithAttributes(attributes)
    }
}
