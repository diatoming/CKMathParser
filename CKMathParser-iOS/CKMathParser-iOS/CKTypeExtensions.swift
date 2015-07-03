//
//  CKTypeExtensions.swift
//  CKMathParser-iOS
//
//  Created by Connor Krupp on 7/2/15.
//  Copyright © 2015 Connor Krupp. All rights reserved.
//

import Foundation


extension String {
    
    // Returns all ranges of a particular string inside of the string being operated on, if none are found, returns nil
    func rangesOfString(findStr: String) -> [Range<String.Index>]? {
        var ranges = [Range<String.Index>]()
        
        var i = 0
        while i <= self.characters.count-findStr.characters.count {
            if self[advance(self.startIndex, i)..<advance(self.startIndex, i+findStr.characters.count)] == findStr {
                ranges.append(Range(start:advance(self.startIndex, i),end:advance(self.startIndex, i+findStr.characters.count)))
                i = i+findStr.characters.count
            } else { i++ }
        }
        if ranges.count > 0 { return ranges } else { return nil }
    }
    
    // Reverses the string being operated on
    // In: asdf Out: fdsa
    func reverse() -> String {
        var reversed = ""
        for scalar in self.unicodeScalars {
            reversed = "\(scalar)" + reversed
        }
        return reversed
    }
    
    // Returns an optional Double from a string
    func toDouble() -> Double? {
        return NSNumberFormatter().numberFromString(self)?.doubleValue
    }
    
    func replaceSubstring(substringToReplace: String, substring: String) -> String {
        var done = false
        var newString = self
        while !done {
            if let range = newString.rangeOfString(substringToReplace) {
                newString.replaceRange(range, with: substring)
            } else {
                done = true
            }
        }
        return newString
    }
}
