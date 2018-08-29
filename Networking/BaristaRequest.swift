//
//  NullRequest.swift
//  Wapa_Customer_iOS
//
//  Created by Santiago Bustamante on 8/25/15.
//  Copyright © 2015 Barista Ventures. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

public extension NSNotification.Name {
    public static let BaristaAppSessionDidExpire = NSNotification.Name("BaristaAppSessionDidExpireKey")// unauthorized, force login
    public static let BaristaAppVersionDidMismatch = NSNotification.Name("BaristaAppVersionDidMismatchKey") //force update
}


public let skipResponseStatusCodes = [401,426]

public extension DataRequest {
    
    typealias ErrorReason = AFError.ResponseValidationFailureReason
    
    open func baristaValidate() -> Self {
        
        let acceptableStatusCodes: Range<Int> = 200..<300
        
        return validate({ (request, response, data) -> Request.ValidationResult in
            
            if acceptableStatusCodes.contains(response.statusCode) {
                return .success
            } else {
                
                let reason: ErrorReason = .unacceptableStatusCode(code: response.statusCode)
                let error = AFError.responseValidationFailed(reason: reason)
                
                return .failure(self.handleObjectError(currentError: error, errorData: data, errorCode: response.statusCode))
            }
        })
    }
    
    
    @discardableResult
    public func handleObjectError(currentError:AFError, errorData:Any?, errorCode:Int = 400) -> BVError{
        var newError = BVError(error:currentError)
		
		var errorTitle = "Something went wrong"
		var errorMessage = "Check your internet connection and try again"
		if let dataAny = errorData as? Data{
            let data = dataAny.jsonDic()
            
			if let message = data["message"] as? String{
				errorMessage = message
                newError.all["message"] = message
                
            }
            
            if let title = data["name"] as? String{
                errorTitle = title
            }
            
            if let errors = data["errors"] as? [String:Any]{
                for (key,value) in errors{
                    newError.all[key] = value
                    if let value = value as? String {
                        errorMessage = value
                        errorTitle = key.capitalized
                    }
                }
            }
			
			newError.code = errorCode
            newError.localizedDescription = errorMessage
            newError.title = errorTitle
		}
		
        //force update
        if errorCode == 426 {
            NotificationCenter.default.post(name: .BaristaAppVersionDidMismatch, object: newError)
        }
        //Unauthorized, when the session is not valid anymore
        else if errorCode == 401 {
            NotificationCenter.default.post(name: .BaristaAppSessionDidExpire, object: newError)
        }
        
		
		return newError
	}
}


/**
 *
 * implemented those class to skip the response call when is a forceupdate or unauthorized
 *
 **/

public extension DataRequest {
	
    @discardableResult
    public func responseBaristaJSON(
        queue: DispatchQueue? = nil,
        options: JSONSerialization.ReadingOptions = .allowFragments,
        completionHandler: @escaping (DataResponse<Any>) -> Void)
        -> Self
    {
        return responseBarista(
            queue: queue,
            responseSerializer: DataRequest.jsonResponseSerializer(options: options),
            completionHandler: completionHandler
        )
    }
    
    @discardableResult
    public func responseBarista(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<Data>) -> Void)
        -> Self
    {
        return responseBarista(
            queue: queue,
            responseSerializer: DataRequest.dataResponseSerializer(),
            completionHandler: completionHandler
        )
    }
    
    @discardableResult
    public func responseBarista<T: DataResponseSerializerProtocol>(
        queue: DispatchQueue? = nil,
        responseSerializer: T,
        completionHandler: @escaping (DataResponse<T.SerializedObject>) -> Void)
        -> Self
    {
        return response(queue: queue, responseSerializer: responseSerializer, completionHandler: { (response) in
            if let error = response.result.error as? BVError, skipResponseStatusCodes.contains(error.code){
                return
            }
            completionHandler(response)
            
        })
    }
}

public extension DataRequest {
	
    public static func ObjectMapperSerializer<T: BaseMappable>(_ keyPath: String?, mapToObject object: T? = nil, context: MapContext? = nil) -> DataResponseSerializer<T> {
        return DataResponseSerializer { request, response, data, error in
            
            
            if let error = error {
                return .failure(error)
            }
            
            guard let _ = data else {
                let error = AFError.responseSerializationFailed(reason: .inputDataNil)
                return .failure(error)
            }
            
            let JSONResponseSerializer = jsonResponseSerializer(options: JSONSerialization.ReadingOptions.allowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
 
            let JSONToMap: Any?
            if let keyPath = keyPath , keyPath.isEmpty == false {
                JSONToMap = (result.value as AnyObject?)?.value(forKeyPath: keyPath)
            } else {
                JSONToMap = result.value
            }
            

            
            if let object = object {
                _ = Mapper<T>().map(JSONObject: JSONToMap, toObject: object)
                return .success(object)
            } else if let parsedObject = Mapper<T>(context: context).map(JSONObject: JSONToMap){
                return .success(parsedObject)
            }
            
            
            let failureReason = "ObjectMapper failed to serialize response."
            var error = AFError.responseSerializationFailed(reason: .inputDataNil)
            
            return .failure(error)
        }
    }
    
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter queue:             The queue on which the completion handler is dispatched.
     - parameter keyPath:           The key path where object mapping should be performed
     - parameter object:            An object to perform the mapping on to
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by ObjectMapper.
     
     - returns: The request.
     */
    @discardableResult
    public func responseObject<T: BaseMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        
        
        return responseBarista(queue: queue, responseSerializer: DataRequest.ObjectMapperSerializer(keyPath, mapToObject: object, context: context), completionHandler:completionHandler)
    }
    
    
        
    public static func ObjectMapperArraySerializer<T: BaseMappable>(_ keyPath: String?, context: MapContext? = nil) -> DataResponseSerializer<[T]> {
        return DataResponseSerializer { request, response, data, error in

            if let error = error {
                return .failure(error)
            }
            
            guard let _ = data else {
                let error = AFError.responseSerializationFailed(reason: .inputDataNil)
                return .failure(BVError(error: error))
            }
            
            
            let JSONResponseSerializer = jsonResponseSerializer(options: JSONSerialization.ReadingOptions.allowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
            
            
            let JSONToMap: Any?
            if let keyPath = keyPath, keyPath.isEmpty == false {
                JSONToMap = (result.value as AnyObject?)?.value(forKeyPath: keyPath)
            } else {
                JSONToMap = result.value
            }
            
            if let parsedObject = Mapper<T>(context: context).mapArray(JSONObject: JSONToMap){
                return .success(parsedObject)
            }
            
            
//            let failureReason = "ObjectMapper failed to serialize response."
            var error = AFError.responseSerializationFailed(reason: AFError.ResponseSerializationFailureReason.inputDataNil)
            return .failure(error)
        }
    }
    
    
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter queue: The queue on which the completion handler is dispatched.
     - parameter keyPath: The key path where object mapping should be performed
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by ObjectMapper.
     
     - returns: The request.
     */
    @discardableResult
    public func responseArray<T: BaseMappable>(queue: DispatchQueue? = nil, keyPath: String? = nil, context: MapContext? = nil, completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {
        
        return responseBarista(queue: queue, responseSerializer: DataRequest.ObjectMapperArraySerializer(keyPath, context: context),completionHandler:completionHandler)
        
    }
    

}
