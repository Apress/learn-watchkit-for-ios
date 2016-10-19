//
//  InterfaceController.swift
//  UpdatingTable WatchKit Extension
//
//  Created by Kim Topley on 5/3/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!
    private var nextRowNumber = 1
    private var nextInsertIndex: Int!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        table.setNumberOfRows(3, withRowType: "Row");
        for index in 0..<table.numberOfRows {
            initializeRow(index)
        }
        nextInsertIndex = table.numberOfRows
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func onNewRowButtonClicked() {
        table.insertRowsAtIndexes(NSIndexSet(index: nextInsertIndex), withRowType: "Row")
        initializeRow(nextInsertIndex)
        table.scrollToRowAtIndex(nextInsertIndex)
        nextInsertIndex = nextInsertIndex + 1
    }
    
    func rowDeleteClicked(rowController: RowController) {
        for index in 0..<table.numberOfRows {
            if let thisRow = table.rowControllerAtIndex(index) as? RowController {
                if thisRow == rowController {
                    nextInsertIndex =  index
                    table.removeRowsAtIndexes(NSIndexSet(index: index))
                    break
                }
            }
        }
    }
    
    private func initializeRow(rowIndex: Int) {
        let row = table.rowControllerAtIndex(rowIndex) as! RowController
        row.label.setText("\(nextRowNumber++)")
        row.controller = self
    }
}
