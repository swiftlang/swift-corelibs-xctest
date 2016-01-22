# XCTest

The XCTest library is designed to provide a common framework for writing unit tests in Swift, for Swift packages and applications.

This version of XCTest uses the same API as the XCTest you are familiar with from Xcode. Our goal is to enable your project's tests to run on all Swift platforms without having to rewrite them.

## Current Status and Project Goals

This project is the very earliest stages of development. It is scheduled to be part of the Swift 3 release.

Only the most basic functionality is currently present. This year, we have the following goals for the project:

* Finish implementing support for the most important non-UI testing APIs present in XCTest for Xcode
* Develop an effective solution to the problem of test discoverability without the Objective-C runtime.
* Provide support for efforts to standardize test functionality across the Swift stack.

## Using XCTest

Your tests are organized into a simple hierarchy. Each `XCTestCase` subclass has a set of `test` methods, each of which should test one part of your code.

You can find all kinds of useful information on using XCTest in [Apple's documentation](https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/03-testing_basics.html).

The rest of this document will focus on how this version of XCTest differs from the one shipped with Xcode.

## Working on XCTest

### On Linux

XCTest can be built as part of the overall Swift package. When following [the instructions for building Swift](http://www.github.com/apple/swift), pass the `--xctest` option to the build script:

```sh
swift/utils/build-script --xctest
```

If you want to build just XCTest, use the `build_script.py` script at the root of the project. The `master` version of XCTest must be built with the `master` version of Swift. XCTest has a dependency upon Foundation, so you must have built the `master` version of that as well.

If your install of Swift is located at `/swift` and you wish to install XCTest into that same location, here is a sample invocation of the build script:

```sh
./build_script.py \
    --swiftc="/swift/usr/bin/swiftc" \
    --build-dir="/tmp/XCTest_build" \
    --foundation-build-dir "/swift//usr/lib/swift/linux" \
    --library-install-path="/swift/usr/lib/swift/linux" \
    --module-install-path="/swift/usr/lib/swift/linux/x86_64"
```

To run the tests on Linux, use the `--test` option:

```sh
./build_script.py \
    --swiftc="/swift/usr/bin/swiftc" \
    --foundation-build-dir "/swift/usr/lib/swift/linux" \
    --test
```

You may add tests for XCTest by including them in the `Tests/Functional/` directory. For an example, see `Tests/Functional/SingleFailingTestCase`.

### On OS X

You may build XCTest via the "SwiftXCTest" scheme in `XCTest.xcworkspace`. The workspace assumes that Foundation and XCTest are checked out from GitHub in sibling directories. For example:

```
% cd Development
% ls
swift-corelibs-foundation swift-corelibs-xctest
%
```

Unlike on Linux, you do not need to build Foundation prior to building XCTest. The "SwiftXCTest" Xcode scheme takes care of that for you.

To run the tests on OS X, build and run the `SwiftXCTestFunctionalTests` target in the Xcode workspace. You may also run them via the command line:

```
xcodebuild -workspace XCTest.xcworkspace -scheme SwiftXCTestFunctionalTests
```

When adding tests to the `Tests/Functional` directory, make sure they can be opened in the `XCTest.xcworkspace` by adding references to them, but do not add them to any of the targets.

### Additional Considerations for Swift on Linux

When running on the Objective-C runtime, XCTest is able to find all of your tests by simply asking the runtime for the subclasses of `XCTestCase`. It then finds the methods that start with the string `test`. This functionality is not currently present when running on the Swift runtime. Therefore, you must currently provide an additional property, conventionally named `allTests`, in your `XCTestCase` subclass. This method lists all of the tests in the test class. The rest of your test case subclass still contains your test methods.

```swift
class TestNSURL : XCTestCase {
    static var allTests : [(String, TestNSURL -> () throws -> Void)] {
        return [
            ("test_URLStrings", test_URLStrings),
            ("test_fileURLWithPath_relativeToURL", test_fileURLWithPath_relativeToURL),
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

Also, this version of XCTest does not use the external test runner binary. Instead, create your own executable which links `libXCTest.so`. In your `main.swift`, invoke the `XCTMain` function with an array of the test cases classes that you wish to run, wrapped by the `testCase` helper function. For example:

```swift
XCTMain([testCase(TestNSString.allTests), testCase(TestNSArray.allTests), testCase(TestNSDictionary.allTests)])
```

The `XCTMain` function does not return, and will cause your test app to exit with either `0` for success or `1` for failure.

We are currently investigating ideas on how to make these additional steps for test discovery automatic when running on the Swift runtime.
