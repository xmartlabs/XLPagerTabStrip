// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "XLPagerTabStrip",
    // platforms: [.iOS("9.3")],
    products: [
        .library(name: "XLPagerTabStrip", targets: ["XLPagerTabStrip"])
    ],
    targets: [
        .target(
            name: "XLPagerTabStrip",
            path: "Sources",
            exclude: ["FXPageControl.h", "FXPageControl.m"]
        )
    ]
)
