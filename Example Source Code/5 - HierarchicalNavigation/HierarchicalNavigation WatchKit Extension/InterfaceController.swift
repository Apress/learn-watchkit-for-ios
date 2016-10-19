//
//  InterfaceController.swift
//  HierarchicalNavigation WatchKit Extension
//
//  Created by Kim Topley on 3/17/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var label: WKInterfaceLabel!
    var labelText: String?

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        super.willActivate()
        println("InterfaceController willActivate() called")
        if labelText != nil {
            label.setText(labelText!)
            labelText = nil
        }
    }

    override func didDeactivate() {
        super.didDeactivate()
        println("InterfaceController didDeactivate() called")
    }

    @IBAction func onImage1ButtonClicked() {
        pushImageControllerWithImageName("image1", title: "Image 1")
    }
    
    @IBAction func onImage2ButtonClicked() {
        pushImageControllerWithImageName("image2", title: "Image 2")
    }
    
    private func pushImageControllerWithImageName(imageName: String, title: String) {
        let context = ImageController.ImageControllerContext(imageName: imageName,
            title: title, callback: { (liked) in
                self.labelText = liked ? "Liked \(title)" : "Disliked \(title)"
            })
        labelText = "Neither liked nor disliked"
        pushControllerWithName("ImageController", context: context)
    }
}
