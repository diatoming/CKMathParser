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
        
        return "hello"
    }
    
    init() {
        
        availableOperations["+"] = Op.BinaryOperation("+", 1, { $0 + $1 })
        availableOperations["-"] = Op.BinaryOperation("-", 1, { $0 - $1 })
        availableOperations["*"] = Op.BinaryOperation("*", 2, { $0 * $1 })
        availableOperations["/"] = Op.BinaryOperation("/", 2, { $0 / $1 })
        availableOperations["^"] = Op.BinaryOperation("^", 3, { pow($0,$1) })
        availableOperations["sin"] = Op.UnaryOperation("sin", 3, { sin($0) })

        availableConstants["π"] = Constant(name: "π", value: M_1_PI)
        availableConstants["e"] = Constant(name: "e", value: M_E)
    }
    
    //
    // Generates the inital expression table values
    //
    private func createExpressionTable() {
        
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
        return nil
    }
    
    func getArguments(functionRange: Range<String.Index>, operation: Op) -> [String?] {
        switch operation {
        case .BinaryOperation:
            let startOfExpression = expression.substringToIndex(functionRange.startIndex).reverse()
            
            let leftArgument = getSideArgument(expression.substringToIndex(functionRange.startIndex).reverse())
            
            let restOfExpression = expression.substringFromIndex(functionRange.endIndex)
            
            
            return [nil, nil]
        case .UnaryOperation:
            //        let restOfExpression = expression.substringFromIndex(functionRange.endIndex.successor())
            //        let relevantExpression = restOfExpression.substringToIndex(restOfExpression.rangeOfString(")")!.startIndex)
            return [nil]
            
        }
    }
    
    //
    //  Figures out the argOfs for the rows
    //
//    private func buildExpressionRelationships() {
//        for _ in expressionTable {
//            var largestIndex = 0
//            var largestLevel = 0
//            for (index, row) in expressionTable.enumerate() {
//                if row.level > largestLevel && row.argOf == nil {
//                    largestIndex = index
//                    largestLevel = row.level
//                }
//            }
//            
//            var upperLevel: Int?
//            var lowerLevel: Int?
//            var upperI = 1
//            var lowerI = 1
//            
//            while largestIndex-upperI >= 0 {
//                if expressionTable[largestIndex-upperI].argOf == nil {
//                    upperLevel = expressionTable[largestIndex-upperI].level
//                    break
//                }
//                upperI++
//            }
//            while largestIndex+lowerI < expressionTable.count {
//                if expressionTable[largestIndex+lowerI].argOf == nil {
//                    lowerLevel = expressionTable[largestIndex+lowerI].level
//                    break
//                }
//                lowerI++
//            }
//            
//            if upperLevel > lowerLevel {
//                expressionTable[largestIndex].argOf = largestIndex-upperI
//            } else if upperLevel < lowerLevel {
//                expressionTable[largestIndex].argOf = largestIndex+lowerI
//            } else if upperLevel == lowerLevel && upperLevel != nil && lowerLevel != nil {
//                expressionTable[largestIndex].argOf = largestIndex-upperI
//            }
//
//        }
//    }
    
    //
    // Builds the sequence of operations
    //
//    private func calculateSequence() {
//        for _ in expressionTable {
//            var largestLevel = 0
//            var largestIndex = 0
//            
//            for (index, row) in expressionTable.enumerate() {
//                if row.level > largestLevel && !sequenceOfOperation.contains(index) {
//                    largestLevel = row.level
//                    largestIndex = index
//                }
//            }
//            sequenceOfOperation.append(largestIndex)
//            
//        }
//    }
    
    //
    // Evaluates the table
    //
//    private func evaluateExpression() -> Double {
//        for index in sequenceOfOperation {
//            let row = expressionTable[index]
//            var solution = 0.0
//            let operation = availableOperations[row.function]!
//            switch operation {
//            case .UnaryOperation(_, _, let function):
//                solution = function(row.argumentOneValue!)
//            case .BinaryOperation(_, _, let function):
//                solution = function(row.argumentOneValue!, row.argumentTwoValue!)
//            }
//           
//            if let argumentRowIndex = row.argOf {
//                if index > argumentRowIndex {
//                    expressionTable[argumentRowIndex].argumentTwoValue = solution
//                } else {
//                    expressionTable[argumentRowIndex].argumentOneValue = solution
//                }
//            } else {
//                return solution
//            }
//        
//        }
//        return 0
//    }
    
}

