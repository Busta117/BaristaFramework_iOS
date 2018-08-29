//
//  UIKit.swift
//  Wapa_Customer_iOS
//
//  Created by Santiago Bustamante on 6/18/15.
//  Copyright © 2015 Barista Ventures. All rights reserved.
//

import Foundation
import UIKit



public extension UIImageView {
    public func changeImage(newImage:UIImage?, options:UIViewAnimationOptions = .transitionFlipFromRight){
        
        if newImage == self.image {
            return
        }
        
        UIView.transition(with: self, duration: 0.2, options: options, animations: {
            self.image = newImage
            }, completion: nil)
        
    }
}

