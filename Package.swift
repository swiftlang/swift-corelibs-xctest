// swift-tools-version:4.0
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
    dependencies: [
    ],
    targets: [
        .target(name: "XCTest", dependencies: [], path: "Sources"),
    ]
)
