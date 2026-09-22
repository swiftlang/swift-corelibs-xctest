// swift-tools-version:6.4
//
// To build with auto-linking of the .swiftmodule use:
// $ swift build -Xswiftc -module-link-name -Xswiftc XCTest
//

import PackageDescription

let package = Package(
    name: "XCTest",
    products: [
        .library(
            name: "XCTest",
            type: .dynamic,
            targets: ["XCTest"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "XCTest", dependencies: [], path: "Sources",
            swiftSettings: [
              .enableExperimentalFeature("Extern"),
              .define("XCT_BUILD_WITH_INTEROP"),
              .define("USE_FOUNDATION_FRAMEWORK"),
            ],
            linkerSettings: [
              .linkedLibrary("_TestingInterop"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
