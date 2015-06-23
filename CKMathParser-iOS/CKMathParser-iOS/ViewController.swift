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

    @IBAction func evaluate(sender: UIButton) {
        var times = [CFAbsoluteTime]()
        var solution = ""
        for _ in 1...1000 {
            let expression = inputTextField.text!
            let startTime = CFAbsoluteTimeGetCurrent()
            solution = CKMathParser().evaluate(expression)
            let endTime = CFAbsoluteTimeGetCurrent()
            times.append(endTime-startTime)
        }
        var sum = 0.0
        for val in times {
            sum += val
        }
        textView.text = textView.text + "\n\(sum/Double(times.count))"
        outputLabel.text = solution
    }

}

