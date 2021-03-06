//
//  ViewLogic.swift
//  HandsOnMath
//
//  Created by Michael Lipman on 10/25/15.
//  Copyright (c) 2015 HackingEDUGroup. All rights reserved.
//

import UIKit


class ExpressionView: UIView {
    var expression: Expression!

    var myParentView: UIView!
    var xConstraint: NSLayoutConstraint!
    var yConstraint: NSLayoutConstraint!
    var newCopyStore: ExpressionView!
    var viewToDistance = [UIView:CGFloat]()
    var indexToView = [Int:UIView]()
    var minXCoord: CGFloat!
    var mostRecentIndex: Int?
    var productExpression: ProductExpression!
    var placeInParent: Int!
    var vcview: UIView!

    func indexForView(input: UIView) -> Int {
        let parentViewOrigin = myParentView.convert(myParentView.frame.origin, to: vcview)
        let dist = input.center.x - parentViewOrigin.x

        var counter = 0
        for (_, viewDist) in viewToDistance {
            if dist > viewDist {
                counter += 1
            }
        }
        return counter
    }

    func setUpViewToDistance() {
        var allDistances = [CGFloat]()
        for child in self.myParentView.subviews {
            if !(child is IndicatorView) {
                allDistances.append(child.center.x)
            }
        }

        minXCoord = allDistances.min()!
        for child in self.myParentView.subviews {
            if !(child is IndicatorView) {
                viewToDistance[child] = child.center.x
            }
        }
    }

    // Allows for expression view that is basically just a UILabel
    func consume(eaten: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(eaten)
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[eat]|",
            options: [],
            metrics: nil,
            views: [
                "eat": eaten
            ])
        )
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[eat]|",
            options: [],
            metrics: nil,
            views: [
                "eat": eaten
            ])
        )
    }
}

class IndicatorView: UIView {
    var start: Int!
    var end: Int!
    weak var productExpressionView: ProductExpressionView!
    var verticalDistance: NSLayoutConstraint!
    var leadingDistance: NSLayoutConstraint!
    var trailingDistance: NSLayoutConstraint!
    var initialWidth: CGFloat?
    var horizontalConstraints = [NSLayoutConstraint]()
}

class ProductExpressionView: ExpressionView {
    var startedIndicator: IndicatorView?
}

/*
UX idea:
blue bar below repeating stretches, with small arrow down, lets you
pull the stretch together
red bar above simple exponenents, with arrow up, lets you pull it apart


blue bar below, on tap show vertical movement,
pull down to contract

red bar above (or same color)
on tap show veritcal movement
pull up to expand


*/
