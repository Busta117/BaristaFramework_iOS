//
//  String.swift
//  BaristaFramework
//
//  Created by Santiago Bustamante on 10/23/16.
//
//

import UIKit


open class Regex {
    open let internalExpression: NSRegularExpression
    open let pattern: String
    
    public init(_ pattern: String) {
        self.pattern = pattern
        self.internalExpression = try! NSRegularExpression (pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
    }
    
    open func matched(in input: String) -> Bool{
        
        let matches = internalExpression.matches(in:input, options: NSRegularExpression.MatchingOptions.reportCompletion, range:NSMakeRange(0, input.characters.count))
        return matches.count > 0
    }
}


public extension String {
    
    /**
    matched by regular expression.
     */
    open func matched(by regexExpression :String) -> Bool {
        
        let pattern: String = regexExpression
        
        do{
            let internalExpression: NSRegularExpression = try NSRegularExpression (pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            
            let matches = internalExpression.matches(in:self, options: NSRegularExpression.MatchingOptions.reportCompletion, range:NSMakeRange(0, self.characters.count))
            return matches.count > 0
        } catch{
            return false
        }
        
    }
    
    open func stringRemovingSpecialCharacters() -> String{
        
        let symbol = "[^a-zA-Z0-9 ]+"
        do{
            let internalExpression: NSRegularExpression = try NSRegularExpression(pattern: symbol, options: NSRegularExpression.Options.caseInsensitive)
            
            var str = internalExpression.stringByReplacingMatches(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, self.characters.count), withTemplate: "")
            
            str = str.replacingOccurrences(of: " ", with: "-")
            
            return str
        }catch{
            return ""
        }
        
    }
    
    /**
     *  Validate an email
     *
     *  @return Valid email or not
     */
    
    public var isValidEmail: Bool {
        
        let regexString: String = "\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b"
        
        var result : Bool = false
        if !self.isEmpty{
            if  self.matched(by:regexString){
                result = true
            }
        }
        return result
    }
    
}
