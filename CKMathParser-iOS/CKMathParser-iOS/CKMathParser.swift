//
//  CKMathParser.swift
//  CKMathParser-iOS
//
//  Created by Connor Krupp on 6/13/15.
//  Copyright © 2015 Connor Krupp. All rights reserved.
//

import Foundation

class CKMathParser {
    
    private let operations = CKMathParser.createOperations()
    private let variables = CKMathParser.createVariables()
    private var expressionTable = [ExpressionRow]()
    
    func evaluate(mathExpression: String) -> String {
        let expression = CKMathParser.cleanInput(mathExpression)
        
        createExpressionTable(expression)
        
        return expression
    }
    
    class func cleanInput(var expression: String) -> String {
        expression = expression.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if expression[expression.startIndex] == "(" && expression[expression.endIndex.predecessor()] == ")" {
            expression.removeAtIndex(expression.startIndex)
            expression.removeAtIndex(expression.endIndex.predecessor())
        }
        
        return expression
    }
    
    private func createExpressionTable(expression: String) {
        
        let op = operations[2]
        
        getArguments(expression, op: op.name)
        
        _ = ExpressionRow(
            id: self.expressionTable.count+1,
            function: op.name,
            maxArguments: op.maxArguments,
            argumentOneId: nil,
            argumentOneName: nil,
            argumentOneValue: nil,
            argumentTwoId: nil,
            argumentTwoName: nil,
            argumentTwoValue: nil,
            level: op.level,
            sequence: nil
        )
        
        
    }
    
    private func getArguments(expression: String, op: String) {
        let operationSet = "+-*/"

        if let opRange = expression.rangeOfString(op) {
            var reversedArgument = ""
            for var index = opRange.startIndex; index != expression.startIndex; index = index.predecessor() {
                let char = expression[index.predecessor()]
                if operationSet.rangeOfString("\(char)") == nil {
                    reversedArgument.append(char)
                } else {
                    break;
                }
            }
            
            var argument = ""
            for scalar in reversedArgument.unicodeScalars {
                argument = "\(scalar)" + argument
            }
            
        }
    }
    
    
    class func createOperations() -> [Operation] {
        var operations = [Operation]()
        
        operations.append(Operation(name: "+", maxArguments: 2, level: 1))
        operations.append(Operation(name: "-", maxArguments: 2, level: 1))
        operations.append(Operation(name: "*", maxArguments: 2, level: 2))
        operations.append(Operation(name: "/", maxArguments: 2, level: 2))
        
        return operations
    }
    
    static func createVariables() -> [Variable] {
        var variables = [Variable]()
        
        variables.append(Variable(name: "pi", value: M_1_PI))
        variables.append(Variable(name: "e", value: M_E))
        
        return variables
    }
}


struct ExpressionRow {
    let id: Int
    let function: String
    let maxArguments: Int
    
    var argumentOneId: Int?
    var argumentOneName: String?
    var argumentOneValue: Double?
    
    var argumentTwoId: Int?
    var argumentTwoName: String?
    var argumentTwoValue: Double?
    
    let level: Int
    
    var sequence: Int?
}

struct Variable {
    let name: String
    let value: Double?
}

struct Operation {
    let name: String
    let maxArguments: Int
    let level: Int
}
