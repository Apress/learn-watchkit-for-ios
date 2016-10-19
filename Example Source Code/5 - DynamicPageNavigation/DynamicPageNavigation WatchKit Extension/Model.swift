//
//  Model.swift
//  DynamicPageNavigation
//
//  Created by Kim Topley on 4/7/15.
//  Copyright (c) 2015 Apress. All rights reserved.
//

import Foundation
import WatchKit

class SharedModel {
    var controllers: [WKInterfaceController?]
    private var likedImages = Set<Int>()
    private var dislikedImages = Set<Int>()
    var likedImageCount: Int {
        get {
            return likedImages.count
        }
    }
    var dislikedImageCount: Int {
        get {
            return dislikedImages.count
        }
    }
    
    init(pageCount: Int) {
        controllers = Array<WKInterfaceController?>(count: pageCount + 1, repeatedValue: nil)
    }
    
    func likeImage(pageIndex: Int) {
        likedImages.insert(pageIndex)
        dislikedImages.remove(pageIndex)
    }
    
    func dislikeImage(pageIndex: Int) {
        dislikedImages.insert(pageIndex)
        likedImages.remove(pageIndex)
    }
}

class ControllerContext {
    let model: SharedModel
    let pageIndex: Int
    
    init(model: SharedModel, pageIndex: Int) {
        self.model = model
        self.pageIndex = pageIndex
    }
}
