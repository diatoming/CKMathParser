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
        var solution = ""
        let expression = "245+(2*3)/sin(30+30)-14"        
        let startTime = CFAbsoluteTimeGetCurrent()
        solution = CKMathParser().evaluate(expression)
        let endTime = CFAbsoluteTimeGetCurrent()
        
        textView.text = textView.text + "\n\(endTime-startTime))"
        outputLabel.text = solution
    }

}

