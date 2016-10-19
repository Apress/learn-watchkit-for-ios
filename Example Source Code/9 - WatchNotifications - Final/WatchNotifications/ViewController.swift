//
//  ViewController.swift
//  WatchNotifications
//
//  Created by Kim Topley on 6/15/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var typeSelector: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onButtonClicked(sender: AnyObject) {
        let notification = UILocalNotification()
        notification.fireDate = NSDate().dateByAddingTimeInterval(5)
        notification.alertTitle = "Alert!"
        notification.alertBody = "It's Sunny!"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.hasAction = true
        notification.alertAction = "Do Something"
        notification.category = "BasicActions"
        if typeSelector.selectedSegmentIndex == 1 {
            // Dynamic interface selected
            notification.userInfo = [
                "cityLabel": "New York",
                "tempLabel": "82\u{00B0}"
            ]
        }
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}

