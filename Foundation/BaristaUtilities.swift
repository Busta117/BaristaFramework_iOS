//
//  NullUtilities.swift
//  Wapa_Customer_iOS
//
//  Created by Santiago Bustamante on 6/22/15.
//  Copyright © 2015 Barista Ventures. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

//clamp is a function to set a min value and max value, so, the evaluated value never cross those limits
public func clamp<T : Comparable>(value: T, minValue: T, maxValue: T) -> T{
    return min(maxValue, max(minValue, value))
}

open class BaristaUtilities: NSObject {
	

	open class func setupNetworking(withBaseURL baseURL: String){
        BaristaNetwork.default.setupNetwork(withBaseURL:baseURL)
	}
    

}


public func delay(_ delay:Double, closure:@escaping ()->Void) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}
