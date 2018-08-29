//
//  ObjectMapperRealmHelper.swift
//  Pods
//
//  Created by Santiago Bustamante on 10/13/16.
//
//

import ObjectMapper
import RealmSwift

//transform array from objectMapper parsing to Realm List
public class ArrayTransform<T:RealmSwift.Object where T:Mappable> : TransformType {
    public typealias Object = List<T>
    public typealias JSON = Array<Any>
    
    public init(){
    }
    
    public func transformFromJSON(_ value: Any?) -> List<T>? {
        let result = List<T>()
        if let tempArr = value as? Array<Any> {
            for entry in tempArr {
                let mapper = Mapper<T>()
                let model : T = mapper.map(JSONObject: entry)!
                result.append(model)
            }
        }
        return result
    }
    
    public func transformToJSON(_ value: List<T>?) -> Array<Any>? {
        if let value = value, value.count > 0
        {
            var result = Array<Any>()
            
            for entry in value {
                let mapped = Mapper().toJSON(entry)
                result.append(mapped)
            }
            return result
        }
        return nil
    }
}
