// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "XLPagerTabStrip",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "XLPagerTabStrip",
            targets: ["XLPagerTabStrip"]
        )
    ],
    targets: [
        .target(
            name: "FXPageControl",
            publicHeadersPath: "."
        ),
        .target(
            name: "XLPagerTabStrip",
            dependencies: ["FXPageControl"]
        ),
    ]
)
