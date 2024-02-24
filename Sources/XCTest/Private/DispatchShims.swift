// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2024 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  NoThreadDispatchShims.swift
//

// This file is a shim for platforms that don't have libdispatch and do assume a single-threaded environment.

// NOTE: We can't use use `#if canImport(Dispatch)` because Dispatch Clang module is placed directly in the resource
// directory, and not split into target-specific directories. This means that the module is always available, even on
// platforms that don't have libdispatch. Thus, we need to check for the actual platform.
#if os(WASI)

/// No-op shim function
func dispatchPrecondition(condition: DispatchPredicate) {}

struct DispatchPredicate {
    static func onQueue<X>(_: X) -> Self {
        return DispatchPredicate()
    }

    static func notOnQueue<X>(_: X) -> Self {
        return DispatchPredicate()
    }
}

extension XCTWaiter {
    /// Single-threaded queue without any actual queueing
    struct DispatchQueue {
        init(label: String) {}

        func sync<T>(_ body: () -> T) -> T {
            body()
        }
        func async(_ body: @escaping () -> Void) {
            body()
        }
    }
}

#endif
