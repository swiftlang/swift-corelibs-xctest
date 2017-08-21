// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCPredicateExpectation.swift
//  Expectations with a specified predicate and object to evaluate.
//

internal class XCPredicateExpectation: XCTestExpectation {
    internal let predicate: NSPredicate
    internal let object: AnyObject
    internal var timer: Timer?
    internal let handler: XCPredicateExpectationHandler?
    private let evaluationInterval = 0.01
    
    internal init(predicate: NSPredicate, object: AnyObject, description: String, file: StaticString, line: Int, testCase: XCTestCase, handler: XCPredicateExpectationHandler? = nil) {
        self.predicate = predicate
        self.object = object
        self.handler = handler
        self.timer = nil
        super.init(description: description, file: file, line: line, testCase: testCase)
    }
    
    internal func considerFulfilling() {
        self.timer = Timer.scheduledTimer(withTimeInterval: self.evaluationInterval, repeats: true, block: { [weak self] timer in
            guard let strongSelf = self else {
                timer.invalidate()
                return
            }
            
            if strongSelf.predicate.evaluate(with: strongSelf.object) {
                if let handler = strongSelf.handler {
                    if handler() {
                        strongSelf.fulfill()
                        timer.invalidate()
                    }
                    // The timer does not invalidate even if the handler returns
                    // false. The object is still re-evaluated until timeout.
                } else {
                    strongSelf.fulfill()
                    timer.invalidate()
                }
            }
        })
        self.timer?.fire()
    }
}
