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


    override func viewDidLoad() {
        super.viewDidLoad()
        mainExpression = getExpr()
        renderMainExpressionInHolder()
    }


    func renderMainExpressionInHolder() {
        // ret = new ExpressionView({model: mainExpression}).render()
        let ret = renderExpression(mainExpression)

        // $(holder).html(ret.$el)
        for vieww in holder.subviews {
            vieww.removeFromSuperview()
        }
        holder.addSubview(ret)
        holder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[ret]|",
            options: [],
            metrics: nil,
            views: [
                "ret": ret
            ])
        )
        holder.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[ret]|",
            options: [],
            metrics: nil,
            views: [
                "ret": ret
            ])
        )
    }

    func getExpr() -> ProductExpression {
        let x = Variable(lttr: "x")
        let x2 = Variable(lttr: "x")
        let x3 = Variable(lttr: "x")
        let x4 = Variable(lttr: "x")
        let y = Variable(lttr: "y")
        let y2 = Variable(lttr: "y")
        let z = Variable(lttr: "z")
        let xtothe5 = ExponentExpression(bse: x, exp: 5)
        let ans = ProductExpression(elems: [z,x,xtothe5,x2,x3,x4,y,y2])
        return ans
    }


    func renderExpression(expression: Expression) -> ExpressionView {
        let currView: ExpressionView
        if let variable = expression as? Variable {
            currView = renderVariable(variable)
        } else if let expExpr = expression as? ExponentExpression {
            // TODO support complex exponent expressions
            currView = renderSimpleExp(expExpr)
        } else {
            // almost fully generalized
            let prodExpr = expression as! ProductExpression
            currView = renderProductExp(prodExpr)
        }
        return currView
    }

    func renderVariable(variable: Variable) -> ExpressionView {
        let firstLabel = UILabel()
        firstLabel.translatesAutoresizingMaskIntoConstraints = false
        firstLabel.font = bigFont
        firstLabel.userInteractionEnabled = true
        firstLabel.text = variable.letter
        let exprView = ExpressionView()
        exprView.expression = variable
        exprView.consume(firstLabel)
        return exprView
    }

    func renderProductExp(prod: ProductExpression) -> ExpressionView {
        let container = ProductExpressionView()
        container.translatesAutoresizingMaskIntoConstraints = false
        if prod.elements.count == 0 {
            // not sure why this is necessary
            let exprView = ExpressionView()
            exprView.expression = ProductExpression(elems: [])
            return exprView
        }

        var firstElemSet = false
        var prev = container as ExpressionView
        for elem in prod.elements {
            let panner = SpecialPanGestureRecognizer(target: self, action: "childPanned:")
            panner.productExpression = prod
            let currView = renderExpression(elem)
            container.addSubview(currView)

            container.addConstraint(NSLayoutConstraint(
                item: currView, attribute: .Top,
                relatedBy: .Equal,
                toItem: prev, attribute: .Top,
                multiplier: 1, constant: 0))
            if !firstElemSet {
                container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:|[curr]-25-|",
                    options: [],
                    metrics: [:],
                    views: [
                        "curr": currView
                    ])
                )
                container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:|[curr]",
                    options: [],
                    metrics: [:],
                    views: [
                        "curr": currView
                    ]))
            } else {
                let START = CGFloat(10.0) // distance between factors in a product
                let constraint = NSLayoutConstraint(
                    item: currView, attribute: .Leading,
                    relatedBy: .Equal,
                    toItem: prev, attribute: .Trailing,
                    multiplier: 1, constant: START
                )
                container.addConstraint(constraint)
                //pincher.constraintSet.append(constraint)
            }
            panner.expression = elem
            panner.parentView = container
            currView.addGestureRecognizer(panner)
            firstElemSet = true
            prev = currView

            if elem.isStart {
                let indicator = IndicatorView()
                indicator.translatesAutoresizingMaskIntoConstraints = false
                container.addSubview(indicator)
                indicator.backgroundColor = UIColor.blueColor()
                indicator.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:[indicator(20)]",
                    options: [],
                    metrics: [:],
                    views: [
                        "indicator": indicator
                    ]))
                container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:[currView][indicator]",
                    options: [],
                    metrics: [:],
                    views: [
                        "indicator": indicator,
                        "currView": currView
                    ]))
                container.addConstraint(NSLayoutConstraint(
                    item: indicator, attribute: .Leading,
                    relatedBy: .Equal,
                    toItem: currView, attribute: .Leading,
                    multiplier: 1, constant: 0))
                container.startedIndicator = indicator

            }
            if elem.isEnd {
                container.addConstraint(NSLayoutConstraint(
                    item: container.startedIndicator!, attribute: .Trailing,
                    relatedBy: .Equal,
                    toItem: currView, attribute: .Trailing,
                    multiplier: 1, constant: 0))
                container.startedIndicator = nil
            }
        }
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[last]|",
            options: [],
            metrics: nil,
            views: [
                "last": prev
            ])
        )
        let exprView = ExpressionView()
        exprView.expression = prod
        exprView.consume(container)

        //container.addGestureRecognizer(pincher)


        // for each eligible range in the product expression
        // add a view containing those children
        // and that view should have indicators on the bottom corners
        // and a pinch recognizer



        return exprView
    }


    func renderSimpleExp(exp: ExponentExpression) -> ExpressionView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        let simpleBase = exp.base as! Variable
        let baseLabel = UILabel()
        baseLabel.userInteractionEnabled = true
        baseLabel.translatesAutoresizingMaskIntoConstraints = false
        baseLabel.text = simpleBase.letter
        baseLabel.font = bigFont
        let expLabel = UILabel()
        expLabel.text = String(exp.exponent)
        expLabel.userInteractionEnabled = true
        expLabel.translatesAutoresizingMaskIntoConstraints = false
        expLabel.font = smallFont

        container.addSubview(baseLabel)
        container.addSubview(expLabel)
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[exp]",
            options: [],
            metrics: nil,
            views: [
                "exp": expLabel
            ])
        )
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[base]|",
            options: [],
            metrics: nil,
            views: [
                "base": baseLabel
            ])
        )
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[base][exp]|",
            options: [],
            metrics: nil,
            views: [
                "base": baseLabel,
                "exp": expLabel
            ])
        )
        let exprView = ExpressionView()
        exprView.expression = exp
        exprView.consume(container)


        let tap = SpecialTapGestureRecognizer(target: self, action: "exponentTapped:")
        tap.expression = exp
        exprView.addGestureRecognizer(tap)

        return exprView
    }

    func exponentTapped(sender: SpecialTapGestureRecognizer) {
        //mainExpression = mainExpression.selfWithReplacement(sender.expression, new: (sender.expression as! ExponentExpression).expand())
        renderMainExpressionInHolder()
    }

    /*
    func prodPinched(sender: SpecialPinchGestureRecognizer) {
        let expString = (sender.view! as! ExpressionView).expression.to_string()
        print("\(expString) pinched")
        if sender.state == .Ended {
            //mainExpression = mainExpression.selfWithReplacement(sender.expression, new: (sender.expression as! ProductExpression).contract())
            renderMainExpressionInHolder()
        } else if sender.state == .Changed {
            for constraint in sender.constraintSet {
                constraint.constant = 60*sender.scale - 50
            }
        }
    }
    */

    func childPanned(sender: SpecialPanGestureRecognizer) {
        if sender.state == .Began {
            sender.setUpViewToDistance()
            sender.view!.hidden = true
            let newCopy = renderExpression(sender.expression)
            sender.newCopyStore = newCopy
            sender.parentView.addSubview(newCopy)

            let xCnstr = NSLayoutConstraint(
                item: newCopy, attribute: .CenterX,
                relatedBy: .Equal,
                toItem: sender.view!, attribute: .CenterX,
                multiplier: 1, constant: 0)
            let yCnstr = NSLayoutConstraint(
                item: newCopy, attribute: .CenterY,
                relatedBy: .Equal,
                toItem: sender.view!, attribute: .CenterY,
                multiplier: 1, constant: 0)
            sender.parentView.addConstraint(xCnstr)
            sender.parentView.addConstraint(yCnstr)

            sender.xConstraint = xCnstr
            sender.yConstraint = yCnstr
            sender.parentView.layoutIfNeeded()


        } else if sender.state == .Changed {
            sender.xConstraint.constant = sender.translationInView(sender.view!.superview!).x
            sender.yConstraint.constant = sender.translationInView(sender.view!.superview!).y
            // indexForView will ignore the range marker views,
            // and figure out the real index in the expression
            let newIndex = sender.indexForView(sender.newCopyStore!)
            print(newIndex)
            if newIndex != sender.mostRecentIndex {
                sender.mostRecentIndex = newIndex
                // rerender with hole (and don't kill newCopy)
            }
            sender.parentView.layoutIfNeeded()


        } else if [.Ended, .Failed, .Cancelled].contains(sender.state) {
            // todo: animate to new position
            UIView.animateWithDuration(Double(0.4),
                animations: { () -> Void in
                    sender.parentView.layoutIfNeeded()
                },
                completion: { (completed: Bool) -> Void in
                    let initialIndex = sender.indexForView(sender.view!)
                    sender.productExpression.jumpTo(sender.mostRecentIndex!, from: initialIndex)
                    sender.view!.hidden = false
                    sender.newCopyStore.removeFromSuperview()
                    self.renderMainExpressionInHolder()

            })

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