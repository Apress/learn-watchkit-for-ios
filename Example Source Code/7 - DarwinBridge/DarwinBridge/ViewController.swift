//
//  ViewController.swift
//  DarwinBridge
//
//  Created by Kim Topley on 5/31/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import UIKit
import DarwinBridgeCode

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func onButtonClicked(sender: AnyObject) {
        DarwinNotificationCenterBridge.postNotificationForName("TestNotification")
    }
}

