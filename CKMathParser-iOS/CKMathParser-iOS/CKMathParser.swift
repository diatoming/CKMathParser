//
//  CKMathParser.swift
//  CKMathParser-iOS
//
//  Created by Connor Krupp on 6/13/15.
//  Copyright © 2015 Connor Krupp. All rights reserved.
//

import Foundation

extension String {
    
    // Returns all ranges of a particular string inside of the string being operated on, if none are found, returns nil
    func rangesOfString(findStr:String) -> [Range<String.Index>]? {
        var ranges = [Range<String.Index>]()
        
        var i = 0
        while i <= self.characters.count-findStr.characters.count {
            if self[advance(self.startIndex, i)..<advance(self.startIndex, i+findStr.characters.count)] == findStr {
                ranges.append(Range(start:advance(self.startIndex, i),end:advance(self.startIndex, i+findStr.characters.count)))
                i = i+findStr.characters.count
            } else { i++ }
        }
        if ranges.count > 0 { return ranges } else { return nil }
    }
    
    // Reverses the string being operated on
    // In: asdf Out: fdsa
    func reverse() -> String {
        var reversed = ""
        for scalar in self.unicodeScalars {
            reversed = "\(scalar)" + reversed
        }
        return reversed
    }
    
    // Returns an optional Double from a string
    func toDouble() -> Double? {
        return NSNumberFormatter().numberFromString(self)?.doubleValue
    }
}

class CKMathParser {
    
    private var expressionTable = [ExpressionRow]() // Initializes expression table
    private var sequenceOfOperation = [Int]()
    
    private var availableOperations = [String:Op]()
    private var availableConstants = [String:Constant]()
    
    private var expression = ""
    
    // Main public function, takes expression as input and outputs result
    func evaluate(mathExpression: String) -> String {
        expression = mathExpression.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) //Removes extraneous spaces (if any)

        createExpressionTable()
        buildExpressionRelationships()
        calculateSequence()
        
        return "\(evaluateExpression())"
    }
    
    // Instantiating default operations
    init() {
        
        availableOperations["+"] = Op.BinaryOperation("+", 1, { $0 + $1 })
        availableOperations["-"] = Op.BinaryOperation("-", 1, { $0 - $1 })
        availableOperations["*"] = Op.BinaryOperation("*", 2, { $0 * $1 })
        availableOperations["/"] = Op.BinaryOperation("/", 2, { $0 / $1 })
        availableOperations["^"] = Op.BinaryOperation("^", 3, { pow($0,$1) })
        availableOperations["sin"] = Op.UnaryOperation("sin", 10, { sin($0) })
        availableOperations["cos"] = Op.UnaryOperation("cos", 10, { cos($0) })
        availableOperations["tan"] = Op.UnaryOperation("tan", 10, { tan($0) })
        availableOperations["log"] = Op.UnaryOperation("log", 10, { log($0) })

        availableConstants["π"] = Constant(name: "π", value: M_1_PI)
        availableConstants["e"] = Constant(name: "e", value: M_E)
    }

    //
    // Generates the inital expression table values
    //
    private func createExpressionTable() {
        
        //Gets function ranges and sorts them into order of use in expression
        for operation in availableOperations.values {
            if let unsortedRanges = expression.rangesOfString(operation.description) {
                for range in unsortedRanges {
                    addRowToExpressionTable(operation, range: range)
                }
            }
        }
        
        // Sorts the table in order of function appearance in the expression
        expressionTable = expressionTable.sort({ $0.rangeInExpression.startIndex < $1.rangeInExpression.startIndex })
        
    }
    
    //
    // Creates ExpressionRow and adds it to the table
    //
    private func addRowToExpressionTable(operation: Op, range: Range<String.Index>) {
        if !(operation.description == "-" && isUnaryMinus(expression, range: range)) {
            expressionTable.append(ExpressionRow(operation: operation, arguments: getArguments(range, operation: operation), level: getLevel(range, operation: operation), rangeInExpression: range))
        }
    }
    
    //
    // Boolean of whether a minus at a supplied index in a supplied expression is a unary minus
    //
    private func isUnaryMinus(expression: String, range: Range<String.Index>) -> Bool {
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
    //
    private func getLevel(functionRange: Range<String.Index>, operation: Op) -> Int {
        var level = 0
        for character in expression.substringToIndex(functionRange.startIndex).unicodeScalars {
            if character == "(" { level += 10 }
            if character == ")" { level -= 10 }
        }
        return level + operation.level
    }
    
    //
    // Gets the argument to the left of a function
    //
    private func getLeftArgument(relevantString: String) -> String? {
        let stoppingValues = availableOperations.keys.array + ["(", ")"]
        var argument = ""
        for character in relevantString.reverse().unicodeScalars {
            if !stoppingValues.contains("\(character)") {
                argument = "\(character)" + argument
            } else if character == "-" {
                if isUnaryMinus(relevantString, range: relevantString.rangesOfString("-")!.last!) {
                    argument = "\(character)" + argument
                } else { break }
            } else { break }
        }
        if argument == "" || stoppingValues.contains(argument) { return nil }
        return argument
    }
    
    //
    // Gets the argument to the right of a function
    //
    private func getRightArgument(relevantString: String) -> String? {
        let stoppingValues = availableOperations.keys.array + ["(", ")"]
        var argument = ""
        var minusIndex = 0
        for character in relevantString.unicodeScalars {
            if !stoppingValues.contains("\(character)") {
                argument.append(character)
            } else if character == "-" {
                if isUnaryMinus(relevantString, range: relevantString.rangesOfString("-")![minusIndex]) {
                    
                    argument.append(character)
                    minusIndex++
                } else { break }
            } else { break }
        }
        if argument == "" || stoppingValues.contains(argument) { return nil }
        return argument
    }
    
    //
    // Controls whether to get the left or right argument and writes it to the table row
    //
    private func getArguments(functionRange: Range<String.Index>, operation: Op) -> [String?] {
        switch operation {
        case .BinaryOperation:
            let leftArgument = getLeftArgument(expression.substringToIndex(functionRange.startIndex))
            let rightArgument = getRightArgument(expression.substringFromIndex(functionRange.endIndex))

            return [leftArgument, rightArgument]
        case .UnaryOperation:
            let rightArgument = getRightArgument(expression.substringFromIndex(functionRange.endIndex.successor()))
            return [rightArgument]
        }
    }
    
    //
    //  Figures out the argOfs for the rows
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
    //
    private func evaluateExpression() -> Double {
        for index in sequenceOfOperation {
            let row = expressionTable[index]
            var solution = 0.0
            switch row.operation {
            case .BinaryOperation(_, _, let function):
                solution = function(row.arguments[0]!.toDouble()!, row.arguments[1]!.toDouble()!)
            case .UnaryOperation(_, _, let function):
                solution = function(row.arguments[0]!.toDouble()!)
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
                return solution
            }
        }
        return -1.0
    }
    
}

