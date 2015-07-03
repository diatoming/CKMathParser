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
    
    private var availableOperations = [Op]()
    private var availableConstants = [Constant]()
    
    private var expression = ""
    private var negationsAccountedFor = [Range<String.Index>]()
    
    //
    // Main public function, takes expression as input and outputs result
    // Status: Needs better pre-evaluation formatting and could switch up in what order it does these activities
    func evaluate(mathExpression: String) -> (result: Double?, error: String?) {
        expression = formatInitialExpression(mathExpression) //Removes extraneous spaces (if any)

        createExpressionTable()
        buildExpressionRelationships()
        calculateSequence()
        
        return evaluateExpressionTable()
    }
    
    //
    // Instantiating default operations
    // Status: I would like to not have to repeat the operation/constant name every time
    //
    init() {
        
        availableOperations.append(Op.BinaryOperation("+", 1, { $0 + $1 }))
        availableOperations.append(Op.BinaryOperation("-", 1, { $0 - $1 }))
        availableOperations.append(Op.BinaryOperation("*", 2, { $0 * $1 }))
        availableOperations.append(Op.BinaryOperation("/", 2, { $0 / $1 }))
        availableOperations.append(Op.BinaryOperation("^", 3, { pow($0,$1) }))
        availableOperations.append(Op.UnaryOperation("sin(", 10, { sin($0) }))
        availableOperations.append(Op.UnaryOperation("cos(", 10, { cos($0) }))
        availableOperations.append(Op.UnaryOperation("tan(", 10, { tan($0) }))
        availableOperations.append(Op.UnaryOperation("log(", 10, { log($0) }))

        availableConstants.append(Constant(name: "π", value: M_1_PI))
        availableConstants.append(Constant(name: "e", value: M_E))
        
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
        if !formattedExpression.isEmpty && (formattedExpression[formattedExpression.startIndex] == "-" || formattedExpression[formattedExpression.startIndex] == "+") {
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
        var expressionToEdit = expression
        
        //Gets function ranges and sorts them into order of use in expression
        for operation in availableOperations {
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
        var argumentsFound = expressionToEdit.componentsSeparatedByString(",").filter({ !$0.isEmpty })
        
        for index in 0..<operationsFound.count {
            let operation = operationsFound[index].operation
            let range = operationsFound[index].range
            let arguments: [String?] = [argumentsFound[index], argumentsFound[index+1]]
            let level = getLevel(range, operation: operation)
            expressionTable.append(ExpressionRow(operation: operation, arguments: arguments, level: level, rangeInExpression: range))
        }
        
    }
    
    //
    // Figures out the argOfs for the rows
    // Status: I haven't looked into improving it yet, but I'm sure it can be
    //
    private func buildExpressionRelationships() {
        for _ in expressionTable {
            var largestIndex = 0
            var largestLevel = 0
            for (index, row) in expressionTable.enumerate() {
                if row.level > largestLevel && row.argOf == nil {
                    largestIndex = index
                    largestLevel = row.level
                }
            }
            
            var upperLevel: Int?
            var lowerLevel: Int?
            var upperI = 1
            var lowerI = 1
            
            while largestIndex-upperI >= 0 {
                if expressionTable[largestIndex-upperI].argOf == nil {
                    upperLevel = expressionTable[largestIndex-upperI].level
                    break
                }
                upperI++
            }
            while largestIndex+lowerI < expressionTable.count {
                if expressionTable[largestIndex+lowerI].argOf == nil {
                    lowerLevel = expressionTable[largestIndex+lowerI].level
                    break
                }
                lowerI++
            }
            
            if upperLevel > lowerLevel {
                expressionTable[largestIndex].argOf = largestIndex-upperI
            } else if upperLevel < lowerLevel {
                expressionTable[largestIndex].argOf = largestIndex+lowerI
            } else if upperLevel == lowerLevel && upperLevel != nil && lowerLevel != nil {
                expressionTable[largestIndex].argOf = largestIndex-upperI
            }
            
        }
    }
    
    //
    // Builds the sequence of operations
    // Status: Seems like it could be vectorized in some way
    //
    private func calculateSequence() {
        for _ in expressionTable {
            var largestLevel = 0
            var largestIndex = 0
            
            for (index, row) in expressionTable.enumerate() {
                if row.level > largestLevel && !sequenceOfOperation.contains(index) {
                    largestLevel = row.level
                    largestIndex = index
                }
            }
            sequenceOfOperation.append(largestIndex)
            
        }
    }
    
    //
    // Evaluates the table
    // Status: Seems simple for what it is doing, but could be improved as well
    //
    private func evaluateExpressionTable() -> (Double?, String?) {
        for index in sequenceOfOperation {
            let row = expressionTable[index]
            var solution = 0.0
            switch row.operation {
            case .BinaryOperation(_, _, let function):
                if let firstArgument = row.arguments[0]?.toDouble() {
                    if let secondArgument = row.arguments[1]?.toDouble() {
                        solution = function(firstArgument, secondArgument)
                    } else {
                        return (nil, "Error: \(row.arguments[1]) not recognized")
                    }
                } else {
                    return (nil, "Error: \(row.arguments[0]) not recognized")
                }
            case .UnaryOperation(_, _, let function):
                if let argument = row.arguments[0]?.toDouble() {
                    solution = function(argument)
                } else {
                    return (nil, "Error: \(row.arguments[0]) not recognized")
                }
            }
            if let argumentRowIndex = row.argOf {
                if index > argumentRowIndex {
                    switch expressionTable[argumentRowIndex].operation {
                    case .UnaryOperation:
                        expressionTable[argumentRowIndex].arguments[0] = "\(solution)"
                    case .BinaryOperation:
                        expressionTable[argumentRowIndex].arguments[1] = "\(solution)"
                    }
                } else {
                    expressionTable[argumentRowIndex].arguments[0] = "\(solution)"
                }
            } else {
                return (solution, nil)
            }
        }
        return (nil, "Error: No Expression")
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
        if (availableOperations.map({ $0.description }) + ["("]).contains("\(expression[range.startIndex.predecessor()])") {
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

