// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors

extension XCTestCase {

    /// A class which encapsulates teardown blocks which are registered via the `addTeardownBlock(_:)` method.
    /// Supports async and sync throwing methods.
    final class TeardownBlocksState {

        #if DISABLE_XCTWAITER
        typealias TeardownBlock = @Sendable @MainActor () async throws -> Void
        #else
        typealias TeardownBlock = () throws -> Void
        #endif

        private var wasFinalized = false
        private var blocks: [TeardownBlock] = []

        // We don't want to overload append(_:) below because of how Swift will implicitly promote sync closures to async closures,
        // which can unexpectedly change their semantics in difficult to track down ways.
        //
        // Because of this, we chose the unusual decision to forgo overloading (which is a super sweet language feature <3) to prevent this issue from surprising any contributors to corelibs-xctest
        @available(macOS 12.0, *)
        func appendAsync(_ block: @Sendable @escaping () async throws -> Void) {
            #if DISABLE_XCTWAITER
            XCTestCase.subsystemQueue.sync {
                precondition(wasFinalized == false, "API violation -- attempting to add a teardown block after teardown blocks have been dequeued")
                blocks.append(block)
            }
            #else
            self.append {
                try awaitUsingExpectation { try await block() }
            }
            #endif
        }

        func append(_ block: @escaping () throws -> Void) {
            XCTestCase.subsystemQueue.sync {
                precondition(wasFinalized == false, "API violation -- attempting to add a teardown block after teardown blocks have been dequeued")
                blocks.append(block)
            }
        }
        
        func finalize() -> [TeardownBlock] {
            XCTestCase.subsystemQueue.sync {
                precondition(wasFinalized == false, "API violation -- attempting to run teardown blocks after they've already run")
                wasFinalized = true
                return blocks
            }
        }
    }
}
