// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ios-test-helpers",
    platforms: [.iOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ios-test-helpers",
            targets: ["ios-test-helpers"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/hmrc/ios-core-library.git", from: "2.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ios-test-helpers",
            dependencies: []),
        .testTarget(
            name: "ios-test-helpersTests",
            dependencies: ["ios-test-helpers"]),
    ]
)
