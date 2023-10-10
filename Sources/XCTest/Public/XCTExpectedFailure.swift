// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

public struct XCTExpectedFailure {
    /// Explanation of the problem requiring the issue to be suppressed.
    public let failureReason: String?

    /// The issue being suppressed.
    public let issue: XCTIssue

    /// Describes the rules for matching issues to expected failures and other behaviors related to
    /// expected failure handling.
    public struct Options {
        /// An optional filter can be used to determine whether or not an issue recorded inside an expected
        /// failure block should be matched to the expected failure. Issues that are not matched to an expected
        /// failure will be recorded as normal issues (real test failures). By default all issues are matched.
        public var issueMatcher: (XCTIssue) -> Bool = { _ in true }

        /// For expected failures that only occur under certain circumstances, this flag can be used to
        /// disable the expected failure. In the closure-based variants of ``XCTExpectFailure(_:options:)``,
        /// the failing block will be executed normally. Defaults to `true`.
        public var isEnabled = true

        /// If `true` (the default) and no issue is matched to the expected failure, then an issue will be
        /// recorded for the unmatched expected failure itself.
        public var isStrict = true

        public init() {}

        /// Convenience factory method which returns a new instance of ``XCTExpectedFailure/Options`` that has
        /// ``isStrict`` set to `false`, with every other value set to its default.
        public static func nonStrict() -> Self {
            var result = Self()
            result.isStrict = false
            return result
        }
    }

    fileprivate struct Context {
        var failureReason: String?
        var options: Options

        typealias ID = UInt64
        private static var nextID: ID = 0
        
        var id = primaryThreadContextQueue.sync {
            defer {
                nextID += 1
            }
            return nextID
        }
    }
}

@available(*, unavailable)
extension XCTExpectedFailure: Sendable {}

@available(*, unavailable)
extension XCTExpectedFailure.Options: Sendable {}

// MARK: -

private let threadContextKey = "org.swift.XCTest.ExpectedFailureContext"
private let primaryThreadContextQueue = DispatchQueue(label: "org.swift.XCTest.XCTExpectedFailure")
private var primaryThreadExpectedFailureContexts = [XCTExpectedFailure.Context]()

private func XCTAddExpectedFailureContext(_ context: XCTExpectedFailure.Context) {
    if XCTCurrentTestCase?.primaryThread == .current {
        var threadLocalContexts = Thread.current.threadDictionary[threadContextKey] as? [XCTExpectedFailure.Context] ?? []
        threadLocalContexts.append(context)
        Thread.current.threadDictionary[threadContextKey] = threadLocalContexts
    } else {
        primaryThreadContextQueue.sync {
            primaryThreadExpectedFailureContexts.append(context)
        }
    }
}

private func XCTRemoveExpectedFailureContext(identifiedBy id: XCTExpectedFailure.Context.ID) {
    if var threadLocalContexts = Thread.current.threadDictionary[threadContextKey] as? [XCTExpectedFailure.Context] {
        threadLocalContexts.removeAll { $0.id == id }
        Thread.current.threadDictionary[threadContextKey] = threadLocalContexts
    }
    primaryThreadContextQueue.sync {
        primaryThreadExpectedFailureContexts.removeAll { $0.id == id }
    }
}

internal func XCTIsIssueExpected(_ issue: XCTIssue) -> Bool {
    var expectedFailureContexts = Thread.current.threadDictionary[threadContextKey] as? [XCTExpectedFailure.Context] ?? []
    expectedFailureContexts += primaryThreadContextQueue.sync {
        primaryThreadExpectedFailureContexts
    }
    return expectedFailureContexts.lazy
        .compactMap(\.options.issueMatcher)
        .contains { $0(issue) }
}

// MARK: -

/// Declares that the test is expected to fail at some point beyond the call. This can be used to both document and
/// suppress a known issue when immediate resolution is not possible. Issues caught by ``XCTExpectFailure(_:options:)`` do not
/// impact the aggregate results of the test suites which own them.
///
/// This function may be invoked repeatedly and has stack semantics. Failures are associated with the closest
/// matching expected failure and the stack is cleaned up by the test after it runs. If a failure is expected
/// but none is recorded, a distinct failure for the unmatched expected failure will be recorded instead.
///
/// Threading considerations: when ``XCTExpectFailure(_:options:)`` is called on the test's primary thread it will match against
/// any issue recorded on any thread. When ``XCTExpectFailure(_:options:)`` is called on any other thread, it will only match
/// against issues recorded on the same thread.
///
/// - Parameter failureReason: Explanation of the issue being suppressed.
///
/// - Parameter options: The options can include a custom issue matching block as well as the ability to
/// disable "strict" behavior, which relaxes the requirement that a call to ``XCTExpectFailure(_:options:)`` must be matched
/// against at least one recorded issue.
public func XCTExpectFailure(
    _ failureReason: String? = nil,
    options: XCTExpectedFailure.Options = .init()
) {
    XCTAddExpectedFailureContext(XCTExpectedFailure.Context(failureReason: failureReason, options: options))
}

/// Declares that the test is expected to fail at some point while invoking the specified closure. This can be used to both
/// document and suppress a known issue when immediate resolution is not possible. Issues caught by
/// ``XCTExpectFailure(_:options:failingBlock:)`` do not impact the aggregate results of the test suites which own them.
///
/// This function may be invoked repeatedly and has stack semantics. Failures are associated with the closest
/// matching expected failure and the stack is cleaned up by the test after it runs. If a failure is expected
/// but none is recorded, a distinct failure for the unmatched expected failure will be recorded instead.
///
/// Threading considerations: when ``XCTExpectFailure(_:options:failingBlock:)`` is called on the test's primary thread it will match against
/// any issue recorded on any thread. When ``XCTExpectFailure(_:options:failingBlock:)`` is called on any other thread, it will only match
/// against issues recorded on the same thread.
///
/// - Parameter failureReason: Explanation of the issue being suppressed.
///
/// - Parameter options: The options can include a custom issue matching block as well as the ability to
/// disable "strict" behavior, which relaxes the requirement that a call to ``XCTExpectFailure(_:options:failingBlock:)``
/// must be matched against at least one recorded issue.
///
/// - Parameter failingBlock: The scope of code in which the failure is expected. Note that this will only
/// match against failures in that scope on the same thread; failures in dispatch callouts or other code
/// running on a different thread will not be matched. If the closure returns a value,
/// ``XCTExpectFailure(_:options:failingBlock:)`` will forward that return value.
public func XCTExpectFailure<R>(
    _ failureReason: String? = nil,
    options: XCTExpectedFailure.Options = .init(),
    failingBlock: () -> R
) -> R {
    let result: Result<R, any Error>

    let context = XCTExpectedFailure.Context(failureReason: failureReason, options: options)
    XCTAddExpectedFailureContext(context)
    defer {
        XCTRemoveExpectedFailureContext(identifiedBy: context.id)
    }

    return failingBlock()
}
