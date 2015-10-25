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

class SpecialGestureRecognizer: UITapGestureRecognizer {
    var expression: Expression!
}
