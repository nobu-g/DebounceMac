// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "DebounceMac",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "1.7.0"),
         .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0"),
         .package(url: "https://github.com/lukaskubanek/OrderedDictionary.git", from: "2.3.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "DebounceMac",
            dependencies: ["SwiftyBeaver", "SwiftyJSON", "OrderedDictionary"]
        ),
    ]
)
