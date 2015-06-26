//: Playground - noun: a place where people can play

import UIKit

extension String {
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

struct ExpressionRow {
    let operation: Op
    var arguments: [String?]
    let level: Int
    
    var argOf: Int?
    var sequence: Int?
    
    init(operation: Op, arguments: [String?], level: Int) {
        self.operation = operation
        self.arguments = arguments
        self.level = level
        self.argOf = nil
        self.sequence = nil
    }
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

var expressionTable = [ExpressionRow]()
var availableOperations = [String:Op]()

availableOperations["+"] = Op.BinaryOperation("+", 1, { $0 + $1 })
availableOperations["-"] = Op.BinaryOperation("-", 1, { $0 - $1 })
availableOperations["*"] = Op.BinaryOperation("*", 2, { $0 * $1 })
availableOperations["/"] = Op.BinaryOperation("/", 2, { $0 / $1 })
availableOperations["^"] = Op.BinaryOperation("^", 3, { pow($0,$1) })
availableOperations["sin"] = Op.UnaryOperation("sin", 3, { sin($0) })

let expression = "245+(2*3)+sin(30+30)"

func getLevel(functionRange: Range<String.Index>, operation: Op) -> Int {
    var level = 0
    for character in expression.substringToIndex(functionRange.startIndex).unicodeScalars {
        if character == "(" { level += 10 }
        if character == ")" { level -= 10 }
    }
    return level + operation.level
}

func getSideArgument(relevantString: String) -> String? {
    let stoppingValues = availableOperations.keys.array + ["(", ")"]
    var argument = ""
    for character in relevantString.unicodeScalars {
        if !stoppingValues.contains("\(character)") {
            argument.append(character)
        } else { break; }
    }
    argument
}

func getArguments(functionRange: Range<String.Index>, operation: Op) -> [String?] {
    switch operation {
    case .BinaryOperation:
        let startOfExpression = expression.substringToIndex(functionRange.startIndex).reverse()
        
        leftArgument = getSideArgument(expression.substringToIndex(functionRange.startIndex).reverse())
        
        let restOfExpression = expression.substringFromIndex(functionRange.endIndex)
        

        return [nil, nil]
    case .UnaryOperation:
//        let restOfExpression = expression.substringFromIndex(functionRange.endIndex.successor())
//        let relevantExpression = restOfExpression.substringToIndex(restOfExpression.rangeOfString(")")!.startIndex)
        return [nil]
        
    }
}

// Remove unary minuses from ranges
// Get arguments
func createExpressionTable() {
    
    //Gets function ranges and sorts them into order of use in expression
    var ranges = [Range<String.Index>]()
    for operation in availableOperations.keys {
        if let unsortedRanges = expression.rangesOfString(operation) {
            for range in unsortedRanges {
                ranges.append(range)
            }
        }
    }
    
    ranges = ranges.sort({ $0.startIndex < $1.startIndex})
    
    
    for range in ranges {
        let operation = availableOperations[expression[range]]!
        expressionTable.append(ExpressionRow(operation: operation, arguments: getArguments(range, operation: operation), level: getLevel(range, operation: operation)))
    }
    
    
}

//let expression = "245+(2*3)+sin(30+30)"

createExpressionTable()
expressionTable[2].arguments







