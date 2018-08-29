//
//  BaristaFramework.swift
//  Pods
//
//  Created by Santiago Bustamante on 9/21/16.
//
//

import UIKit
import Alamofire
import ObjectMapper

public func setupNetworking(withBaseURL baseURL: String){
    BaristaNetwork.default.setupNetwork(withBaseURL:baseURL)
}

public func addAdditionalHeaders(_ newHeaders: HTTPHeaders?) {
    if let adapter = BaristaNetwork.default.manager?.adapter as? BaristaNetworkAdapter {
        adapter.addAdditionalHeaders(newHeaders)
    }
}

public func addDefaultBaristaHeaders(appProfile: String = "mobile") {
    
    let version = UIApplication.appVersion()
    let build = UIApplication.appBuild()
    let versionHeader = "ios/\(appProfile)/\(version)/\(build)"
    let newHeaders = ["bv-app-version":versionHeader]
    
    addAdditionalHeaders(newHeaders)
}

@discardableResult
public func request(
    _ url: URLConvertible,
    method: HTTPMethod = .get,
    parameters: Parameters? = nil,
    encoding: ParameterEncoding = JSONEncoding.default,
    headers: HTTPHeaders? = nil)
    -> DataRequest
{
    return BaristaNetwork.default.manager!.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
}


public func upload(
    multipartFormData: @escaping (MultipartFormData) -> Void,
    usingThreshold encodingMemoryThreshold: UInt64 = SessionManager.multipartFormDataEncodingMemoryThreshold,
    to url: URLConvertible,
    method: HTTPMethod = .post,
    headers: HTTPHeaders? = nil,
    encodingCompletion: ((SessionManager.MultipartFormDataEncodingResult) -> Void)?)
{
    return BaristaNetwork.default.manager!.upload(
        multipartFormData: multipartFormData,
        usingThreshold: encodingMemoryThreshold,
        to: url,
        method: method,
        headers: headers,
        encodingCompletion: encodingCompletion
    )
}

@discardableResult
public func login<T:BaseMappable>(_ path: String,
                  parameters: Parameters,
                  completionHandler: @escaping(DataResponse<T>) -> Void) -> DataRequest
{
    return BaristaNetwork.default.manager!.login(path, parameters: parameters, completionHandler: completionHandler)
}

public func logout(completeHandler: ((_ success:Bool)->())? = nil){
    BaristaNetwork.default.manager?.logout(completeHandler: completeHandler)
}


/**
 setup a forced authenticated token
 the default authorizationType is bearer, if you want to use basic set it
 */
public func authenticate(withToken token: String, authorizationType: AuthorizationType? = nil) {
    BaristaNetwork.default.manager?.authenticate(withToken: token, authorizationType: authorizationType)
}

/**
 setup a specific authorization type
 could be .bearer .basic or .token
 */
public var authorizationType: AuthorizationType {
    set {
        if let manager = BaristaNetwork.default.manager, let adapter = manager.adapter as? BaristaNetworkAdapter {
            adapter.authorizationType = newValue
        } else {
            print("YOU HAVE TO SETUP BARISTA FRAMEWORK FIST")
        }
    }
    get {
        if let manager = BaristaNetwork.default.manager, let adapter = manager.adapter as? BaristaNetworkAdapter {
            return adapter.authorizationType
        } else {
            print("YOU HAVE TO SETUP BARISTA FRAMEWORK FIST")
            return .bearer
        }
        
    }
}

public var adapter: BaristaNetworkAdapter? {
    get {
        return BaristaNetwork.default.adapter
    }
}


