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
    var testExpressions = [String:String]()

    override func viewDidLoad() {
        testExpressions["1+4"] = "5.0"
        testExpressions["1-4"] = "-3.0"
        testExpressions["1*4"] = "4.0"
        testExpressions["1/4"] = "0.25"
        testExpressions["1+2-3*4/5"] = "0.6"
        testExpressions["     1+2    *3"] = "7.0"
        testExpressions["(4+8)/4 + (2+3*4)^2 - 3^4 + (9+10)*(15-21) + 7*(17-15)"] = "18.0"
        testExpressions["-1+2"] = "1.0"
    }
    
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
        for (expression, answer) in testExpressions {
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

