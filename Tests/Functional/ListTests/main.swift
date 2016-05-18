// RUN: %{swiftc} %s -o %{built_tests_dir}/ListTests
// RUN: %{built_tests_dir}/ListTests --list-tests > %t || true
// RUN: %{xctest_checker} %t %s

#if os(Linux) || os(FreeBSD)
    import XCTest
#else
    import SwiftXCTest
#endif

// CHECK: ListTests.FirstTestCase
class FirstTestCase: XCTestCase {
    static var allTests: [(String, (FirstTestCase) -> () throws -> Void)] {
        return [
                   ("test_foo", test_foo),
                   ("test_bar", test_bar),
        ]
    }

    // CHECK: ^  ListTests.FirstTestCase/test_foo
    func test_foo() {}

    // CHECK: ^  ListTests.FirstTestCase/test_bar
    func test_bar() {}
}

// CHECK: ListTests.SecondTestCase
class SecondTestCase: XCTestCase {
    static var allTests: [(String, (SecondTestCase) -> () throws -> Void)] {
        return [
                   ("test_someMore", test_someMore),
                   ("test_allTheThings", test_allTheThings),
        ]
    }

    // CHECK: ^  ListTests.SecondTestCase/test_someMore
    func test_someMore() {}

    // CHECK: ^  ListTests.SecondTestCase/test_allTheThings
    func test_allTheThings() {}
}

XCTMain([
            testCase(FirstTestCase.allTests),
            testCase(SecondTestCase.allTests),
            ])
