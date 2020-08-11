//
//  CMBundle.swift
//  CMImageScrollView
//
//  Created by cm0630 on 2020/8/11.
//  Copyright © 2020 CM_iOS. All rights reserved.
//

import Foundation

class CMCommunityBundle {
    
    static let kBundle = "bundle"
    static let kFramework = "CMCommunityModel"
    static let kBundlePathForCarthage = "CMCommunityModel.framework"
    
    /// get current bundle
    static var bundle: Bundle? {
        let mainBundle = Bundle(for: CMCommunityBundle.self)
        let bundleURL = mainBundle.url(forResource: CMCommunityBundle.kFramework, withExtension: CMCommunityBundle.kBundle)
        
        //PodSpec (resource_bundles)
        if let bundleURL = bundleURL, let bundle = Bundle(url: bundleURL) {
            return bundle
        }
        
        //Carthage
        if mainBundle.bundlePath.contains(CMCommunityBundle.kBundlePathForCarthage){
            return mainBundle
        }
        
        return nil
    }
    
}
