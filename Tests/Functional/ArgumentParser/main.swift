// RUN: %{swiftc} %s -o %T/ArgumentParser
// RUN: %T/ArgumentParser

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

class ArgumentParsingTestCase: XCTestCase {
    static var allTests = {
        return [
          ("testFail", testFail),
          ("testSuccess", testSuccess),
        ]
    }()
    func testFail() { XCTFail("failure") }
    func testSuccess() { }
}

let arguments = ["main", "\(String(reflecting: ArgumentParsingTestCase.self))/testSuccess"]
XCTMain([testCase(ArgumentParsingTestCase.allTests)], arguments: arguments)
