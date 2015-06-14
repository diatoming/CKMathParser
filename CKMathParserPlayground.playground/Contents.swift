//: Playground - noun: a place where people can play

import UIKit

struct ExpressionRow {
    let id: Int
    let function: String
    let maxArg: Int
    
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

var ops = [Operation]()
var expressionTable = [ExpressionRow]()
var variablesTable = [Variable]()

func parseExpression(expr: String) {

    let parantheticalLevel = 0
    let op = ops[0]
    
    expressionTable.append(
        ExpressionRow(
            id: expressionTable.count+1,
            function: op.name,
            maxArg: op.maxArguments,
            argumentOneId: nil,
            argumentOneName: nil,
            argumentOneValue: 245,
            argumentTwoId: nil,
            argumentTwoName: nil,
            argumentTwoValue: nil,
            level: op.level + parantheticalLevel,
            sequence: nil
        )
    )
    
}

ops.append(Operation(name: "*", maxArguments: 2, level: 2))

let expression = "245*(a+b)*(a-b)+1"

parseExpression(expression)