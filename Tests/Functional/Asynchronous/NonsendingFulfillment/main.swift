// RUN: %{swiftc} %s -o %T/NonsendingFulfillment -warn-concurrency -warnings-as-errors

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

final class NonisolatedExpectationTests: XCTestCase {
    @MainActor func testIt() async {
        let something = expectation(description: "bla")
        Task {
            try? await Task.sleep(for: .seconds(1.0))
            something.fulfill()
        }
        await fulfillment(of: [something], timeout: 2.0)
    }
}
