//
//  ExpressionBrain.swift
//  HandsOnMath
//
//  Created by Michael Lipman on 10/24/15.
//  Copyright (c) 2015 HackingEDUGroup. All rights reserved.
//

import Foundation


protocol Expression: NSObjectProtocol {
    func to_string() -> String

    func selfWithReplacement(old: Expression, new: Expression) -> Expression
}

class ExponentExpression: NSObject, Expression {
    init(bse: Expression, exp: Int?) {
        exponent = exp ?? 1
        base = bse
    }
    var exponent: Int
    var base: Expression
    func to_string() -> String {
        return "((" + base.to_string() + ")^(" + String(exponent) + "))"
    }

    func expand() -> ProductExpression {
        var ans: [Expression] = []
        for i in 0..<exponent {
            ans.append(base)
        }
        return ProductExpression(elems: ans)
    }

    func selfWithReplacement(old: Expression, new: Expression) -> Expression {
        let newBase = (old === base) ? new : base
        return ExponentExpression(bse: newBase, exp: exponent)
    }

}

class ProductExpression: NSObject, Expression {
    init(elems: [Expression]) {
        elements = elems
    }
    var elements: [Expression]
    func to_string() -> String {
        let descs = elements.map({$0.to_string()}) as [String]
        return "•".join(descs)
    }

    func selfWithReplacement(old: Expression, new: Expression) -> Expression {
        var newElements: [Expression] = []
        for (i, element) in enumerate(elements) {
            let newElement: Expression = (old === element) ? new : element
            newElements.append(newElement)
        }
        return ProductExpression(elems: newElements)
    }

    func contract() -> ExponentExpression {
        // could validate that all elements are the same
        return ExponentExpression(bse: elements[0], exp: elements.count)
    }


}

class DivisorExpression: NSObject, Expression {
    init(num: Expression, denom: Expression) {
        self.numerator = num
        self.denominator = denom
    }

    var numerator: Expression!
    var denominator: Expression!
    func to_string() -> String {
        return numerator.to_string() + "/" + denominator.to_string()
    }

    func selfWithReplacement(old: Expression, new: Expression) -> Expression {
        let newNum = (old === numerator) ? new : numerator
        let newDenom = (old === denominator) ? new : denominator
        return DivisorExpression(num: newNum, denom: newDenom)
    }
}

class Variable: NSObject, Expression {
    init(lttr: String) {
        letter = lttr
    }

    var letter: String

    func to_string() -> String {
        if contains(["/", "^", "(", ")", "•"], letter) {
            return "\\"+letter
        } else {
            return letter
        }
    }

    func selfWithReplacement(old: Expression, new: Expression) -> Expression {
        return (old === self) ? new : self
    }
}
