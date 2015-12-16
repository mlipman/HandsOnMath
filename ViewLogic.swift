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

class IndicatorView: UIView {

}

class ProductExpressionView: ExpressionView {
    var startedIndicator: IndicatorView? = nil
}

// 1/3 todo/note: I think this isn't needed, since the view
// would have an expression that it can access
class SpecialTapGestureRecognizer: UITapGestureRecognizer {
    var expression: Expression!
}


// 2/3 also, the view (or a subclass) should be able to have a constraint set
/*
class SpecialPinchGestureRecognizer: UIPinchGestureRecognizer {
    var expression: Expression!
    var constraintSet: [NSLayoutConstraint] = []
}
*/

// 3/3 and all these other things too
class SpecialPanGestureRecognizer: UIPanGestureRecognizer {
    var expression: Expression!
    var parentView: UIView!
    var xConstraint: NSLayoutConstraint!
    var yConstraint: NSLayoutConstraint!
    var newCopyStore: ExpressionView!
    var viewToDistance = [UIView:CGFloat]()
    var minXCoord: CGFloat!
    var mostRecentIndex: Int?
    var productExpression: ProductExpression!

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
            if !(child is IndicatorView) {
                allDistances.append(child.center.x)
            }
        }

        minXCoord = allDistances.minElement()!
        for child in self.parentView.subviews {
            if !(child is IndicatorView) {
                viewToDistance[child] = child.center.x - minXCoord
            }
        }
    }

}

/*
UX idea:
blue bar below repeating stretches, with small arrow down, lets you
pull the stretch together
red bar above simple exponenents, with arrow up, lets you pull it apart
*/










