//
//  Array.swift
//
//
//  Created by Santiago Bustamante on 5/11/17.
//
//

import UIKit

public extension Array{
    
    public func toDictionary( transformer: @escaping (_ element: Element) -> (key: AnyHashable, value: Any)?) -> Dictionary<AnyHashable, Any>
    {
        return (self).reduce([:]) { (dict, e) in
            var dict = dict
            if let (key, value) = transformer(e)
            {
                dict[key] = value
            }
            return dict
        }
    }
    
}
