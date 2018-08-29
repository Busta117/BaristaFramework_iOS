//
//  BaristaAccessTokenAdapter.swift
//  Pods
//
//  Created by Santiago Bustamante on 9/20/16.
//
//

import UIKit
import Alamofire


public enum AuthorizationType: String {
    case bearer = "Bearer"
    case basic = "Basic"
    case token = "Token"
}

open class BaristaNetworkAdapter: RequestAdapter {

    open var accessToken: String?
    open var additionalHeaders = HTTPHeaders()
    open var baseURL = URL(string: "")
    
    open var authorizationType = AuthorizationType.bearer
    
    open func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        if let accessToken = accessToken {
            urlRequest.setValue("\(authorizationType.rawValue) \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        additionalHeaders.forEach {urlRequest.setValue($1, forHTTPHeaderField: $0)} //adding addiotional headers to request
        
        let slash: Character = "/"
        
        //checking if the base url have an / at the end and remove it
        var baseStr = baseURL!.absoluteString
        if baseStr.characters.last == slash {
            baseStr.characters.removeLast()
        }
        //checking if the path url have an / at the bigining and remove it
        var url = urlRequest.url!.absoluteString
        if url.characters.first == slash {
            url.characters.removeFirst()
        }
        
        var completeUrlStr = baseStr + "/" + url //create a complete resource url
        urlRequest.url = URL(string: completeUrlStr)
        
        return urlRequest
    }
    
    
    public func addAdditionalHeaders(_ newHeaders:HTTPHeaders?) {
        
        if let newHeaders = newHeaders {
            let headers = try! newHeaders.forEach { additionalHeaders.updateValue($1, forKey: $0) }
        }
        
    }

    
}


