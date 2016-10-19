//
//  InterfaceController.swift
//  DynamicPageNavigation WatchKit Extension
//
//  Created by Kim Topley on 3/30/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    private let pageCount = 5
    @IBOutlet weak var startLabel: WKInterfaceLabel!
    @IBOutlet weak var summaryLabel: WKInterfaceLabel!
    private var model: SharedModel!
    private var firstActivation = true
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        if context == nil {
            // This case is application launch
            model = SharedModel(pageCount: pageCount)
            
            var identifiers = ["MainController"]
            var contexts = [ControllerContext(model: model, pageIndex: 0)]
            
            for pageNumber in 1...pageCount {
                identifiers.append("ImageController")
                contexts.append(ControllerContext(model: model, pageIndex: pageNumber))
            }
            
            WKInterfaceController.reloadRootControllersWithNames(identifiers, contexts: contexts)
        } else {
            // Created by reloadRootControllersWithNames(_:contexts:)
            let controllerContext = context as! ControllerContext
            model = controllerContext.model
            model.controllers[0] = self
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        
        if (firstActivation) {
            firstActivation = false
        } else {
            startLabel.setHidden(true)
            summaryLabel.setHidden(false)
            let likedImageCount = model.likedImageCount;
            let dislikedImageCount = model.dislikedImageCount
            let noCommentImageCount = pageCount - likedImageCount - dislikedImageCount
            summaryLabel.setText(
                "Likes: \(likedImageCount)\n"
                    + "Dislikes: \(dislikedImageCount)\n"
                    + "No comment: \(noCommentImageCount)")
        }

    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
