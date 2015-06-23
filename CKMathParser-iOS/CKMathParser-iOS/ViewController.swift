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

    @IBAction func evaluate(sender: UIButton) {
        let expression = inputTextField.text!
        outputLabel.text = CKMathParser().evaluate(expression)
    }

}

