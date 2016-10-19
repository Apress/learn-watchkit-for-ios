//
//  ConfigurationController.swift
//  Configuration Table
//
//  Created by Kim Topley on 4/30/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation

class ConfigurationController: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!
    private var selectedColor: UIColor?
    private var selectedFont: UIFont?
    private var controllerContext: ControllerContext?
    
    class ControllerContext {
        let textAttributes: TextAttributes
        let callback: (TextAttributes) -> Void
        
        init(textAttributes: TextAttributes, callback: (TextAttributes) -> Void) {
            self.textAttributes = textAttributes
            self.callback = callback
        }
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        var rowTypes = [String]();
        
        // Color section
        rowTypes.append("Header")
        for _ in 0..<TextAttributes.colors.count {
            rowTypes.append("Body")
        }
        
        // Font section
        rowTypes.append("Header")
        for _ in 0..<TextAttributes.fonts.count {
            rowTypes.append("Body")
        }
        table.setRowTypes(rowTypes)
        
        var inColorSection = false
        var sectionStartIndex = -1
        for index in 0..<table.numberOfRows {
            let controller: AnyObject? = table.rowControllerAtIndex(index)
            if let header = controller as? HeaderRowController {
                inColorSection = index == 0;
                sectionStartIndex = index + 1;
                header.label.setText(inColorSection ? "Color" : "Font")
            } else if let body = controller as? BodyRowController {
                let rowInSectionIndex = index - sectionStartIndex
                switch inColorSection {
                case true:
                    let color = TextAttributes.colors[rowInSectionIndex]
                    body.attributeValue = color
                    body.label.setText(TextAttributes.colorNames[rowInSectionIndex])
                    body.label.setTextColor(color)
                    
                case false:
                    let font = TextAttributes.fonts[rowInSectionIndex]
                    body.attributeValue = font
                    let text = NSAttributedString(string: TextAttributes.fontNames[rowInSectionIndex],
                        attributes: [NSFontAttributeName: font])
                    body.label.setAttributedText(text)
                    
                default:
                    fatalError("Invalid index: \(index)")
                }
            }
        }
        
        // Install the selected color and font and update the
        // check marks in the table.
        if let controllerContext = context as? ControllerContext {
            self.controllerContext = controllerContext
            selectedColor = controllerContext.textAttributes.color
            selectedFont = controllerContext.textAttributes.font
            updateCheckMarks()
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func onSaveButtonClicked() {
        if selectedColor != nil && selectedFont != nil {
            let textAttributes = TextAttributes(color: selectedColor!, font: selectedFont!)
            controllerContext?.callback(textAttributes)
            dismissController()
        }
    }
    
    // Handling for row selection change
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let controller: AnyObject? = table.rowControllerAtIndex(rowIndex)
        if let body = controller as? BodyRowController {
            if let color = body.attributeValue as? UIColor {
                selectedColor = color
            } else if let font = body.attributeValue as? UIFont {
                selectedFont = font
            }
            updateCheckMarks()
        }
    }
    
    // Show or hide the check image for each body row.
    private func updateCheckMarks() {
        for index in 0..<table.numberOfRows {
            let controller: AnyObject? = table.rowControllerAtIndex(index)
            var match = false
            if let body = controller as? BodyRowController {
                if let color = body.attributeValue as? UIColor {
                    match = color == selectedColor
                } else if let font = body.attributeValue as? UIFont {
                    match = font == selectedFont
                }
                body.checkImage.setHidden(!match)
            }
        }
    }
}
