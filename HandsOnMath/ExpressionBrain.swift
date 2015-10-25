//
//  ExpressionBrain.swift
//  HandsOnMath
//
//  Created by Michael Lipman on 10/24/15.
//  Copyright (c) 2015 HackingEDUGroup. All rights reserved.
//

import Foundation


protocol Expression {
    func description() -> String
}

class ExponentExpression: Expression {
    init(bse: Expression, exp: Int?) {
        exponent = exp ?? 1
        base = bse
    }
    var exponent: Int
    var base: Expression
    func description() -> String {
        return "((" + base.description() + ")^(" + String(exponent) + "))"
    }

    func expand() -> ProductExpression {
        var ans: [Expression] = []
        for i in 0..<exponent {
            ans.append(base)
        }
        return ProductExpression(elems: ans)
    }
}

class ProductExpression: Expression {
    init(elems: [Expression]) {
        elements = elems
    }
    var elements: [Expression]
    func description() -> String {
        let descs = elements.map({$0.description()}) as [String]
        return "•".join(descs)
    }


}

class DivisorExpression: Expression {
    init(num: Expression, denom: Expression) {
        self.numerator = num
        self.denominator = denom
    }

    var numerator: Expression!
    var denominator: Expression!
    func description() -> String {
        return numerator.description() + "/" + denominator.description()
    }
}

class Variable: Expression {
    init(lttr: String) {
        letter = lttr
    }

    var letter: String

    func description() -> String {
        return letter
        /*
        if (letter in ["/", "^", "(", ")", "•"]) {
            return "\\"+letter
        } else {
            return letter
        }
        */
    }
}
