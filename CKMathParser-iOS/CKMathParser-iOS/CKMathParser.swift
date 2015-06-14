//
//  CKMathParser.swift
//  CKMathParser-iOS
//
//  Created by Connor Krupp on 6/13/15.
//  Copyright © 2015 Connor Krupp. All rights reserved.
//

import Foundation

class CKMathParser {
    
    private let operations = ["(","+", "-", "*", "/", "^"]
    
    init() {
        print("Parser Initialized");
    }
    
    func evaluate(mathExpression: String) -> Double {
        
        let expression = mathExpression
        
        for op in operations {
            if let pos = expression.rangeOfString(op, options:NSStringCompareOptions.BackwardsSearch) {
                
                var leftExpression = expression.substringWithRange(expression.startIndex..<pos.startIndex)
                var rightExpression = expression.substringWithRange(pos.endIndex..<expression.endIndex)
                
                if op == "(" {
                    let pos1 = expression.rangeOfString("(")
                    let pos2 = expression.rangeOfString(")", options:NSStringCompareOptions.BackwardsSearch)
                    
                    leftExpression = expression.substringWithRange(expression.startIndex..<pos.startIndex)
                    rightExpression = expression.substringWithRange((pos1?.startIndex)!..<(pos2?.endIndex)!)
                    
                    rightExpression.removeAtIndex(rightExpression.startIndex)
                    rightExpression.removeAtIndex(rightExpression.endIndex.predecessor())
                    //Return so it doesnt default
                    
                }
                
                print(leftExpression)
                print(rightExpression)
                switch op {
                    case "^":
                        return pow(evaluate(leftExpression), evaluate(rightExpression))
                    case "*":
                        return evaluate(leftExpression) * evaluate(rightExpression)
                    case "/":
                        return evaluate(leftExpression) / evaluate(rightExpression)
                    case "+":
                        return evaluate(leftExpression) + evaluate(rightExpression)
                    case "-":
                        return evaluate(leftExpression) - evaluate(rightExpression)
                    default:
                        return evaluate(leftExpression) + evaluate(rightExpression)
                }
            }
        }
        
        return (expression as NSString).doubleValue
    }
    
    private func cleanInput(var expression: String) -> String {
        expression = expression.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if expression[expression.startIndex] == "(" && expression[expression.endIndex.predecessor()] == ")" {
            expression.removeAtIndex(expression.startIndex)
            expression.removeAtIndex(expression.endIndex.predecessor())
        }
        
        return expression
    }
}