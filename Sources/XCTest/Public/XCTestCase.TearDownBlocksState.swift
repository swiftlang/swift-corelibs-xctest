// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTestCase.ClosureType.swift
//  Extension on XCTestCase which encapsulates ClosureType
//

///  XCTestCase.TeardownBlocksState
///  A class which encapsulates teardown blocks which are registered via the `addTearDownBlock(_block:)` method.
///  Supports async and sync throwing methods

extension XCTestCase {
    final class TeardownBlocksState {
        
        private var wasFinalized = false
        private var blocks: [() throws -> Void] = []
        
        @available(macOS 12, *)
        func append(_ block: @escaping () async throws -> Void) {
            XCTWaiter.subsystemQueue.sync {
                precondition(wasFinalized == false, "API violation -- attempting to add a teardown block after teardown blocks have been dequeued")
                blocks.append {
                    try awaitUsingExpectation { try await block() }
                }
            }
        }
        
        func append(_ block: @escaping () throws -> Void) {
            XCTWaiter.subsystemQueue.sync {
                precondition(wasFinalized == false, "API violation -- attempting to add a teardown block after teardown blocks have been dequeued")
                blocks.append(block)            }
        }
        
        func finalize() -> [() throws -> Void] {
            XCTWaiter.subsystemQueue.sync {
                precondition(wasFinalized == false, "API violation -- attempting to run teardown blocks after they've already run")
                wasFinalized = true
                return blocks
            }
        }
    }
}
