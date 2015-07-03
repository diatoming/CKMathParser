//
//  CKMathParser.swift
//  CKMathParser-iOS
//
//  Created by Connor Krupp on 6/13/15.
//  Copyright © 2015 Connor Krupp. All rights reserved.
//

import Foundation

class CKMathParser {
    
    private var expressionTable = [ExpressionRow]() // Initializes expression table
    private var sequenceOfOperation = [Int]()
    
    private var availableOperations = [String:Op]()
    private var availableConstants = [String:Constant]()
    
    private var expression = ""
    private var negationsAccountedFor = [Range<String.Index>]()
    
    //
    // Main public function, takes expression as input and outputs result
    // Status: Needs better pre-evaluation formatting and could switch up in what order it does these activities
    func evaluate(mathExpression: String) -> (result: Double?, error: String?) {
        expression = formatInitialExpression(mathExpression) //Removes extraneous spaces (if any)

        createExpressionTable()
        
        return (nil, nil)
    }
    
    //
    // Instantiating default operations
    // Status: I would like to not have to repeat the operation/constant name every time
    //
    init() {
        
        availableOperations["+"] = Op.BinaryOperation("+", 1, { $0 + $1 })
        availableOperations["-"] = Op.BinaryOperation("-", 1, { $0 - $1 })
        availableOperations["*"] = Op.BinaryOperation("*", 2, { $0 * $1 })
        availableOperations["/"] = Op.BinaryOperation("/", 2, { $0 / $1 })
        availableOperations["^"] = Op.BinaryOperation("^", 3, { pow($0,$1) })
        availableOperations["sin("] = Op.UnaryOperation("sin(", 10, { sin($0) })
        availableOperations["cos("] = Op.UnaryOperation("cos(", 10, { cos($0) })
        availableOperations["tan("] = Op.UnaryOperation("tan(", 10, { tan($0) })
        availableOperations["log("] = Op.UnaryOperation("log(", 10, { log($0) })

        availableConstants["π"] = Constant(name: "π", value: M_1_PI)
        availableConstants["e"] = Constant(name: "e", value: M_E)
    }
    
    //
    // Clears spaces, fixes unary minus/plus issues
    // Status: Does not account for unary minus after operator
    //
    private func formatInitialExpression(expression: String) -> String {
        var formattedExpression = expression
        
        formattedExpression = formattedExpression.replaceSubstring(" ", substring: "")
        formattedExpression = formattedExpression.replaceSubstring("(-", substring: "(0-")
        formattedExpression = formattedExpression.replaceSubstring("(+", substring: "(0+")
        if formattedExpression[formattedExpression.startIndex] == "-" || formattedExpression[formattedExpression.startIndex] == "+" {
            formattedExpression = "0" + formattedExpression
        }
        
        return formattedExpression
    }

    //
    // Generates the inital expression table values
    // Status: Not done
    //
    private func createExpressionTable() {
        var operationsFound = [OpWithRange]()
        var argumentsFound = [String]()
        var expressionToEdit = expression
        
        //Gets function ranges and sorts them into order of use in expression
        for operation in availableOperations.values {
            if let unsortedRanges = expression.rangesOfString(operation.description) {
                for range in unsortedRanges {
                    operationsFound.append(OpWithRange(operation: operation, range: range))
                    expressionToEdit = expressionToEdit.replaceSubstring(operation.description, substring: ",")
                }
            }
        }
    
        expressionToEdit = expressionToEdit.replaceSubstring("(", substring: "")
        expressionToEdit = expressionToEdit.replaceSubstring(")", substring: "")
        
        operationsFound = operationsFound.sort({ $0.range.startIndex < $1.range.startIndex })
        argumentsFound = expressionToEdit.componentsSeparatedByString(",").filter({ !$0.isEmpty })

        print(operationsFound.map({ $0.operation.description }))
        print(argumentsFound)
        
    }
    
    //
    // Boolean of whether a minus at a supplied index in a supplied expression is a unary minus
    // Status: Unimplemented
    //
    private func isUnaryMinus(expression: String, range: Range<String.Index>) -> Bool {
        if expression[range] != "-" {
            return false
        }
        if range.startIndex == expression.startIndex {
            return true
        }
        if (availableOperations.keys.array + ["("]).contains("\(expression[range.startIndex.predecessor()])") {
            return true
        }
        return false
    }
    
    //
    // Parses through the string and calculates the level based on convention
    // Status: Unimplemented
    //
    private func getLevel(functionRange: Range<String.Index>, operation: Op) -> Int {
        var level = 0
        for character in expression.substringToIndex(functionRange.startIndex).unicodeScalars {
            if character == "(" { level += 10 }
            if character == ")" { level -= 10 }
        }
        return level + operation.level
    }
    
}

