//
//  ImageController.swift
//  HierarchicalNavigation
//
//  Created by Kim Topley on 3/17/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class ImageController: WKInterfaceController {
    class ImageControllerContext {
        let imageName: String
        let title: String
        let callback: (liked: Bool) -> Void
        
        init(imageName: String, title: String, callback: (liked: Bool) -> Void) {
            self.imageName = imageName
            self.title = title
            self.callback = callback
        }
    }
    var context: ImageControllerContext?
    @IBOutlet weak var image: WKInterfaceImage!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        println("ImageController awakeWithContext() called: \(context)")
        
        if let contextStructure = context as? ImageControllerContext {
            self.context = contextStructure
            setTitle(contextStructure.title)
            image.setImageNamed(contextStructure.imageName)
        }
    }

    override func willActivate() {
        super.willActivate()
        println("ImageController willActivate() called")
    }

    override func didDeactivate() {
        super.didDeactivate()
        println("ImageController didDeactivate() called")
    }

    @IBAction func onLikeButtonClicked() {
        context?.callback(liked: true)
        popController()
    }
    
    @IBAction func onDislikeButtonClicked() {
        context?.callback(liked: false)
        popController()
    }
}
