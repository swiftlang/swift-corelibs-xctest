# XCTest

The XCTest library is designed to provide a common framework for writing unit tests in Swift, for Swift packages and applications.

This version of XCTest uses the same API as the XCTest you are familiar with from Xcode. Our goal is to enable your project's tests to run on all Swift platforms without having to rewrite them.

## Current Status and Project Goals

This project is the very earliest stages of development. It is scheduled to be part of the Swift 3 release.

Only the most basic functionality is currently present. In the next year, we have the following goals for the project:

* Finish implementing support for the most important non-UI testing APIs present in XCTest for Xcode
* Develop an effective solution to the problem of test discoverability without the Objective-C runtime.
* Provide support for efforts to standardize test functionality across the Swift stack.

## Using XCTest

Your tests are organized into a simple hierarchy. Each `XCTestCase` subclass has a set of `test` methods, each of which should test one part of your code.

You can find all kinds of useful information on using XCTest in [Apple's documenation](https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/03-testing_basics.html).

The rest of this document will focus on how this version of XCTest differs from the one shipped with Xcode.

## Working on XCTest

XCTest can be built as part of the overall Swift package. When following [the instructions for building Swift](http://www.github.com/apple/swift), pass the `--xctest` option to the build script:

```sh
swift/utils/build-script --xctest
```

If you want to build just XCTest, use the `build_xctest.py` script at the root of the project. The `master` version of XCTest must be built with the `master` version of Swift.

If your install of swift is located at `/swift` and you wish to install XCTest into that same location, here is a sample invocation of the build script:

```sh
./build_script.py --swiftc="/swift/usr/bin/swiftc" --build-dir="/tmp/XCTest_build" --swift-build-dir="/swift/usr" --library-install-path="/swift/usr/lib/swift/linux" --module-install-path="/swift/usr/lib/swift/linux/x86_64"
```

### Additional Considerations for Swift on Linux

When running on the Objective-C runtime, XCTest is able to find all of your tests by simply asking the runtime for the subclasses of `XCTestCase`. It then finds the methods that start with the string `test`. This functionality is not currently present when running on the Swift runtime. Therefore, you must currently provide an additional property called `allTests` in your `XCTestCase` subclass. This method lists all of the tests in the test class. The rest of your test case subclass still contains your test methods.

```swift
class TestNSURL : XCTestCase {
    var allTests : [(String, () -> ())] {
        return [
            ("test_URLStrings", test_URLStrings),
            ("test_fileURLWithPath_relativeToURL", test_fileURLWithPath_relativeToURL ),
            ("test_fileURLWithPath", test_fileURLWithPath),
            ("test_fileURLWithPath_isDirectory", test_fileURLWithPath_isDirectory),
            // Other tests go here
        ]
    }

    func test_fileURLWithPath_relativeToURL() {
        // Write your test here. Most of the XCTAssert macros you are familiar with are available.
        XCTAssertTrue(theBestNumber == 42, "The number is wrong")
    }

    // Other tests go here
}
```

Also, this version of XCTest does not use the external test runner binary. Instead, create your own executable which links `libXCTest.so`. In your `main.swift`, invoke the `XCTMain` function with an array of instances of the test cases that you wish to run. For example:

```swift
XCTMain([TestNSString(), TestNSArray(), TestNSDictionary()])
```

The `XCTMain` function does not return, and will cause your test app to exit with either `0` for success or `1` for failure.

We are currently investigating ideas on how to make these additional steps for test discovery automatic when running on the Swift runtime.
