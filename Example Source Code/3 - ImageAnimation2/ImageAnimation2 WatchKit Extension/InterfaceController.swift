//
//  InterfaceController.swift
//  ImageAnimation2 WatchKit Extension
//
//  Created by Kim Topley on 2/25/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var image: WKInterfaceImage!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
//        let device = WKInterfaceDevice.currentDevice()
//        for i in 0...11 {
//            if let image = UIImage(named: "sun\(i).png") {
//                device.addCachedImage(image, name: "sun\(i)")
//            }
//        }
//        println(device.cachedImages)
//        
//        image.setImageNamed("sun")
//        image.startAnimating()
        
        let device = WKInterfaceDevice.currentDevice()
        let cacheKey = "AnimatedSun"
        if device.cachedImages[cacheKey] == nil {
            var images = Array<UIImage>()
            for i in 0...11 {
                if let image = UIImage(named: "sun\(i).png") {
                    images.append(image)
                }
            }
            let animatedImage = UIImage.animatedImageWithImages(images, duration: 1.0)
            device.addCachedImage(animatedImage, name: cacheKey)
        }
        
        image.setImageNamed(cacheKey)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        image.startAnimating()
        //image.startAnimatingWithImagesInRange(NSMakeRange(0, 6), duration: 5, repeatCount: 2)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        image.stopAnimating()
    }

}
