// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XLPagerTabStrip",
    platforms: [
            .iOS(.v11)
        ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "XLPagerTabStrip",
            targets: ["XLPagerTabStrip"]),
    ],
    dependencies: [
        .package(
                    url: "https://github.com/nicklockwood/FXPageControl.git",
                    .upToNextMajor(from: "1.6.0")
                )
    ],
    targets: [
        .target(
            name: "XLPagerTabStrip",
            dependencies: ["FXPageControl"]),
    ],
    swiftLanguageVersions: [
           .v5
       ]
)
