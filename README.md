# XCTest

The XCTest library is designed to provide a common framework for writing unit tests in Swift, for Swift packages and applications.

This version of XCTest uses the same API as the XCTest you are familiar with from Xcode. Our goal is to enable your project's tests to run on all Swift platforms without having to rewrite them.

## Current Status and Project Goals

This project is in the very earliest stages of development. It is scheduled to be part of the Swift 3 release.

Only the most basic functionality is currently present. This year, we have the following goals for the project:

* Finish implementing support for the most important non-UI testing APIs present in XCTest for Xcode.
* Develop an effective solution to the problem of test discoverability without the Objective-C runtime.
* Provide support for efforts to standardize test functionality across the Swift stack.

For more details, visit the `Documentation` directory.

## Using XCTest

Your tests are organized into a simple hierarchy. Each `XCTestCase` subclass has a set of `test` methods, each of which should test one part of your code.

You can find all kinds of useful information on using XCTest in [Apple's documentation](https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/03-testing_basics.html).

## Contributing to XCTest

To contribute, you'll need to be able to build this project and and run its test suite. The easiest way to do so is via the Swift build script.

First, follow [the instructions in the Swift README](https://github.com/apple/swift/blob/master/README.md) to build Swift from source. Confirm you're able to build the Swift project using `utils/build-script -R`.

Once you are able to build the Swift project, build XCTest and run its tests:

```
$ cd swift-corelibs-xctest
$ ../swift/utils/build-script --preset corelibs-xctest
```

This project is only guaranteed to build with the very latest commit on the Swift and swift-corelibs-foundation `master` branches. You may update to the latest commits using the Swift `utils/update-checkout` script:

```
$ ../swift/utils/update-checkout
```

### Using Xcode

To browse files in this project using Xcode, use `XCTest.xcworkspace`. You may build the project using the "SwiftXCTest" scheme. Run the "SwiftXCTestFunctionalTests" scheme to run the tests.

However, in order to successfully build the project in Xcode, **you must use an Xcode toolchain with an extremely recent version of Swift**. The Swift website provides [Xcode toolchains to download](https://swift.org/download/#latest-development-snapshots), as well as [instructions on how to use Xcode with those toolchains](https://swift.org/download/#apple-platforms). Swift development moves fairly quickly, and so even a week-old toolchain may no longer work.

> If none of the toolchains available to download are recent enough to build XCTest, you may build your own toolchain by using [the `utils/build-toolchain` script in the Swift repository](https://github.com/apple/swift/blob/master/utils/build-toolchain).
>
> Keep in mind that the build script invocation in "Contributing to XCTest" above will always work, regardless of which Swift toolchains you have installed. The Xcode workspace exists simply for the convenience of contributors. It is not necessary to successfully build this project in Xcode in order to contribute.
