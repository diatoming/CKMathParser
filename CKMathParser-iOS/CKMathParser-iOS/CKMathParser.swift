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
    
    //Main public function, takes expression as input and outputs result
    func evaluate(mathExpression: String) -> String {
        let expression = mathExpression.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) //Removes extraneous spaces (if any)
        
        createExpressionTable(expression)
        fillExpressionTable()
        
        return expression
    }
    
    private func createExpressionTable(expression: String) {
        
        let operationSet = "+-*/"
        var parantheticalLevel = 0
        
        for var index = expression.startIndex; index != expression.endIndex; index = index.successor() {
            let char = expression[index]
            if char == "(" { parantheticalLevel += 10 }
            if char == ")" { parantheticalLevel -= 10 }
            
            // Once finds an operation in the expression, if there is an operation in the library with that name, generates row
            if operationSet.rangeOfString("\(char)") != nil {
                if let op = operationWithName("\(char)") {
                
                    expressionTable.append(ExpressionRow(
                        id: self.expressionTable.count+1,
                        function: op.name,
                        maxArguments: op.maxArguments,
                        argumentOneId: nil,
                        argumentOneName: nil,
                        argumentOneValue: (getLeftArgument(index, expression: expression) as NSString).doubleValue,
                        argumentTwoId: nil,
                        argumentTwoName: nil,
                        argumentTwoValue: nil,
                        level: op.level + parantheticalLevel,
                        sequence: nil
                        )
                    )
                }
            }
        }
        
        for var index = expression.endIndex.predecessor(); index != expression.startIndex; index = index.predecessor() {
            if operationSet.rangeOfString("\(expression[index])") != nil {
                expressionTable[expressionTable.count-1].argumentTwoValue = (expression.substringWithRange(Range(start: index.successor(), end: expression.endIndex)) as NSString).doubleValue
                break;
            }
        }
    }
    
    private func fillExpressionTable() {
        for index in 0..<expressionTable.count-1 {
            expressionTable[index].argumentTwoValue = expressionTable[index+1].argumentOneValue
        }
    }
    
    //Gets left argument from a supplied operation index
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
    
    
    class func createOperations() -> [Operation] {
        var operations = [Operation]()
        
        operations.append(Operation(name: "+", maxArguments: 2, level: 1))
        operations.append(Operation(name: "-", maxArguments: 2, level: 1))
        operations.append(Operation(name: "*", maxArguments: 2, level: 2))
        operations.append(Operation(name: "/", maxArguments: 2, level: 2))
        
        return operations
    }
    
    class func createVariables() -> [Variable] {
        var variables = [Variable]()
        
        variables.append(Variable(name: "pi", value: M_1_PI))
        variables.append(Variable(name: "e", value: M_E))
        
        return variables
    }
    
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
