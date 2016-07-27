# Additional Considerations for Swift on Linux

When running on the Objective-C runtime, XCTest is able to find all of your tests by simply asking the runtime for the subclasses of `XCTestCase`. It then finds the methods that start with the string `test`. This functionality is not currently present when running on the Swift runtime. Therefore, you must currently provide an additional property, conventionally named `allTests`, in your `XCTestCase` subclass. This method lists all of the tests in the test class. The rest of your test case subclass still contains your test methods.

```swift
class TestNSURL : XCTestCase {
    static var allTests = {
        return [
            ("test_URLStrings", test_URLStrings),
            ("test_fileURLWithPath_relativeToURL", test_fileURLWithPath_relativeToURL),
            ("test_fileURLWithPath", test_fileURLWithPath),
            ("test_fileURLWithPath_isDirectory", test_fileURLWithPath_isDirectory),
            // Other tests go here
        ]
    }()

    func test_fileURLWithPath_relativeToURL() {
        // Write your test here. Most of the XCTAssert macros you are familiar with are available.
        XCTAssertTrue(theBestNumber == 42, "The number is wrong")
    }

    // Other tests go here
}
```

Also, this version of XCTest does not use the external test runner binary. Instead, create your own executable which links `libXCTest.so`. In your `main.swift`, invoke the `XCTMain` function with an array of the tests from the `XCTestCase` subclasses that you wish to run, wrapped by the `testCase` helper function. For example:

```swift
XCTMain([testCase(TestNSString.allTests), testCase(TestNSArray.allTests), testCase(TestNSDictionary.allTests)])
```

We are currently investigating ideas on how to make these additional steps for test discovery automatic when running on the Swift runtime.

# Command Line Usage
The `XCTMain` function does not return, and will cause your test app to exit with either `0` for success or `1` for failure. Certain command line arguments can be used to modify the test runner behavior:

* A particular test or test case can be selected to execute. For example:

```sh
$ ./FooTests Tests.FooTestCase/testFoo  # Run a single test case
$ ./FooTests Tests.FooTestCase          # Run all the tests in FooTestCase
```
* Tests can be listed, instead of executed.

```sh
$ ./FooTests --list-tests
Listing 4 tests in FooTests.xctest:

Tests.FooTestCase/testFoo
Tests.FooTestCase/testBar
Tests.BarTestCase/test123

$ ./FooTests --dump-tests-json
{"tests":[{"tests":[{"tests":[{"name":"testFoo"},{"name":"testBar"}],"name":"Tests.FooTestCase"},{"tests":[{"name":"test123"}],"name":"Tests.BarTestCase"}],"name":"Tests.xctest"}],"name":"All tests"}
```
