//
//  ExpressionVC.swift
//  HandsOnMath
//
//  Created by Michael Lipman on 10/24/15.
//  Copyright (c) 2015 HackingEDUGroup. All rights reserved.
//

import UIKit

class ExpressionVC: UIViewController {
    var bigFont = UIFont.systemFont(ofSize: 100)
    var smallFont = UIFont.systemFont(ofSize: 60)
    var mainHolder: UIView!
    var tempHolder: UIView!
    var mainExpression: Expression!

    override func viewDidLoad() {
        super.viewDidLoad()

        mainHolder = UIView()
        view.addSubview(mainHolder)
        mainHolder.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(
            item: mainHolder, attribute: .centerY,
            relatedBy: .equal,
            toItem: view, attribute: .centerY,
            multiplier: 1, constant: 0
        ))
        view.addConstraint(NSLayoutConstraint(
            item: mainHolder, attribute: .centerX,
            relatedBy: .equal,
            toItem: view, attribute: .centerX,
            multiplier: 1, constant: 0
        ))

        // different widths of elements might mess up indexForView stuff
        tempHolder = UIView()
        view.addSubview(tempHolder)
        tempHolder.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(
            item: tempHolder, attribute: .centerY,
            relatedBy: .equal,
            toItem: view, attribute: .centerY,
            multiplier: 1, constant: 0
        ))
        view.addConstraint(NSLayoutConstraint(
            item: tempHolder, attribute: .centerX,
            relatedBy: .equal,
            toItem: view, attribute: .centerX,
            multiplier: 1, constant: 0
        ))

        mainExpression = getExpr()
        render(expr: mainExpression, holder: mainHolder)
    }

    func render(expr: Expression, holder: UIView) {
        // Backbone: ret = new ExpressionView({model: mainExpression}).render()
        let ret = renderExpression(expression: expr)

        // Backbone: $(holder).html(ret.$el)
        for vieww in holder.subviews {
            vieww.removeFromSuperview()
        }
        holder.addSubview(ret)
        holder.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[ret]|",
            options: [],
            metrics: nil,
            views: [
                "ret": ret
            ])
        )
        holder.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[ret]|",
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
            currView = renderVariable(variable: variable)
        } else if let expExpr = expression as? ExponentExpression {
            // TODO support complex exponent expressions
            currView = renderSimpleExp(exp: expExpr)
        } else if let _ = expression as? Blank {
            currView = renderBlankExpression()
        } else {
            // almost fully generalized
            let prodExpr = expression as! ProductExpression
            currView = renderProductExp(prod: prodExpr)
        }
        return currView
    }

    func renderVariable(variable: Variable) -> ExpressionView {
        let firstLabel = UILabel()
        firstLabel.translatesAutoresizingMaskIntoConstraints = false
        firstLabel.font = bigFont
        firstLabel.isUserInteractionEnabled = true
        firstLabel.text = variable.letter
        let exprView = ExpressionView()
        exprView.expression = variable
        exprView.consume(eaten: firstLabel)
        return exprView
    }

    func renderBlankExpression() -> ExpressionView {
        let firstLabel = UILabel()
        firstLabel.translatesAutoresizingMaskIntoConstraints = false
        firstLabel.font = bigFont
        firstLabel.text = "_"
        let exprView = ExpressionView()
        exprView.consume(eaten: firstLabel)
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
                target: self, action: #selector(self.childPanned(sender:))
            )
            let currView = renderExpression(expression: elem)
            currView.productExpression = prod
            currView.placeInParent = prod.elements.index(where: {$0 === elem})
            currView.vcview = self.view
            container.addSubview(currView)

            container.addConstraint(NSLayoutConstraint(
                item: currView, attribute: .top,
                relatedBy: .equal,
                toItem: prev, attribute: .top,
                multiplier: 1, constant: 0))

            if !firstElemSet {
                container.addConstraints(NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|[curr]-25-|",
                    options: [],
                    metrics: [:],
                    views: [
                        "curr": currView
                    ])
                )
                container.addConstraints(NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|[curr]",
                    options: [],
                    metrics: [:],
                    views: [
                        "curr": currView
                    ]))

            } else {
                let START = CGFloat(10.0) // distance between factors in a product
                let constraint = NSLayoutConstraint(
                    item: currView, attribute: .leading,
                    relatedBy: .equal,
                    toItem: prev, attribute: .trailing,
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
                indicator.backgroundColor = UIColor.blue
                indicator.addConstraints(NSLayoutConstraint.constraints(
                    withVisualFormat: "V:[indicator(20)]",
                    options: [],
                    metrics: [:],
                    views: [
                        "indicator": indicator
                    ]))
                let verticalDistance = NSLayoutConstraint(
                    item: indicator, attribute: .top,
                    relatedBy: .equal,
                    toItem: currView, attribute: .bottom,
                    multiplier: 1, constant: 0
                )
                container.addConstraint(verticalDistance)
                indicator.verticalDistance = verticalDistance
                let leadingDistance = NSLayoutConstraint(
                    item: indicator, attribute: .leading,
                    relatedBy: .equal,
                    toItem: currView, attribute: .leading,
                    multiplier: 1, constant: 0
                )
                container.addConstraint(leadingDistance)
                container.startedIndicator!.leadingDistance = leadingDistance

                indicator.addGestureRecognizer(
                    UIPanGestureRecognizer(target: self, action: #selector(self.pannedIndicator(sender:)))
                )
                indicator.addGestureRecognizer(
                    UITapGestureRecognizer(target: self, action: #selector(self.tappedIndicator(sender:)))
                )
            }

            if elem.isEnd {
                container.startedIndicator!.end = currView.placeInParent
                let trailingDistance = NSLayoutConstraint(
                    item: container.startedIndicator!, attribute: .trailing,
                    relatedBy: .equal,
                    toItem: currView, attribute: .trailing,
                    multiplier: 1, constant: 0
                )
                container.addConstraint(trailingDistance)
                container.startedIndicator!.trailingDistance = trailingDistance
                container.startedIndicator = nil
            }
        }

        container.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:[last]|",
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
        baseLabel.isUserInteractionEnabled = true
        baseLabel.translatesAutoresizingMaskIntoConstraints = false
        baseLabel.text = simpleBase.letter
        baseLabel.font = bigFont
        let expLabel = UILabel()
        expLabel.text = String(exp.exponent)
        expLabel.isUserInteractionEnabled = true
        expLabel.translatesAutoresizingMaskIntoConstraints = false
        expLabel.font = smallFont

        container.addSubview(baseLabel)
        container.addSubview(expLabel)
        container.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[exp]",
            options: [],
            metrics: nil,
            views: [
                "exp": expLabel
            ])
        )
        container.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[base]|",
            options: [],
            metrics: nil,
            views: [
                "base": baseLabel
            ])
        )
        container.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[base][exp]|",
            options: [],
            metrics: nil,
            views: [
                "base": baseLabel,
                "exp": expLabel
            ])
        )
        let exprView = ExpressionView()
        exprView.expression = exp
        exprView.consume(eaten: container)

        exprView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.exponentTapped(sender:)))
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
    @objc func childPanned(sender: UIPanGestureRecognizer) {
        let panned = sender.view as! ExpressionView
        if sender.state == .began {
            panned.setUpViewToDistance()
            let newCopy = renderExpression(expression: panned.expression)
            panned.newCopyStore = newCopy
            self.view.addSubview(newCopy)
            
            let xCnstr = NSLayoutConstraint(
                item: newCopy, attribute: .centerX,
                relatedBy: .equal,
                toItem: panned, attribute: .centerX,
                multiplier: 1, constant: 0)
            let yCnstr = NSLayoutConstraint(
                item: newCopy, attribute: .centerY,
                relatedBy: .equal,
                toItem: panned, attribute: .centerY,
                multiplier: 1, constant: 0)
            view.addConstraint(xCnstr)
            view.addConstraint(yCnstr)

            panned.xConstraint = xCnstr
            panned.yConstraint = yCnstr
            view.layoutIfNeeded()

            mainHolder.isHidden = true
            tempHolder.isHidden = false
            let mainProductExp = mainExpression as! ProductExpression
            let place = panned.placeInParent!
            let newView = mainProductExp.moveElem(from: place, toBlankAt: place)
            render(expr: newView, holder: tempHolder)

        } else if sender.state == .changed {
            panned.xConstraint.constant = sender.translation(in: sender.view!.superview!).x
            panned.yConstraint.constant = sender.translation(in: sender.view!.superview!).y
            let newIndex = panned.indexForView(input: panned.newCopyStore!)
            if newIndex != panned.mostRecentIndex {
                panned.mostRecentIndex = newIndex
                let mainProductExp = mainExpression as! ProductExpression
                let newView = mainProductExp.moveElem(from: panned.placeInParent, toBlankAt:newIndex)
                render(expr: newView, holder: tempHolder)
                
            }
            panned.myParentView.layoutIfNeeded()

        } else if [.ended, .failed, .cancelled].contains(sender.state) {
            panned.productExpression.jumpTo(
                index1: panned.mostRecentIndex!, from: panned.placeInParent)
            render(expr: mainExpression, holder: mainHolder)
            panned.newCopyStore.removeFromSuperview()
            mainHolder.isHidden = false
            tempHolder.isHidden = true
            // TODO: get animation working, need to find position to animate to
        }
    }

    @objc func pannedIndicator(sender: UIPanGestureRecognizer) {
        let DRAG_LENGTH: CGFloat = 100.0
        let indicator = sender.view as! IndicatorView
        let parent = indicator.productExpressionView
        if indicator.initialWidth == nil {
            indicator.initialWidth = indicator.frame.size.width
        }

        switch sender.state {
        case .changed:
            let yChange = sender.translation(in: parent).y
            if yChange > DRAG_LENGTH {
                let indicator = sender.view as! IndicatorView
                let prod = indicator.productExpressionView.expression as! ProductExpression
                prod.contractSlice(start: indicator.start, end: indicator.end)
                render(expr: prod, holder: mainHolder)
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
        case .ended:
            indicator.verticalDistance.constant = 0
            indicator.leadingDistance.constant = 0
            indicator.trailingDistance.constant = 0
            for constraint in indicator.horizontalConstraints {
                // put 10 as start in indicatorview class
                constraint.constant = 10
            }
        case .began, .possible, .failed, .cancelled:
            break
        }

    }

    @objc func tappedIndicator(sender: UITapGestureRecognizer) {
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
    @objc func exponentTapped(sender: UITapGestureRecognizer) {
        let expressionView = sender.view as! ExpressionView
        let exponentExpression  = expressionView.expression as! ExponentExpression
        (mainExpression as! ProductExpression).expand(elem: exponentExpression)
        render(expr: mainExpression, holder: mainHolder)
    }

}

