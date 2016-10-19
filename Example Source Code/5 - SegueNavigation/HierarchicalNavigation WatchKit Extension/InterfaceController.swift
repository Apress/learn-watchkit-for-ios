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
    
    override func contextForSegueWithIdentifier(segueIdent: String) -> AnyObject? {
        labelText = "Neither liked nor disliked"
        var imageName: String!
        var title: String!
        
        switch segueIdent {
        case "Image1":
            imageName = "image1"
            title = "Image 1"
            
        case "Image2":
            imageName = "image2"
            title = "Image 2"
            
        default:
            println("Invalid segue ideintifier: \(segueIdent)")
            abort()
        }
        
        let context = ImageController.ImageControllerContext(imageName: imageName,
            title: title, callback: { (liked) in
                self.labelText = liked ? "Liked \(title)" : "Disliked \(title)"
        })
        return context
    }
}
