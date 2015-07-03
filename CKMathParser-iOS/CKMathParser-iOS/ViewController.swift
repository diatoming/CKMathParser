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
    
    @IBAction func evaluate(sender: UIButton) {
        let expression = "(4+8)/4+(2+3*4)^2-3^4+(9+10)-(15-21)+7*(17-15)"//"a+b*(c-d+(e^f))/sin(g)"
        
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

}

