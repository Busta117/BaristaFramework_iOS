//
//  UIApplication+BuildVersion.swift
//  Wapa_Customer_iOS
//
//  Created by Daniel Gomez Rico on 7/13/15.
//  Copyright © 2015 Barista Ventures. All rights reserved.
//

// http://stackoverflow.com/a/7608711/273119
public extension UIApplication {
    
    public class func  appVersion() -> String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    public class func appBuild() -> String {
        return Bundle.main.infoDictionary![kCFBundleVersionKey as String] as! String
    }
    
    public class func appId() -> String {
        return Bundle.main.infoDictionary![kCFBundleIdentifierKey as String] as! String
    }
    
    
    public class var ´version´: String {
        return self.appVersion()
    }
    
    public class var build: String {
        return self.appBuild()
    }
    
    public class var bundle: String {
        return self.appId()
    }
    
    
}
