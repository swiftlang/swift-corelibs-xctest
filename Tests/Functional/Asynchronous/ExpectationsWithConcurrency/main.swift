// RUN: %{swiftc} %s -typecheck -warn-concurrency -warnings-as-errors

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

let expectation = XCTestExpectation()
Task.detached {
    expectation.fulfill()
}
