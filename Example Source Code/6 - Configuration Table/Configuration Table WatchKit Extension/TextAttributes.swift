//
//  TextAttributes.swift
//  Configuration Table
//
//  Created by Kim Topley on 4/30/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import UIKit

struct TextAttributes {
    static let colorNames = ["White", "Yellow", "Green"]
    static let colors = [UIColor.whiteColor(), UIColor.yellowColor(), UIColor.greenColor()]
    static let fontNames = ["Body", "Headline", "Footnote"]
    static let fonts = [
        UIFont.preferredFontForTextStyle(UIFontTextStyleBody),
        UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline),
        UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
    ]
    
    let color: UIColor
    let font: UIFont
}
