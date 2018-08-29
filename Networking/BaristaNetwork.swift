//
//  BaristaNetwork.swift
//  Wapa_Customer_iOS
//
//  Created by Santiago Bustamante on 6/30/15.
//  Copyright © 2015 Barista Ventures. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireImage
import KeychainAccess

open class BaristaNetwork {
	
	typealias Success = (_ operationRequest: NSURLRequest?, _ responseObject: Any?) -> ()
	typealias Failure = (_ error: AFError) -> ()
	
	private var clientID:String = ""
	private var secret:String = ""
	
	public var manager:BaristaSessionManager?
	
    open var adapter: BaristaNetworkAdapter? {
        get {
            if let manager = manager, let managerId = manager.serviceProviderIdentifier, let adapter = manager.adapter as? BaristaNetworkAdapter  {
                return adapter
            }
            return nil
        }
    }
	
	open var isAuthenticated : Bool {
		get {
			
			if let manager = manager, let managerId = manager.serviceProviderIdentifier, let adapter = manager.adapter as? BaristaNetworkAdapter  {
                
                if let _ = adapter.accessToken{
                    return true
                }
                
                print("check session - null keychain id: \(managerId)")
                let keychain = Keychain(service: managerId).accessibility(Accessibility.alwaysThisDeviceOnly)
                
                var token:String?
                do{
                    token = try keychain.get(BaristaCredentialServiceName)
                }catch _{
                    return false
                }
                
                if let token = token{
                    adapter.accessToken = token
                    return true
                }
                return false
				
			}
            
			return false
		}
	}
	
	
	/// Singelton instance
	public static let `default`: BaristaNetwork = BaristaNetwork()
	
	
	/**
	Instantiate the HTTP client with a base url and public key to be able to connect to server
	
	- parameter baseURL:  API base URL
	- parameter clientID: API public key
	*/
	func setupNetwork(withBaseURL baseURL: String){
		
		manager = BaristaSessionManager(baseUrl: URL(string: baseURL)!)
        addDefaultBaristaHeaders()
		
	}
	
}

public extension String {
	
	public func jsonDic() -> [AnyHashable:Any] {
		let data: Data = self.data(using: String.Encoding.utf8)!
		return data.jsonDic()
	}
	
}

public extension Data {
	public func jsonDic() -> [AnyHashable:Any] {
		let json:Any?
		
		do {
			json = try JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions.allowFragments)
            if let json = json as? [AnyHashable:Any]{
				return json
			}
			return [AnyHashable:Any]()
		} catch _{
			return [AnyHashable:Any]()
		}
	}
}

public extension UIImage {
    
    public func saveInCache(forUrlString urlString: String?) {
        
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return
        }
        
        let request = URLRequest(url: url)
        saveInCache(forRequest: request)
    }
    
    public func saveInCache(forRequest request: URLRequest?) {
        guard let request = request else {
            print("[BaristaFramework] WARNING - image not saved, there's no request")
            return
        }
        let imageDownloader = UIImageView.af_sharedImageDownloader
        let imageCache = imageDownloader.imageCache
        imageCache?.add(self, for: request, withIdentifier: nil)
    }
    
}

public extension UIImageView {

	open func cancelImageRequest() {
        self.af_cancelImageRequest()
    }
	
	open func setImage(withUrl url:String?, placeholder:UIImage? = nil, transitionDuration:Double = 0.3, animateTransition:Bool = true){
		
        if let url = url {
            if let url = URL(string: url){
                
                self.af_setImage(withURL: url, placeholderImage: placeholder, filter: nil, imageTransition: UIImageView.ImageTransition.noTransition, completion: { (response) in
                    if let image = response.result.value {
                        if animateTransition {
                            UIView.transition(with: self, duration: transitionDuration, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { 
                                self.image = image
                            })
                        }else{
                            self.image = response.result.value
                        }
                    }
                    else{
                        if let placeholder = placeholder {
                            self.image = placeholder
                        }
                    }
                })
                
            }else{
                if let placeholder = placeholder {
                    self.image = placeholder
                }
            }
        }else{
            if let placeholder = placeholder {
                self.image = placeholder
            }
        }
		
	}
	
}


