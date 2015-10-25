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

    @IBOutlet weak var holder: UIView!
    var mainExpression: Expression!
    var expanded = false


    override func viewDidLoad() {
        super.viewDidLoad()
        mainExpression = getExpr()
        renderMainExpression()
    }

    func renderMainExpression() {
        for vieww in holder.subviews {
            vieww.removeFromSuperview()
        }
        let ret = renderExpression(mainExpression)
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

    func getExpr() -> ProductExpression {
        let x = Variable(lttr: "x")
        let y = Variable(lttr: "y")
        let z = Variable(lttr: "z")
        let xfif = ExponentExpression(bse: x, exp: 5)
        let blah = ProductExpression(elems: [x, xfif])
        var first: Expression = xfif
        if expanded {
            first = xfif.expand()
        }
        let ans = ProductExpression(elems: [first,y,z,x])
        return ans
    }


    func renderExpression(expression: Expression) -> ExpressionView {
        let currView: ExpressionView
        if let variable = expression as? Variable {
            currView = renderVariable(variable)
        } else if let expExpr = expression as? ExponentExpression {
            currView = renderSimpleExp(expExpr)
        } else {
            // almost fully generalized
            let prodExpr = expression as! ProductExpression
            currView = renderProductExp(prodExpr)
        }
        return currView
    }

    func renderVariable(variable: Variable) -> ExpressionView {
        var firstLabel = UILabel()
        firstLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        firstLabel.font = bigFont
        firstLabel.userInteractionEnabled = true
        firstLabel.text = variable.letter
        var exprView = ExpressionView()
        exprView.expression = variable
        exprView.consume(firstLabel)
        return exprView
    }

    func renderProductExp(prod: ProductExpression) -> ExpressionView {
        let pincher = SpecialPinchGestureRecognizer(target: self, action: "prodPinched:")
        pincher.expression = prod
        var panner = SpecialPanGestureRecognizer(target: self, action: "childPanned:")
        let container = UIView()
        container.setTranslatesAutoresizingMaskIntoConstraints(false)
        if prod.elements.count == 0 {
            var exprView = ExpressionView()
            exprView.expression = ProductExpression(elems: [])
            return exprView
        }

        var firstElemSet = false
        var prev = container
        for elem in prod.elements {
            let currView = renderExpression(elem)

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
                let START = CGFloat(10.0)
                let constraint = NSLayoutConstraint(
                    item: currView, attribute: .Leading,
                    relatedBy: .Equal,
                    toItem: prev, attribute: .Trailing,
                    multiplier: 1, constant: START
                )
                container.addConstraint(constraint)
                pincher.constraintSet.append(constraint)
            }
            panner.expression = elem
            panner.parentView = container
            currView.addGestureRecognizer(panner)
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
        var exprView = ExpressionView()
        exprView.expression = prod
        exprView.consume(container)
        panner.productExpression = prod

        container.addGestureRecognizer(pincher)
        return exprView
    }


    func renderSimpleExp(exp: ExponentExpression) -> ExpressionView {
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
        var exprView = ExpressionView()
        exprView.expression = exp
        exprView.consume(container)

        let tap = SpecialTapGestureRecognizer(target: self, action: "exponentTapped:")
        tap.expression = exp
        expLabel.addGestureRecognizer(tap)

        return exprView
    }

    func exponentTapped(sender: SpecialTapGestureRecognizer) {
        mainExpression = mainExpression.selfWithReplacement(sender.expression, new: (sender.expression as! ExponentExpression).expand())
        renderMainExpression()
    }

    func prodPinched(sender: SpecialPinchGestureRecognizer) {
        if sender.state == .Ended {
            mainExpression = mainExpression.selfWithReplacement(sender.expression, new: (sender.expression as! ProductExpression).contract())
            renderMainExpression()
        } else if sender.state == .Changed {
            for constraint in sender.constraintSet {
                constraint.constant = 60*sender.scale - 50
            }
        }
    }

    func childPanned(sender: SpecialPanGestureRecognizer) {
        if sender.state == .Began {
            sender.setUpViewToDistance()
            sender.view!.hidden = true
            var newCopy = renderExpression(sender.expression)
            sender.newCopyStore = newCopy
            sender.parentView.addSubview(newCopy)
            var constraintToAnimate = NSLayoutConstraint(
                item: sender.view!, attribute: .CenterY,
                relatedBy: .Equal,
                toItem: newCopy, attribute: .CenterY,
                multiplier: 1, constant: 0)
            sender.parentView.addConstraint(constraintToAnimate)
            let xCnstr = NSLayoutConstraint(
                item: newCopy, attribute: .CenterX,
                relatedBy: .Equal,
                toItem: sender.view!, attribute: .CenterX,
                multiplier: 1, constant: 0)
            sender.parentView.addConstraint(xCnstr)
            sender.parentView.layoutIfNeeded()

            sender.xConstraint = xCnstr
            constraintToAnimate.constant = 60
            UIView.animateWithDuration(Double(0.3), animations: {
                sender.parentView.layoutIfNeeded()
            })

        } else if sender.state == .Changed {
            sender.xConstraint.constant = sender.translationInView(sender.view!.superview!).x
                let newIndex = sender.indexForView(sender.newCopyStore!)
            if newIndex != sender.mostRecentIndex {
                sender.mostRecentIndex = newIndex
            }

        } else if contains([.Ended, .Failed, .Cancelled], sender.state) {
            // re arrange
            sender.view!.hidden = false
            sender.newCopyStore.removeFromSuperview()
            let initialIndex = sender.indexForView(sender.view!)
            sender.productExpression.swap(sender.mostRecentIndex!, index2: initialIndex)
            renderMainExpression()


        }

        // join where possible
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