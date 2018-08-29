//
//  BVError.swift
//  Pods
//
//  Created by Santiago Bustamante on 9/16/16.
//
//

import UIKit
import Alamofire

public struct BVError:Error {

    public var error:Error?
    private var inCode = 0
    public var code:Int{
        set{ inCode = newValue }
        get{
            if inCode == 0{
                if let error = error as? AFError {
                    return error.responseCode ?? 0
                }
                if let error = error as? NSError {
                    return error.code
                }
            }
            return inCode
        }
    }
    private var description = ""
    public var localizedDescription:String {
        set{ description = newValue }
        get{
            if let error = error, description == "" {
                return error.localizedDescription
            }
            return description
        }
    }
    
    public var title = "Error"
    
    public var all = [String:Any]()
    
    
    
    public init(error:Error?){
        self.error = error
    }
    
    public init(title:String, code:Int, description:String){
        self.title = title
        self.code = code
        self.localizedDescription = description
    }
    
    
    
    
}
