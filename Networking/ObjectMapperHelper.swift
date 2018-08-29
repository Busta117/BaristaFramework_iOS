//
//  ObjectMapperHelper.swift
//  Pods
//
//  Created by Santiago Bustamante on 9/16/16.
//
//

import UIKit
import ObjectMapper

open class BaristaISO8601DateTransform: TransformType {
    
    public typealias Object = Date
    public typealias JSON = String
    
    public let dateFormatter = DateFormatter()
    
    public init() {
//        let dateFormatter: DateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
//        super.init(dateFormatter: dateFormatter)
    }
    
    
    fileprivate func check(withFormat format:String, string dateStr:String)-> Date? {
        self.dateFormatter.dateFormat = format
        return self.dateFormatter.date(from:dateStr)
    }
    
    open func transformFromJSON(_ value: Any?) -> Date? {
        
        if let dateString = value as? String {
            
            if let date = check(withFormat: "yyyy-MM-dd'T'HH:mm:ss'Z'", string: dateString) {
                return date
            }else if let date = check(withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", string: dateString) {
                return date
            }else if let date = check(withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", string: dateString) {
                return date
            }else if let date = check(withFormat: "yyyy-MM-dd'T'HH:mm:ssZZZZZ", string: dateString) {
                return date
            }
            
        }
        return nil //super.transformFromJSON(value)
    }
    
    
    open func transformToJSON(_ value: Date?) -> String? {
        if let date = value {
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    
    
}
