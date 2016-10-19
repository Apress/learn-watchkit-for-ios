//
//  ImageController.swift
//  DynamicPageNavigation
//
//  Created by Kim Topley on 4/4/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class ImageController: WKInterfaceController {
    private var controllerContext: ControllerContext!
    @IBOutlet weak var image: WKInterfaceImage!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        controllerContext = context! as! ControllerContext
        let pageIndex = controllerContext.pageIndex
        controllerContext.model.controllers[pageIndex] = self
        
        setTitle("Page \(pageIndex)")
        image.setImageNamed("image\(pageIndex)")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func onLikeButtonClicked() {
        controllerContext.model.likeImage(controllerContext.pageIndex)
        moveToNextPage()
    }
    
    @IBAction func onDislikeButtonClicked() {
        controllerContext.model.dislikeImage(controllerContext.pageIndex)
        moveToNextPage()
    }
    
    func moveToNextPage() {
        let pageIndex = controllerContext.pageIndex
        let totalPages = controllerContext.model.controllers.count
        let nextIndex = (pageIndex + 1) % totalPages
        let nextController = controllerContext.model.controllers[nextIndex]!
        nextController.becomeCurrentPage()
    }
}
