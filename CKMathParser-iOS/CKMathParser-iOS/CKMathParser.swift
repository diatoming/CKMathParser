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
    
    private let operations = CKMathParser.createOperations() // Loads default operations
    private let variables = CKMathParser.createVariables() // Loads default variables
    private var expressionTable = [ExpressionRow]() // Initializes expression table
    private var sequenceTable = [Int]()

    //Main public function, takes expression as input and outputs result
    func evaluate(mathExpression: String) -> String {
        let expression = mathExpression.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) //Removes extraneous spaces (if any)
        
        createExpressionTable(expression)
        fillExpressionTable()
        buildExpressionRelationships()
        calculateSequence()
        
        return "\(evaluateExpression())"
    }
    
    class func createOperations() -> [Operation] {
        var operations = [Operation]()
        
        operations.append(Operation(name: "+", maxArguments: 2, level: 1, binaryOperation: { $0 + $1 }))
        operations.append(Operation(name: "-", maxArguments: 2, level: 1, binaryOperation: { $0 - $1 }))
        operations.append(Operation(name: "*", maxArguments: 2, level: 2, binaryOperation: { $0 * $1 }))
        operations.append(Operation(name: "/", maxArguments: 2, level: 2, binaryOperation: { $0 / $1 }))
        
        return operations
    }
    
    class func createVariables() -> [Variable] {
        var variables = [Variable]()
        
        variables.append(Variable(name: "pi", value: M_1_PI))
        variables.append(Variable(name: "e", value: M_E))
        
        return variables
    }
    
    //
    // Generates the inital expression table values
    //
    private func createExpressionTable(expression: String) {
        
        let operationSet = "+-*/"
        var parantheticalLevel = 0
        
        for var index = expression.startIndex; index != expression.endIndex; index = index.successor() {
            let char = expression[index]
            if char == "(" { parantheticalLevel += 10 }
            if char == ")" { parantheticalLevel -= 10 }
            // Once finds an operation in the expression, if there is an operation in the library with that name, generates row
            if operationSet.rangeOfString("\(char)") != nil {

                if !(char == "-" && operationSet.rangeOfString("\(expression[index.predecessor()])") != nil) { // Checks for unary minus
                    if let op = operationWithName("\(char)") {
                        expressionTable.append(ExpressionRow(
                            function: op.name,
                            maxArguments: op.maxArguments,
                            argumentOneId: nil,
                            argumentOneName: nil,
                            argumentOneValue: (getLeftArgument(index, expression: expression) as NSString).doubleValue,
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
        }
        
        for var index = expression.endIndex.predecessor(); index != expression.startIndex; index = index.predecessor() {
            
            if operationSet.rangeOfString("\(expression[index])") != nil {
                if !(expression[index] == "-" && operationSet.rangeOfString("\(expression[index.predecessor()])") != nil) {
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
                if row.level > largestLevel && !sequenceTable.contains(index) {
                    largestLevel = row.level
                    largestIndex = index
                }
            }
            sequenceTable.append(largestIndex)
            
        }
    }
    
    //
    // Evaluates the table
    //
    private func evaluateExpression() -> Double {
        for index in sequenceTable {
            let row = expressionTable[index]
            let solution = operationWithName(row.function)!.binaryOperation(row.argumentOneValue!, row.argumentTwoValue!)
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
    private func getLeftArgument(index: String.Index, expression: String) -> String {
        let operationSet = "+-*/"
        var reversedArgument = ""
        for var indexx = index; indexx != expression.startIndex; indexx = indexx.predecessor() {
            let char = expression[indexx.predecessor()]
            if operationSet.rangeOfString("\(char)") == nil {
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
    //
    //
    private func operationWithName(name: String) -> Operation? {
        for operation in operations {
            if operation.name == name {
                return operation
            }
        }
        
        return nil
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

struct Variable {
    let name: String
    let value: Double?
}

struct Operation {
    let name: String
    let maxArguments: Int
    let level: Int
    
    let binaryOperation: (Double, Double) -> Double
}
