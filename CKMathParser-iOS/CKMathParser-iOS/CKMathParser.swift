//
//  CKMathParser.swift
//  CKMathParser-iOS
//
//  Created by Connor Krupp on 6/13/15.
//  Copyright © 2015 Connor Krupp. All rights reserved.
//

import Foundation

extension String {
    func rangesOfString(findStr:String) -> [Range<String.Index>]? {
        var arr = [Range<String.Index>]()
        var startInd = self.startIndex
        // check first that the first character of search string exists
        if self.characters.contains(findStr.characters.first!) {
            // if so set this as the place to start searching
            startInd = self.characters.indexOf(findStr.characters.first!)!
        }
        else {
            // if not return empty array
            return nil
        }
        var i = distance(self.startIndex, startInd)
        while i<=self.characters.count-findStr.characters.count {
            if self[advance(self.startIndex, i)..<advance(self.startIndex, i+findStr.characters.count)] == findStr {
                arr.append(Range(start:advance(self.startIndex, i),end:advance(self.startIndex, i+findStr.characters.count)))
                i = i+findStr.characters.count
            }
            else {
                i++
            }
        }
        return arr
    }
}

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
        
        
        let operationSet = "+-*/"
        var parantheticalLevel = 0
        for var index = expression.startIndex; index != expression.endIndex; index = index.successor() {
            let char = expression[index]
            if char == "(" {
                parantheticalLevel += 10
            } else if char == ")" {
                parantheticalLevel -= 10
            }
            
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
        
    }
    
    private func getLeftArgument(index: String.Index, expression: String) -> String {
        let operationSet = "+-*/"
        var argument = ""
        var reversedArgument = ""
        for var indexx = index; indexx != expression.startIndex; indexx = indexx.predecessor() {
            let char = expression[indexx.predecessor()]
            if operationSet.rangeOfString("\(char)") == nil {
                reversedArgument.append(char)
            } else {
                break;
            }
        }
        
        for scalar in reversedArgument.unicodeScalars {
            argument = "\(scalar)" + argument
        }
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
    
    static func createVariables() -> [Variable] {
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
