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
    //func ==(lhs: Expression, rhs: Expression) -> Bool
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
    static var identifier: Int = 0
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
        return "((" + base.to_string() + ")^" + String(exponent) + ")"
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
            return otherExp.base.dotEquals(other: self.base) && otherExp.exponent == self.exponent
        } else {
            return false
        }
    }

    /*
    func ==(lhs: Expression, rhs: Expression) -> Bool {
        return lhs.identifier === rhs.identifier
    }
    */

}

class ProductExpression: NSObject, Expression {
    var elements: [UnitExpression]

    init(elems: [UnitExpression]) {
        elements = elems
        ProductExpression.markSlices(elems: elems)

    }

    func to_string() -> String {
        let descs = elements.map({$0.to_string()}) as [String]
        return descs.joined(separator: "•")
    }

    func jumpTo(index1: Int, from: Int) {
        if (index1 < elements.count) {
            elements.insert(elements.remove(at: from), at: index1)
        } else {
            elements.append(elements.remove(at: from))
        }
        ProductExpression.markSlices(elems: elements)
    }

    func selfWithHoleAt(index: Int) -> ProductExpression {
        // should I be deep copying?
        var newElems = self.elements
        newElems[index] = Blank(blah: "")
        return ProductExpression(elems: newElems)
    }

    func moveElem(from: Int, toBlankAt: Int) -> ProductExpression {
        // should I be deep copying?
        var newElems = self.elements
        newElems.remove(at: from)
        if (toBlankAt < newElems.count) {
            newElems.insert(Blank(blah: ""), at: toBlankAt)
        } else {
            newElems.append(Blank(blah: ""))
        }
        return ProductExpression(elems: newElems)
    }

    func contractSlice(start: Int, end: Int) {
        // todo: die if not all from start to end are the same
        let base = elements[start]
        elements[start...end] = [ExponentExpression(bse: base, exp: end-start+1)]
        ProductExpression.markSlices(elems: elements)
    }

    func expand(elem: ExponentExpression) {
        let i = elements.index(where: {$0 === elem})!
        var new = [UnitExpression]()
        for _ in 0..<elem.exponent {
            // not fully generalized: should copy base, even if not a Variable
            new.append(Variable(lttr: (elem.base as! Variable).letter))
        }
        elements.replaceSubrange(i...i, with: new)
        ProductExpression.markSlices(elems: elements)

    }

    // class func because called in init, should be able to fix that
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

        for (i, curr) in elems.enumerated() {
            if i == 0 {
                continue
            }
            // dotEquals is a bit of a hack
            // I should look into comparables more and implement ==
            if curr.dotEquals(other: prev) {
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

class Blank: NSObject, UnitExpression {
    init(blah: String) {
        isStart = false
        isEnd = false
    }

    var isStart : Bool
    var isEnd : Bool

    func to_string() -> String {
        return "_"
    }

    func dotEquals(other: UnitExpression) -> Bool {
        return false
    }


}
