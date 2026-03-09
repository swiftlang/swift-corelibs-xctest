// swift-tools-version:5.9
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
            swiftSettings: swiftSettings,
            linkerSettings: linkerSettings
        )
    ]
)

// Only link and enable interop for >=6.3 since it is a new library
#if compiler(>=6.3)
let swiftSettings: [SwiftSetting] = [
    .enableExperimentalFeature("Extern"),
    .define("XCT_BUILD_WITH_INTEROP"),
]
let linkerSettings: [LinkerSetting] = [
    .linkedLibrary("_TestingInterop")
]
#else
let swiftSettings: [SwiftSetting] = []
let linkerSettings: [LinkerSetting] = []
#endif
