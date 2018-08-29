//
//  BaristaManager.swift
//  Pods
//
//  Created by Santiago Bustamante on 9/21/15.
//
//

import UIKit
import Alamofire
import KeychainAccess
import ObjectMapper


public let BaristaCredentialServiceName:String = "BaristaCredentialService"
public let BaristaCredentialAuthType:String = "BaristaCredentialAuthType"

func AlamoKeychainQueryDictionaryWithIdentifier(identifier:String) -> [String:Any]{
	return [kSecClass as String:kSecClassGenericPassword, kSecAttrService as String:BaristaCredentialServiceName, kSecAttrAccount as String:identifier]
}

public struct URLNoBracketsEncoding: ParameterEncoding {
    
    public static var `default`: URLNoBracketsEncoding { return URLNoBracketsEncoding() }
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try URLEncoding.queryString.encode(urlRequest, with: parameters)
        request.url = URL(string: request.url!.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "="))
        return request
    }
}


//Manager
open class BaristaSessionManager: SessionManager {
	
	open var serviceProviderIdentifier:String?
    
	
	init(baseUrl:URL){
        super.init()
        serviceProviderIdentifier =  baseUrl.host //"\(baseUrl.host)/\(UIApplication.appId())" //this is to create an unique id for app
        createAccessTokenAdapter(baseUrl:baseUrl)
	}
    
    
    public override init(
        configuration: URLSessionConfiguration = URLSessionConfiguration.default,
        delegate: SessionDelegate = SessionDelegate(),
        serverTrustPolicyManager: ServerTrustPolicyManager? = nil)
    {
        super.init(configuration:configuration, delegate:delegate, serverTrustPolicyManager:serverTrustPolicyManager)
    }
    
    
    func createAccessTokenAdapter(baseUrl:URL){
        
        adapter = BaristaNetworkAdapter()
        
        if let adapter = adapter as? BaristaNetworkAdapter {
            adapter.baseURL = baseUrl
            if adapter.accessToken == nil{
                var token:String?
                var authorizationTypeStr = AuthorizationType.bearer.rawValue
                print("crate adapter - Barista keychain id: \(serviceProviderIdentifier)")
                let keychain = Keychain(service: serviceProviderIdentifier!).accessibility(.alwaysThisDeviceOnly)
                do{
                    token = try keychain.get(BaristaCredentialServiceName)
                }catch _{
                    token = nil
                }
                
                if let token = token{
                    adapter.accessToken = token
                }
                
                //get the auth type
                do {
                    if let value = try keychain.get(BaristaCredentialAuthType) {
                        authorizationTypeStr = value
                    }
                }catch _{
                    authorizationTypeStr = AuthorizationType.bearer.rawValue
                }
                
                adapter.authorizationType = AuthorizationType(rawValue: authorizationTypeStr)!
            }
        }
        
        
        
    }
    
    
    @discardableResult
    open override func request(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        headers: HTTPHeaders? = nil)
        -> DataRequest
    {
        
        var realEncoding = encoding
        if method == .get {
            realEncoding = URLNoBracketsEncoding.default
            
        }
        
        return super.request(url, method: method, parameters: parameters, encoding: realEncoding, headers: headers)
    }
    
    @discardableResult
    public func login<T:BaseMappable>(_ path: String,
                      parameters: Parameters,
                      completionHandler: @escaping(DataResponse<T>) -> Void) -> DataRequest
    {   
        return self.request(path, method: .post, parameters: parameters)
            .baristaValidate()
            .responseObject { (response:DataResponse<T>) in
            
            if response.result.isSuccess {
                let JSONResponseSerializer = DataRequest.jsonResponseSerializer(options: JSONSerialization.ReadingOptions.allowFragments)
                let result = JSONResponseSerializer.serializeResponse(response.request, response.response, response.data, response.result.error)
                
                if let serviceProviderIdentifier = self.serviceProviderIdentifier {
                    if let value = result.value as? [String:Any] {
                        var authToken: String?
                        
                        if let token = value["token"] as? String {
                            authToken = token
                        } else if let token = value["auth_token"] as? String {
                            authToken = token
                        }
                        
                        if let token = authToken {
                            print("login Barista keychain id: \(serviceProviderIdentifier)")
                            
                            let keychain = Keychain(service: serviceProviderIdentifier).accessibility(.alwaysThisDeviceOnly)
                            
                            do{
                                try keychain.set(token, key: BaristaCredentialServiceName)
                                
                                if let adapter = self.adapter as? BaristaNetworkAdapter{
                                    adapter.accessToken = token
                                }
                                
                                completionHandler(response)
                                
                            }catch _{
                                print("YOU NEED TO SETUP BARISTA FRAMEWORK FIRST")
                                //                            completionHandler(response)
                            }
                        }else{
                            print("UNABLE TO GET TOKEN IN RESPONSE")
                            completionHandler(response)
                        }
                    }else{
                        print("RESPONSE IN A WRONG FORMAT")
                    }
                }else{
                    print("YOU NEED TO SETUP BARISTA FRAMEWORK FIRST!")
//                    completionHandler(response)
                }
            }else{
                completionHandler(response)
                //aqui retornar error para mostrarle al user
            }
        }
    }
    
    /**
     set a forced session token
     */
    public func authenticate(withToken token:String, authorizationType:AuthorizationType? = nil) {
        
        guard let serviceProviderIdentifier = serviceProviderIdentifier else{
            print("YOU NEED TO SETUP BARISTA FRAMEWORK FIRST")
            return
        }
        print("forced Barista keychain id: \(serviceProviderIdentifier)")
        
        let keychain = Keychain(service: serviceProviderIdentifier).accessibility(.alwaysThisDeviceOnly)
        do{
            try keychain.set(token, key: BaristaCredentialServiceName)
            
            if let authorizationType = authorizationType {
                try keychain.set(authorizationType.rawValue, key: BaristaCredentialAuthType)
            }
            
            if let adapter = self.adapter as? BaristaNetworkAdapter{
                adapter.accessToken = token
                if let authorizationType = authorizationType {
                    adapter.authorizationType = authorizationType
                }
            }
        }catch _{
            print("YOU NEED TO SETUP BARISTA FRAMEWORK FIRST")
        }
    }
    
    
    /**
     Remove the credentials from the device
     */
    public func logout(completeHandler: ((_ success:Bool)->())? = nil){
        
        if let serviceProviderIdentifier = serviceProviderIdentifier{
            
            
            print("logout - Barista keychain id: \(serviceProviderIdentifier)")
            let keychain = Keychain(service: serviceProviderIdentifier).accessibility(.alwaysThisDeviceOnly)
            do{
                try keychain.remove(BaristaCredentialServiceName)
                
                if let adapter = adapter as? BaristaNetworkAdapter{
                    adapter.accessToken = nil
                }
                
                completeHandler?(true)
            }catch _{
                print("*****SOMETHING HAPPENED DELETING TOKEN FROM KEYCHAIN")
                completeHandler?(false)
            }
        }else{
            print("NO keychain id stored")
        }
    }
    
	
	
}


