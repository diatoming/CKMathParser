//
//  CKMathParserTests.swift
//  CKMathParser-iOS
//
//  Created by Connor Krupp on 7/7/15.
//  Copyright © 2015 Connor Krupp. All rights reserved.
//

import Foundation

class CKMathParserTests {
    var testExpressions = [String:String]()
    
    init() {
        testExpressions["1+4"] = "5.0"
        testExpressions["1-4"] = "-3.0"
        testExpressions["1*4"] = "4.0"
        testExpressions["1/4"] = "0.25"
        testExpressions["1+2-3*4/5"] = "0.6"
        testExpressions["     1+2    *3"] = "7.0"
        testExpressions["(4+8)/4 + (2+3*4)^2 - 3^4 + (9+10)*(15-21) + 7*(17-15)"] = "18.0"
        testExpressions["-1+2"] = "1.0"
        testExpressions["2^-(1+2)"] = "0.125"
        testExpressions["2^-(-(-(1+1)))"] = "0.25"
        testExpressions["2^(2)"] = "4.0"
        testExpressions["2+-1"] = "1.0"
        testExpressions["-1+2"] = "1.0"
        testExpressions["-(14-14)*2"] = "0.0"
        testExpressions["2^(((2)))"] = "4.0"
        testExpressions["0-1"] = "-1.0"
        testExpressions["2^2*2-1+0/4*-2+-2*-2^4"] = "39.0"
        testExpressions["(((((2-2)))))"] = "0.0"
        testExpressions["2^0"] = "1.0"
        testExpressions["-2^-(1+2)*(-1+4)*((-4+2))"] = "0.75"
        testExpressions["-2^-(-1+4^-(-1+4))"] = "-1.97845602639"
        testExpressions["2^2^2"] = "16.0"
    }
}