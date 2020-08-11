//
//  CMBundle.swift
//  CMImageScrollView
//
//  Created by cm0630 on 2020/8/11.
//  Copyright © 2020 CM_iOS. All rights reserved.
//

import Foundation

class CMBundle {
    
    static let kBundle = "bundle"
    static let kFramework = "CMImageScrollView"
    static let kBundlePathForCarthage = "CMImageScrollView.framework"
    
    /// get current bundle
    static var bundle: Bundle? {
        let mainBundle = Bundle(for: CMBundle.self)
        let bundleURL = mainBundle.url(forResource: CMBundle.kFramework, withExtension: CMBundle.kBundle)
        
        //PodSpec (resource_bundles)
        if let bundleURL = bundleURL, let bundle = Bundle(url: bundleURL) {
            return bundle
        }
        
        //Carthage
        if mainBundle.bundlePath.contains(CMBundle.kBundlePathForCarthage){
            return mainBundle
        }
        
        return nil
    }
    
}
