//: Playground - noun: a place where people can play

import UIKit


let operationSet = "+-*/"

let expression = "245*(a+b)*(a-b)+1"

let op = "+"

if let a = expression.rangeOfString(op) {
    
    var str = ""
    for var indexx = a.startIndex; indexx != expression.startIndex; indexx = indexx.predecessor() {
        let ch = expression[indexx.predecessor()]
        if operationSet.rangeOfString("\(ch)") == nil {
            str.append(ch)
        } else {
            break;
        }
    }
    
    var reverseStr = ""
    for scalar in str.unicodeScalars {
        var asString = "\(scalar)"
        reverseStr = asString + reverseStr
    }
    
    reverseStr
}