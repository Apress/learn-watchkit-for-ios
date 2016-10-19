//
//  InterfaceController.swift
//  LWK Weather WatchKit Extension
//
//  Created by Kim Topley on 6/1/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation
import SharedCode

class InterfaceController: WKInterfaceController {
    var delegate: DisplayedCityInfoModelDelegate?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        let model = DisplayedCityInfoModel.sharedInstance()
        println(model.displayedCities)
        
        class ModelDelegate: DisplayedCityInfoModelDelegate {
            func displayedCityInfoDidChange(model: DisplayedCityInfoModel) {
                println("Displayed cities: \(model.displayedCities)")
                println("Use celsius: \(model.useCelsius)")
            }
        }
        delegate = ModelDelegate()
        model.delegate = delegate
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
