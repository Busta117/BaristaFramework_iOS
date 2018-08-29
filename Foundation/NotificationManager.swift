//
//  NotificationManager.swift
//  BaristaFramework_iOS
//
//  Created by Santiago Bustamante on 6/18/15.
//  Copyright © 2015 Barista Ventures. All rights reserved.
//

import Foundation
import UIKit

open class NotificationManager {
    fileprivate var observerTokens: [Any] = []
    
    public init(){}
    
    deinit {
        deregisterAll()
    }
    
    open func deregisterAll() {
        for token in observerTokens {
            NotificationCenter.default.removeObserver(token)
        }
        
        observerTokens = []
    }
    
    open func addObserver(forName name: NSNotification.Name, action: @escaping ((Notification) -> ())) {
        let newToken = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) {note in
            action(note)
        }
        
        observerTokens.append(newToken)
    }
    
    open func addObserver(forNameString name: String, forObject object: Any? = nil, action: @escaping ((Notification) -> ())) {
        let newToken = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: name), object: object, queue: nil) {note in
            action(note)
        }
        
        observerTokens.append(newToken)
    }
}


public struct NotificationGroup {
    let entries: [String]
    
    init(_ newEntries: String...) {
        entries = newEntries
    }
    
}

public extension NotificationManager {
    open func addGroupObserver(_ group: NotificationGroup, action: @escaping ((Notification) -> ())) {
        for name in group.entries {
            addObserver(forNameString:name, action: action)
        }
    }
}

public extension Notification {
    
    
    open var keyboardHeight: CGFloat{
        if let keyboardSize = (self.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            return keyboardSize.height
        }
        return 0
    }
    
    open var keyboardAnimationDuraction: Double{
        if let animationDuration = self.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double {
            return animationDuration
        }
        return 0
    }
    
    open var keyboardAnimationType: UIViewAnimationOptions{
        if let options = self.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? Int {
            return UIViewAnimationOptions(rawValue: UInt(options << 16))
        }
        return UIViewAnimationOptions.curveEaseIn
    }
}

public extension NotificationManager {
    
    open func postNotification(withName aName: Notification.Name, object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
        NotificationCenter.default.post(name: aName, object: object, userInfo: userInfo)
    }
    
    open func postNotification(withNameString aName: String, object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: aName), object: object, userInfo: userInfo)
    }
    
}



