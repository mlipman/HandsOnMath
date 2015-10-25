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

    func consume(eaten: UIView) {
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(eaten)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[eat]|",
            options: nil,
            metrics: nil,
            views: [
                "eat": eaten
            ])
        )
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[eat]|",
            options: nil,
            metrics: nil,
            views: [
                "eat": eaten
            ])
        )
    }
}

class SpecialTapGestureRecognizer: UITapGestureRecognizer {
    var expression: Expression!
}

class SpecialPinchGestureRecognizer: UIPinchGestureRecognizer {
    var expression: Expression!
    var constraintSet: [NSLayoutConstraint] = []
}

class SpecialPanGestureRecognizer: UIPanGestureRecognizer {
    var expression: Expression!
    var parentView: UIView!
    var xConstraint: NSLayoutConstraint!
    var newCopyStore: ExpressionView!
    var viewToDistance = [UIView:CGFloat]()
    var minXCoord: CGFloat!
    var mostRecentIndex: Int?
    var productExpression: ProductExpression!
    var constraintToAnimateFor: NSLayoutConstraint!

    func indexForView(input: UIView) -> Int {
        let dist = input.center.x - minXCoord
        var counter = 0
        for (vieww, viewDist) in viewToDistance {
            if dist > viewDist && view! !== vieww {
                counter += 1
            }
        }
        return counter
    }

    func setUpViewToDistance() {
        if self.parentView.subviews.count == 0 {
            return
        }
        var allDistances = [CGFloat]()
        for child in self.parentView.subviews {
            allDistances.append((child as! UIView).center.x)
        }
        var minX  = allDistances[0]
        for d in allDistances {
            if d < minX {
                minX = d
            }
        }
        minXCoord = minX
        for child in self.parentView.subviews {
            let a = child as! UIView
            let b = child.center.x
            let c = b - minX
            viewToDistance[a] = c
            //viewToDistance[child as! UIView] = child.center.x - minX
        }
    }

}










