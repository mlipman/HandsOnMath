//
//  ViewController.swift
//  HandsOnMath
//
//  Created by Michael Lipman on 10/24/15.
//  Copyright (c) 2015 HackingEDUGroup. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var fiveLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func tappedFive(sender: UITapGestureRecognizer) {
        if (sender.state == .Ended) {
            sender.view!.hidden = true
            let repeatText = "x"
            for _ in 1..<5 {
                xLabel.text = (xLabel.text ?? "") + "•" + repeatText
            }
        }
    }
    @IBAction func didPinchX(sender: UITapGestureRecognizer) {
        if (sender.state == .Ended) {
            let x = sender.view as! UILabel
            if (x.text! == "x•x•x•x•x") {
                x.text = "x"
                fiveLabel.hidden = false
            }
        }
    }

}

