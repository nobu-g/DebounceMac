// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DebounceMac",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "2.1.1"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.2"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .executableTarget(
            name: "DebounceMac",
            dependencies: [
                "SwiftyBeaver",
                "SwiftyJSON",
                .product(name: "Collections", package: "swift-collections"),
            ],
        ),
    ],
)
