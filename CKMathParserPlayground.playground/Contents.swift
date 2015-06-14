//: Playground - noun: a place where people can play

import UIKit

let str = "2-(4+3)"

let pos = str.rangeOfString("-")
let pos1 = str.rangeOfString("(")
let pos2 = str.rangeOfString(")", options:NSStringCompareOptions.BackwardsSearch)

let left = str.substringWithRange(str.startIndex..<(pos?.startIndex)!)
let right = str.substringWithRange((pos1?.startIndex)!..<(pos2?.endIndex)!)

