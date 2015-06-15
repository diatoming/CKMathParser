//: Playground - noun: a place where people can play

import UIKit

extension String {
    func rangesOfString(findStr:String) -> [Range<String.Index>]? {
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
}

let expression = "245*(a+b)*(a-b)+1"

expression.rangesOfString("*")