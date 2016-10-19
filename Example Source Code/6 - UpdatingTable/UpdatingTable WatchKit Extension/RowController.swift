//
//  RowController.swift
//  UpdatingTable
//
//  Created by Kim Topley on 5/3/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit

class RowController: NSObject {
    var controller: InterfaceController?
    @IBOutlet weak var label: WKInterfaceLabel!

    @IBAction func onDeleteButtonClicked() {
        controller?.rowDeleteClicked(self)
    }
}
