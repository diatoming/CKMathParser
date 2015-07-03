//
//  CKDataTypes.swift
//  CKMathParser-iOS
//
//  Created by Connor Krupp on 6/26/15.
//  Copyright © 2015 Connor Krupp. All rights reserved.
//

import Foundation


struct ExpressionRow {
    let operation: Op
    var arguments: [String?]
    let level: Int
    let rangeInExpression: Range<String.Index>
    var negationCount: Int?
    
    var argOf: Int?
    var sequence: Int?
    
    init(operation: Op, arguments: [String?], level: Int, rangeInExpression: Range<String.Index>) {
        self.operation = operation
        self.arguments = arguments
        self.level = level
        self.rangeInExpression = rangeInExpression
    }
}

struct OpWithRange {
    let operation: Op
    let range: Range<String.Index>
}

struct Constant {
    let name: String
    let value: Double
}

enum Op {
    case UnaryOperation(String, Int, Double -> Double)
    case BinaryOperation(String, Int, (Double, Double) -> Double)
    
    var description: String {
        get {
            switch self {
            case .UnaryOperation(let symbol, _,  _):
                return symbol
            case .BinaryOperation(let symbol, _, _):
                return symbol
            }
        }
    }
    
    var level: Int {
        get {
            switch self {
            case .UnaryOperation(_, let level,  _):
                return level
            case .BinaryOperation(_, let level, _):
                return level
            }
        }
    }
}
