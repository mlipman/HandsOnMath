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
}

protocol UnitExpression: Expression {
    // would rather do something like type of other is self if possible
    func dotEquals(other: UnitExpression) -> Bool

    // ranges that can be contracted inside a prodcut expression
    // are marked with a unit expression that has isStart of true
    // and one that has isEnd as false
    // if they are misordered or mismatched, the code that
    // genereated them is wrong
    var isStart: Bool {get set}
    var isEnd: Bool {get set}
}

class ExponentExpression: NSObject, UnitExpression {
    // losing support for (xyz)^3
    init(bse: UnitExpression, exp: Int?) {
        exponent = exp ?? 1
        base = bse
        isStart = false
        isEnd = false
    }
    var exponent: Int
    var base: UnitExpression
    var isStart : Bool
    var isEnd : Bool

    func to_string() -> String {
        return "((" + base.to_string() + ")^(" + String(exponent) + "))"
    }

    func expand() -> ProductExpression {
        var ans: [UnitExpression] = []
        for _ in 0..<exponent {
            ans.append(base)
        }
        return ProductExpression(elems: ans)
    }

    func dotEquals(other: UnitExpression) -> Bool {
        if let otherExp = other as? ExponentExpression {
            return otherExp.base.dotEquals(self.base) && otherExp.exponent == self.exponent
        } else {
            return false
        }
    }


}

class ProductExpression: NSObject, Expression {
    var elements: [UnitExpression]

    init(elems: [UnitExpression]) {
        elements = elems
        ProductExpression.markSlices(elems)

    }

    func to_string() -> String {
        let descs = elements.map({$0.to_string()}) as [String]
        return descs.joinWithSeparator("•")
    }

    func jumpTo(index1: Int, from: Int) {
        elements.insert(elements.removeAtIndex(from), atIndex: index1)
        ProductExpression.markSlices(elements)
    }

    func contract() -> ExponentExpression {
        // could validate that all elements are the same
        return ExponentExpression(bse: elements[0], exp: elements.count)
    }


    /*
    test_ranges = [
        ("xxxxxyy", "0-5, 5-7"),
        ("xyxyxq", "[]"),
        ("asdfxxwwk", "4-6, 6-8"),
        ("sddfyy", "1-3, 4-6"),
        ("x", "[]"),
        ("yyy", "0-3"),
        ("asdeeefea", "3-6")
    ]
    for test in test_ranges:
    print ("%s %s %s" % (test[0], returnRanges(test[0]), test[1]))
    */
    class func markSlices(elems: [UnitExpression]) {
        for elem in elems {
            elem.isStart = false;
            elem.isEnd = false;
        }
        if elems.count < 2 {
            return
        }
        var prev = elems[0]
        var currStart: Int? = nil

        for (i, curr) in elems.enumerate() {
            if i == 0 {
                continue
            }
            if curr.dotEquals(prev) {
                if currStart == nil {
                    currStart = i-1
                    elems[i-1].isStart = true
                }
            } else if currStart != nil {
                elems[i-1].isEnd = true
                currStart = nil
            }
            prev = curr
        }
        if currStart != nil {
            elems.last!.isEnd = true
        }
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

}

class Variable: NSObject, UnitExpression {
    init(lttr: String) {
        letter = lttr
        isStart = false
        isEnd = false
    }

    var letter: String
    var isStart : Bool
    var isEnd : Bool

    func to_string() -> String {
        if ["/", "^", "(", ")", "•"].contains(letter) {
            return "\\"+letter
        } else {
            return letter
        }
    }

    func dotEquals(other: UnitExpression) -> Bool {
        if let otherVar = other as? Variable {
            return otherVar.letter == self.letter
        } else {
            return false
        }
    }


}
