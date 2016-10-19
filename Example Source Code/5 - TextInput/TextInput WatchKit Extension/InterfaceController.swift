//
//  InterfaceController.swift
//  TextInput WatchKit Extension
//
//  Created by Kim Topley on 4/14/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var label: WKInterfaceLabel!
    @IBOutlet weak var image: WKInterfaceImage!
    let suggestions = ["Hello, World", "Hello, Watch",
                       "To be or not to be, that is the question"]
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func onChangeTextButtonClicked() {
        presentTextInputControllerWithSuggestions(suggestions,
                        allowedInputMode: .AllowAnimatedEmoji,
                        completion: onTextInputComplete)
    }
    
    private func onTextInputComplete(results: [AnyObject]!) -> Void {
        if results != nil && !results.isEmpty {
            if let text = results[0] as? String {
                label.setText(text)
                image.setHidden(true)
                label.setHidden(false)
            } else if let data = results[0] as? NSData {
                let emojiImage = UIImage(data: data)
                image.setImage(emojiImage)
                image.setHidden(false)
                label.setHidden(true)
            }
        }
    }
}
