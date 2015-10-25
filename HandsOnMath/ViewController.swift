//
//  ViewController.swift
//  HandsOnMath
//
//  Created by Michael Lipman on 10/24/15.
//  Copyright (c) 2015 HackingEDUGroup. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var bigFont = UIFont.systemFontOfSize(48)
    var smallFont = UIFont.systemFontOfSize(30)


    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var fiveLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        let x = Variable(lttr: "x")
        let xfif = ExponentExpression(bse: x, exp: 5)
        let blah = ProductExpression(elems: [x, xfif])
        let xxpand = xfif.expand()

        /*
        println("x is " + x.description())
        println("xfif is " + xfif.description())
        println("blah is " + blah.description())
        println("xxpand is " + xxpand.description())
        */

        let go = ExponentExpression(bse: Variable(lttr: "z"), exp: 5)
        xLabel.hidden = true
        fiveLabel.hidden = true
        renderExpression(go)
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

    func renderExpression(expr: Expression) {
        let container = UIView()
        var ahh: UIView!
        container.setTranslatesAutoresizingMaskIntoConstraints(false)
        if let exp = expr as? ExponentExpression {
            if let simpleBase = exp.base as? Variable {
                let baseLabel = UILabel()
                baseLabel.userInteractionEnabled = true
                baseLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
                baseLabel.text = simpleBase.letter
                baseLabel.font = bigFont
                let expLabel = UILabel()
                expLabel.text = String(exp.exponent)
                expLabel.userInteractionEnabled = true
                expLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
                expLabel.font = smallFont

                container.addSubview(baseLabel)
                container.addSubview(expLabel)
                container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:|[exp]",
                    options: nil,
                    metrics: nil,
                    views: [
                        "exp": expLabel
                    ])
                )
                container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:|[base]",
                    options: nil,
                    metrics: nil,
                    views: [
                        "base": baseLabel
                    ])
                )
                container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:|[base][exp]|",
                    options: nil,
                    metrics: nil,
                    views: [
                        "base": baseLabel,
                        "exp": expLabel
                    ])
                )

                view.addSubview(container)
                //view.addSubview(expLabel)
                view.addConstraint(NSLayoutConstraint(
                    item: view, attribute: .CenterY,
                    relatedBy: .Equal,
                    toItem: container, attribute: .CenterY,
                    multiplier: 1, constant: 0
                ))
                view.addConstraint(NSLayoutConstraint(
                    item: view, attribute: .CenterX,
                    relatedBy: .Equal,
                    toItem: container, attribute: .CenterX,
                    multiplier: 1, constant: 0
                ))
                ahh = expLabel
            }
        }

        println("container's constraints is")
        println(ahh)
        println("that was container")
        view.setNeedsLayout()
    }

}

/*
calculatorbrain has a divisorofexpression
whcich has a numeratorexp and denominator exp

numeratorexp is an expression (abstract)

can be either expexpression or product expression

exp has an expression as base and an integer exponent


product expression has an array of expressions


important actions:
exp expression can be expanded: base^exp becomes product expression of length exp, with base as all elements


complex:
product expressions can of course be nested
after an action, if a product expression is next to another, they combine
maybe: group: start underneath or at group button, drag within product to group

product expressions should be analyzed for chains, they







*/