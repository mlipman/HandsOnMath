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

    // Not totally sure why this hack is here and if it's necessary
    // but I think it allows me to subclass UIView, while  also using UILabels
    func consume(eaten: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(eaten)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[eat]|",
            options: [],
            metrics: nil,
            views: [
                "eat": eaten
            ])
        )
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[eat]|",
            options: [],
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
            allDistances.append(child.center.x)
        }

        minXCoord = allDistances.minElement()!
        for child in self.parentView.subviews {
            viewToDistance[child] = child.center.x - minXCoord
        }
    }

}










