//
//  CKMathParser.swift
//  CKMathParser-iOS
//
//  Created by Connor Krupp on 6/13/15.
//  Copyright © 2015 Connor Krupp. All rights reserved.
//

import Foundation

class CKMathParser {
    
    private let operations = ["-", "+", "/", "*"]
    
    init() {
        print("Parser Initialized");
    }
    
    func evaluate(expression: String) -> Float {
        
        // Clear empty space before and after expression
        // Check for letters
        
        for op in operations {
            if let pos = expression.rangeOfString(op, options:NSStringCompareOptions.BackwardsSearch) {
                
                let leftExpression = expression.substringWithRange(expression.startIndex..<pos.startIndex)
                let rightExpression = expression.substringWithRange(pos.endIndex..<expression.endIndex)
            
                switch op {
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
        
        return (expression as NSString).floatValue
    }
}