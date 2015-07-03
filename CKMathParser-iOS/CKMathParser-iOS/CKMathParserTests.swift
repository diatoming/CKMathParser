//
//  CKMathParserTests.swift
//  CKMathParser-iOS
//
//  Created by Connor Krupp on 7/3/15.
//  Copyright © 2015 Connor Krupp. All rights reserved.
//

import Foundation

class CKMathParserTests {
    
    var testExpressions = [String:Double]()
    
    init() {
        testExpressions["1+1"] = 2.0
        testExpressions["1-1"] = 0.0
        testExpressions["1*2"] = 2.0
        testExpressions["1/2"] = 0.5
    }
    
    func executeTests() {
        let parser = CKMathParser()
        for (expression, answer) in testExpressions {
            if parser.evaluate(expression).result == answer {
                print("Correct")
            } else {
                print("Incorrect")
            }
        }
    }
}