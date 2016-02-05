//
//  ExpressionVC.swift
//  HandsOnMath
//
//  Created by Michael Lipman on 10/24/15.
//  Copyright (c) 2015 HackingEDUGroup. All rights reserved.
//

import UIKit

class ExpressionVC: UIViewController {
    var bigFont = UIFont.systemFontOfSize(100)
    var smallFont = UIFont.systemFontOfSize(60)
    var mainHolder: UIView!
    var tempHolder: UIView!
    var mainExpression: Expression!

    override func viewDidLoad() {
        super.viewDidLoad()

        mainHolder = UIView()
        view.addSubview(mainHolder)
        mainHolder.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(
            item: mainHolder, attribute: .CenterY,
            relatedBy: .Equal,
            toItem: view, attribute: .CenterY,
            multiplier: 1, constant: 0
        ))
        view.addConstraint(NSLayoutConstraint(
            item: mainHolder, attribute: .CenterX,
            relatedBy: .Equal,
            toItem: view, attribute: .CenterX,
            multiplier: 1, constant: 0
        ))

        // different widths of elements might mess up indexForView stuff
        tempHolder = UIView()
        view.addSubview(tempHolder)
        tempHolder.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(
            item: tempHolder, attribute: .CenterY,
            relatedBy: .Equal,
            toItem: view, attribute: .CenterY,
            multiplier: 1, constant: 0
        ))
        view.addConstraint(NSLayoutConstraint(
            item: tempHolder, attribute: .CenterX,
            relatedBy: .Equal,
            toItem: view, attribute: .CenterX,
            multiplier: 1, constant: 0
        ))

        mainExpression = getExpr()
        render(mainExpression, holder: mainHolder)
    }

    func render(expr: Expression, holder: UIView) {
        // Backbone: ret = new ExpressionView({model: mainExpression}).render()
        let ret = renderExpression(expr)

        // Backbone: $(holder).html(ret.$el)
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
        let letters = ["x", "y", "z", "w"]
        var terms = [UnitExpression]()
        for _ in 0..<5 {
            let i = Int(arc4random())%letters.count
            let variable = Variable(lttr: letters[i])
            if (Int(arc4random())%2 == 0) {
                terms.append(variable)
            } else {
                let exponent = Int(arc4random())%4 + 2
                terms.append(
                    ExponentExpression(bse: variable, exp: exponent)
                )
            }
        }
        return ProductExpression(elems: terms)
    }


    func renderExpression(expression: Expression) -> ExpressionView {
        let currView: ExpressionView
        if let variable = expression as? Variable {
            currView = renderVariable(variable)
        } else if let expExpr = expression as? ExponentExpression {
            // TODO support complex exponent expressions
            currView = renderSimpleExp(expExpr)
        } else if let _ = expression as? Blank {
            currView = renderBlankExpression()
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

    func renderBlankExpression() -> ExpressionView {
        let firstLabel = UILabel()
        firstLabel.translatesAutoresizingMaskIntoConstraints = false
        firstLabel.font = bigFont
        firstLabel.text = "_"
        let exprView = ExpressionView()
        exprView.consume(firstLabel)
        return exprView
    }

    func renderProductExp(prod: ProductExpression) -> ExpressionView {
        let container = ProductExpressionView()
        container.expression = prod
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
            let panner = UIPanGestureRecognizer(
                target: self, action: "childPanned:")
            let currView = renderExpression(elem)
            currView.productExpression = prod
            currView.placeInParent = prod.elements.indexOf({$0 === elem})!
            currView.vcview = self.view
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
                if let indicator = container.startedIndicator {
                    indicator.horizontalConstraints.append(constraint)
                }
            }

            currView.expression = elem
            currView.myParentView = container
            currView.addGestureRecognizer(panner)
            firstElemSet = true
            prev = currView

            if elem.isStart {
                let indicator = IndicatorView()
                indicator.productExpressionView = container
                container.startedIndicator = indicator
                indicator.start = currView.placeInParent
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
                let verticalDistance = NSLayoutConstraint(
                    item: indicator, attribute: .Top,
                    relatedBy: .Equal,
                    toItem: currView, attribute: .Bottom,
                    multiplier: 1, constant: 0
                )
                container.addConstraint(verticalDistance)
                indicator.verticalDistance = verticalDistance
                let leadingDistance = NSLayoutConstraint(
                    item: indicator, attribute: .Leading,
                    relatedBy: .Equal,
                    toItem: currView, attribute: .Leading,
                    multiplier: 1, constant: 0
                )
                container.addConstraint(leadingDistance)
                container.startedIndicator!.leadingDistance = leadingDistance

                indicator.addGestureRecognizer(
                    UIPanGestureRecognizer(target: self, action: "pannedIndicator:")
                )
                indicator.addGestureRecognizer(
                    UITapGestureRecognizer(target: self, action: "tappedIndicator:")
                )
            }

            if elem.isEnd {
                container.startedIndicator!.end = currView.placeInParent
                let trailingDistance = NSLayoutConstraint(
                    item: container.startedIndicator!, attribute: .Trailing,
                    relatedBy: .Equal,
                    toItem: currView, attribute: .Trailing,
                    multiplier: 1, constant: 0
                )
                container.addConstraint(trailingDistance)
                container.startedIndicator!.trailingDistance = trailingDistance
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

        return container
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

        exprView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: "exponentTapped:")
        )

        return exprView
    }


    /*
    func prodPinched(sender: SpecialPinchGestureRecognizer) {
        let expString = (sender.view! as! ExpressionView).expression.to_string()
        print("\(expString) pinched")
        if sender.state == .Ended {
            //mainExpression = mainExpression.selfWithReplacement(
                sender.expression, new: (sender.expression as! ProductExpression).contract())
            renderMainExpressionInHolder()
        } else if sender.state == .Changed {
            for constraint in sender.constraintSet {
                constraint.constant = 60*sender.scale - 50
            }
        }
    }
    */

    // should move this into ViewLogic file
    func childPanned(sender: UIPanGestureRecognizer) {
        let panned = sender.view as! ExpressionView
        if sender.state == .Began {
            panned.setUpViewToDistance()
            let newCopy = renderExpression(panned.expression)
            panned.newCopyStore = newCopy
            self.view.addSubview(newCopy)
            
            let xCnstr = NSLayoutConstraint(
                item: newCopy, attribute: .CenterX,
                relatedBy: .Equal,
                toItem: panned, attribute: .CenterX,
                multiplier: 1, constant: 0)
            let yCnstr = NSLayoutConstraint(
                item: newCopy, attribute: .CenterY,
                relatedBy: .Equal,
                toItem: panned, attribute: .CenterY,
                multiplier: 1, constant: 0)
            view.addConstraint(xCnstr)
            view.addConstraint(yCnstr)

            panned.xConstraint = xCnstr
            panned.yConstraint = yCnstr
            view.layoutIfNeeded()

            mainHolder.hidden = true
            tempHolder.hidden = false
            let mainProductExp = mainExpression as! ProductExpression
            let place = panned.placeInParent
            let newView = mainProductExp.moveElem(place, toBlankAt: place)
            render(newView, holder: tempHolder)

        } else if sender.state == .Changed {
            panned.xConstraint.constant = sender.translationInView(sender.view!.superview!).x
            panned.yConstraint.constant = sender.translationInView(sender.view!.superview!).y
            let newIndex = panned.indexForView(panned.newCopyStore!)
            if newIndex != panned.mostRecentIndex {
                panned.mostRecentIndex = newIndex
                let mainProductExp = mainExpression as! ProductExpression
                let newView = mainProductExp.moveElem(panned.placeInParent, toBlankAt:newIndex)
                render(newView, holder: tempHolder)
                
            }
            panned.myParentView.layoutIfNeeded()

        } else if [.Ended, .Failed, .Cancelled].contains(sender.state) {
            panned.productExpression.jumpTo(
                panned.mostRecentIndex!, from: panned.placeInParent)
            render(mainExpression, holder: mainHolder)
            panned.newCopyStore.removeFromSuperview()
            mainHolder.hidden = false
            tempHolder.hidden = true
            // TODO: get animation working, need to find position to animate to
        }
    }

    func pannedIndicator(sender: UIPanGestureRecognizer) {
        let DRAG_LENGTH: CGFloat = 100.0
        let indicator = sender.view as! IndicatorView
        let parent = indicator.productExpressionView
        if indicator.initialWidth == nil {
            indicator.initialWidth = indicator.frame.size.width
        }

        switch sender.state {
        case .Changed:
            let yChange = sender.translationInView(parent).y
            if yChange > DRAG_LENGTH {
                let indicator = sender.view as! IndicatorView
                let prod = indicator.productExpressionView.expression as! ProductExpression
                prod.contractSlice(indicator.start, end: indicator.end)
                render(prod, holder: mainHolder)
            } else if yChange > 0 {
                // bug / weird behavior: longer than initial width at end of drag
                let adjustment = (yChange/DRAG_LENGTH)*indicator.initialWidth!*0.4
                indicator.verticalDistance.constant = yChange
                indicator.leadingDistance.constant = adjustment
                indicator.trailingDistance.constant = -1*adjustment
                for constraint in indicator.horizontalConstraints {
                    // put 10 as start in indicatorview class
                    constraint.constant = 10 - 50*(yChange/DRAG_LENGTH)
                }
            } else {
                indicator.verticalDistance.constant = 0
                indicator.leadingDistance.constant = 0
                indicator.trailingDistance.constant = 0
                for constraint in indicator.horizontalConstraints {
                    // put 10 as start in indicatorview class
                    constraint.constant = 10
                }
            }
        case .Ended:
            indicator.verticalDistance.constant = 0
            indicator.leadingDistance.constant = 0
            indicator.trailingDistance.constant = 0
            for constraint in indicator.horizontalConstraints {
                // put 10 as start in indicatorview class
                constraint.constant = 10
            }
        case .Began, .Possible, .Failed, .Cancelled:
            break
        }

    }

    func tappedIndicator(sender: UITapGestureRecognizer) {
        // get indicator to bounce down and up, animiation not working
        /*
        let indicator = sender.view as! IndicatorView
        indicator.verticalDistance.constant = 80
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            indicator.setNeedsDisplay()
        }, completion: { (completed) -> Void in
            print("Done \(completed)")
            //indicator.verticalDistance.constant = 0
            UIView.animateWithDuration(0.500, animations: { () -> Void in
                indicator.setNeedsDisplay()
            })
        })
        */

    }

    // refactor: the expression view would call expand on its parent
    // instead of assuming the global mainExpression is the parent
    func exponentTapped(sender: UITapGestureRecognizer) {
        let expressionView = sender.view as! ExpressionView
        let exponentExpression  = expressionView.expression as! ExponentExpression
        (mainExpression as! ProductExpression).expand(exponentExpression)
        render(mainExpression, holder: mainHolder)
    }

}

