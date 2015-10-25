//
//  ViewController.swift
//  HandsOnMath
//
//  Created by Michael Lipman on 10/24/15.
//  Copyright (c) 2015 HackingEDUGroup. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var bigFont = UIFont.systemFontOfSize(100)
    var smallFont = UIFont.systemFontOfSize(60)


    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var fiveLabel: UILabel!
    @IBOutlet weak var holder: UIView!


    override func viewDidLoad() {
        super.viewDidLoad()
        let x = Variable(lttr: "x")
        let y = Variable(lttr: "y")
        let z = Variable(lttr: "z")

        let xfif = ExponentExpression(bse: x, exp: 5)
        let blah = ProductExpression(elems: [x, xfif])
        let xxxxpand = xfif.expand()
        let xxpand = ProductExpression(elems: [xfif,y,z,x])

        /*
        println("x is " + x.description())
        println("xfif is " + xfif.description())
        println("blah is " + blah.description())
        println("xxpand is " + xxpand.description())
        */

        //let go = ExponentExpression(bse: Variable(lttr: "r"), exp: 9)
        xLabel.hidden = true
        fiveLabel.hidden = true
        let ret = renderProductExp(xxpand)
        holder.addSubview(ret)
        holder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[ret]|",
            options: nil,
            metrics: nil,
            views: [
                "ret": ret
            ])
        )
        holder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[ret]|",
            options: nil,
            metrics: nil,
            views: [
                "ret": ret
            ])
        )
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

    func renderVariable(variable: Variable) -> UIView {
        var firstLabel = UILabel()
        firstLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        firstLabel.font = bigFont
        firstLabel.userInteractionEnabled = true
        firstLabel.text = variable.letter
        return firstLabel
    }

    func renderProductExp(prod: ProductExpression) -> UIView {
        let container = UIView()
        container.setTranslatesAutoresizingMaskIntoConstraints(false)
        if prod.elements.count == 0 {
            return UIView()
        }

        var firstElemSet = false
        var prev = container
        for elem in prod.elements {
            let currView: UIView
            if let variable = elem as? Variable {
                currView = renderVariable(variable)
            } else {
                // will probably eventually call expression.render on firstElem
                let expExpr = elem as! ExponentExpression
                currView = renderSimpleExp(expExpr)
            }

            container.addSubview(currView)

            container.addConstraint(NSLayoutConstraint(
                item: currView, attribute: .CenterY,
                relatedBy: .Equal,
                toItem: prev, attribute: .CenterY,
                multiplier: 1, constant: 0))
            if !firstElemSet {
                container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:|[curr]|",
                    options: nil,
                    metrics: nil,
                    views: [
                        "curr": currView
                    ])
                )
                container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:|[curr]",
                    options: nil,
                    metrics: ["space": 10],
                    views: [
                        "prev": prev,
                        "curr": currView
                    ])
                )
            } else {
                container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:[prev]-(space)-[curr]",
                    options: nil,
                    metrics: ["space": 10],
                    views: [
                        "prev": prev,
                        "curr": currView
                    ])
                )
            }
            firstElemSet = true
            prev = currView
        }
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[last]|",
            options: nil,
            metrics: nil,
            views: [
                "last": prev
            ])
        )
        return container
    }


    func renderSimpleExp(exp: ExponentExpression) -> UIView {
        let container = UIView()
        container.setTranslatesAutoresizingMaskIntoConstraints(false)
        let simpleBase = exp.base as! Variable
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
            "V:|[base]|",
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
        return container
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