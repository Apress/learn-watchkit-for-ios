//
//  InterfaceController.swift
//  Fonts WatchKit Extension
//
//  Created by Kim Topley on 2/12/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var label1: WKInterfaceLabel!
    @IBOutlet weak var label2: WKInterfaceLabel!
    @IBOutlet weak var label3: WKInterfaceLabel!
    @IBOutlet weak var label4: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        let headlineFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        let footnoteFont = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        let text1 = NSMutableAttributedString(string: "Tangerine Bold")
        text1.addAttribute(NSFontAttributeName, value: headlineFont, range: NSMakeRange(0, 3))
        text1.addAttribute(NSFontAttributeName, value: footnoteFont, range: NSMakeRange(3, 3))
        label1.setAttributedText(text1)
        
        let regularFont = UIFont.systemFontOfSize(24)
        let heavyFont = UIFont.systemFontOfSize(24, weight: UIFontWeightHeavy)
        let text2 = NSMutableAttributedString(string: "Tangerine Regular")
        text2.addAttribute(NSFontAttributeName, value: regularFont, range: NSMakeRange(0, 3))
        text2.addAttribute(NSFontAttributeName, value: heavyFont, range: NSMakeRange(3, 3))
        label2.setAttributedText(text2)
        
        let text3 = NSMutableAttributedString(string: "Tangerine Bold (Code)")
        if let tangerineBoldFont = UIFont(name: "Tangerine-Bold", size: 20) {
            text3.addAttribute(NSFontAttributeName, value: tangerineBoldFont, range: NSMakeRange(0, 21))
        }
        label3.setAttributedText(text3)
        
        let desc = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
 //       let bodyFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
 //       let desc = bodyFont.fontDescriptor()
        let italicBoldDesc = desc.fontDescriptorWithSymbolicTraits(.TraitItalic | .TraitBold)
        let italicBoldBody = UIFont(descriptor: italicBoldDesc!, size: 0)
        let text4 = NSAttributedString(string: "Italic Bold Body",
                                       attributes: [NSFontAttributeName: italicBoldBody])
        label4.setAttributedText(text4)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
