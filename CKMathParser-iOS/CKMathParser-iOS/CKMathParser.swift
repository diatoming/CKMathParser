//
//  CKMathParser.swift
//  CKMathParser-iOS
//
//  Created by Connor Krupp on 6/13/15.
//  Copyright © 2015 Connor Krupp. All rights reserved.
//

import Foundation

extension String {
    
    // Returns all ranges of a particular searchString, if none are found, returns nil
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
    
    func reverse() -> String {
        var reversed = ""
        for scalar in self.unicodeScalars {
            reversed = "\(scalar)" + reversed
        }
        return reversed
    }
}

class CKMathParser {
    
    private var expressionTable = [ExpressionRow]() // Initializes expression table
    private var sequenceOfOperation = [Int]()
    
    private var availableOperations = [String:Op]()
    private var availableConstants = [String:Constant]()
    
    private var expression = ""
    
    //Main public function, takes expression as input and outputs result
    func evaluate(mathExpression: String) -> String {
        expression = mathExpression.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) //Removes extraneous spaces (if any)
        
        createExpressionTable()
        fillExpressionTable()
        buildExpressionRelationships()
        calculateSequence()
        return "\(evaluateExpression())"
    }
    
    init() {
        
        availableOperations["+"] = Op.BinaryOperation("+", 1, { $0 + $1 })
        availableOperations["-"] = Op.BinaryOperation("-", 1, { $0 - $1 })
        availableOperations["*"] = Op.BinaryOperation("*", 2, { $0 * $1 })
        availableOperations["/"] = Op.BinaryOperation("/", 2, { $0 / $1 })
        availableOperations["^"] = Op.BinaryOperation("^", 3, { pow($0,$1) })

        availableConstants["π"] = Constant(name: "π", value: M_1_PI)
        availableConstants["e"] = Constant(name: "e", value: M_E)
    }
    
    //
    // Generates the inital expression table values
    //
    private func createExpressionTable() {
        
        var parantheticalLevel = 0
        
        for var index = expression.startIndex; index != expression.endIndex; index = index.successor() {
            let char = expression[index]
            
            if char == "(" { parantheticalLevel += 10 }
            if char == ")" { parantheticalLevel -= 10 }
            
            // Once finds an operation in the expression, if there is an operation in the library with that name, generates row
            if let op = availableOperations["\(char)"] {
                
                if !checkForUnaryMinus(index) { // Checks for unary minus
                    expressionTable.append(ExpressionRow(
                        function: op.description,
                        maxArguments: 2,
                        argumentOneId: nil,
                        argumentOneName: nil,
                        argumentOneValue: (getLeftArgument(index) as NSString).doubleValue,
                        argumentTwoId: nil,
                        argumentTwoName: nil,
                        argumentTwoValue: nil,
                        argOf: nil,
                        level: op.level + parantheticalLevel,
                        sequence: nil
                        )
                    )
                }
            }
            
        }
        
        for var index = expression.endIndex.predecessor(); index != expression.startIndex; index = index.predecessor() {
            if let _ = availableOperations["\(expression[index])"] {
                if !checkForUnaryMinus(index) {
                    expressionTable[expressionTable.count-1].argumentTwoValue = (expression.substringWithRange(Range(start: index.successor(), end: expression.endIndex)) as NSString).doubleValue
                    break;
                }
            }
        }
        
    }
    
    //
    // Fill in the second argument value for each row
    //
    private func fillExpressionTable() {
        for index in 0..<expressionTable.count-1 {
            expressionTable[index].argumentTwoValue = expressionTable[index+1].argumentOneValue
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
            let operation = availableOperations[row.function]!
            switch operation {
            case .UnaryOperation(_, _, let function):
                solution = function(row.argumentOneValue!)
            case .BinaryOperation(_, _, let function):
                solution = function(row.argumentOneValue!, row.argumentTwoValue!)
            }
           
            if let argumentRowIndex = row.argOf {
                if index > argumentRowIndex {
                    expressionTable[argumentRowIndex].argumentTwoValue = solution
                } else {
                    expressionTable[argumentRowIndex].argumentOneValue = solution
                }
            } else {
                return solution
            }
        
        }
        return 0
    }
    
    //
    //Gets left argument from a supplied operation index
    //
    private func getLeftArgument(index: String.Index) -> String {
        var reversedArgument = ""
        for var parsingIndex = index; parsingIndex != expression.startIndex; parsingIndex = parsingIndex.predecessor() {
            let char = expression[parsingIndex.predecessor()]
            if availableOperations["\(char)"] == nil {
                reversedArgument.append(char)
            } else {
                break;
            }
        }
        
        var argument = reversedArgument.reverse()
        argument = argument.stringByReplacingOccurrencesOfString("(", withString: "")
        argument = argument.stringByReplacingOccurrencesOfString(")", withString: "")
        return argument
    }
    
    //
    // Checks for unary minus
    //
    private func checkForUnaryMinus(index: String.Index) -> Bool {
        if let _ = availableOperations["\(expression[index.predecessor()])"] { return true } else { return false }
    }
}


struct ExpressionRow {
    let function: String
    let maxArguments: Int
    
    var argumentOneId: Int?
    var argumentOneName: String?
    var argumentOneValue: Double?
    
    var argumentTwoId: Int?
    var argumentTwoName: String?
    var argumentTwoValue: Double?
    
    var argOf: Int?
    
    let level: Int
    
    var sequence: Int?
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


