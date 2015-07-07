//
//  ViewController.swift
//  CKMathParser-iOS
//
//  Created by Connor Krupp on 6/13/15.
//  Copyright © 2015 Connor Krupp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var textView: UITextView!

    let mathParser = CKMathParser()
    let mathParserTests = CKMathParserTests()
    
    @IBAction func evaluate(sender: UIButton) {
        let expression = inputTextField.text!
        
        let solution = CKMathParser().evaluate(expression)
        
        textView.text = textView.text + "\n\(expression)"
        
        if let result = solution.result {
            outputLabel.text = result.toString()
        } else {
            if let error = solution.error {
                outputLabel.text = error
            } else {
                outputLabel.text = "Error: Unknown"
            }
        }
    }

    @IBAction func runTests(sender: UIButton) {
        var wasErrors = false
        for (expression, answer) in mathParserTests.testExpressions {
            if let result = CKMathParser().evaluate(expression).result {
                if result.toString() != answer {
                    textView.text = textView.text + "\n\(expression): Was: \(result), Should be: \(answer)"
                    wasErrors = true
                }
            }
        }
        if !wasErrors {
            textView.text = "All Tests Successful"
        }
    }
}

