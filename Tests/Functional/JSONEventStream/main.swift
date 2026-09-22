// RUN: %{swiftc} %s -o %T/JSONEventStream
// RUN: %T/JSONEventStream > %t || true
// RUN: %{xctest_checker} %t %s

import Testing
@testable import XCTest

@Test func `JSON event stream is generated`() async throws {
    let temporaryFilePath = FileManager().temporaryDirectory.appending(component: UUID().uuidString)
    XCTMain(
        [
            (
                TestCaseFixtureSubclass.self,
                [
                    ("fixtureTestFunction", fixtureTestFunction)
                ]
            )
        ],
        arguments: ["PATH", "--event-stream-output-path", temporaryFilePath.path(percentEncoded: false), "--event-stream-output-version", "6.4"]
    )
}

private final class TestCaseFixtureSubclass: XCTestCase {}
private func fixtureTestFunction(_: XCTestCase) {
    XCTFail("Test failed intentionally")
}

