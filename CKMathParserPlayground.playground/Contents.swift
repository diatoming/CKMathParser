//: Playground - noun: a place where people can play

import UIKit

extension String {
    func rangesOfString(findStr:String) -> [Range<String.Index>] {
        var arr = [Range<String.Index>]()
        var startInd = self.startIndex
        // check first that the first character of search string exists
        if self.characters.contains(findStr.characters.first!) {
            // if so set this as the place to start searching
            startInd = self.characters.indexOf(findStr.characters.first!)!
        }
        else {
            // if not return empty array
            return arr
        }
        var i = distance(self.startIndex, startInd)
        while i<=self.characters.count-findStr.characters.count {
            if self[advance(self.startIndex, i)..<advance(self.startIndex, i+findStr.characters.count)] == findStr {
                arr.append(Range(start:advance(self.startIndex, i),end:advance(self.startIndex, i+findStr.characters.count)))
                i = i+findStr.characters.count
            }
            else {
                i++
            }
        }
        return arr
    }
}

let operationSet = "+-*/"

let expression = "245*(a+b)*(a-b)+1"

func getArg(index: String.Index) {
    var argument = ""
    var reversedArgument = ""
    for var indexx = index; indexx != expression.startIndex; indexx = indexx.predecessor() {
        let char = expression[indexx.predecessor()]
        print(char)
        if operationSet.rangeOfString("\(char)") == nil {
            reversedArgument.append(char)
        } else {
            break;
        }
    }
    
    for scalar in reversedArgument.unicodeScalars {
        argument = "\(scalar)" + argument
    }
    argument = argument.stringByReplacingOccurrencesOfString("(", withString: "")
    argument = argument.stringByReplacingOccurrencesOfString(")", withString: "")
    print(argument)
}

for var index = expression.startIndex; index != expression.endIndex; index = index.successor() {
    let char = expression[index]
    
    if operationSet.rangeOfString("\(char)") != nil {
        getArg(index)
    }
}
