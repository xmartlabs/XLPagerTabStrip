// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "XLPagerTabStrip",
  platforms: [.iOS(.v9)],
  products: [
    .library(name: "XLPagerTabStrip", targets: ["XLPagerTabStrip"])
  ],
  dependencies: [],
  targets: [
    .binaryTarget(name: "FXPageControl", path: "FXPageControl.xcframework"),
    .target(
      name: "XLPagerTabStrip",
      dependencies: ["FXPageControl"],
      path: "Sources",
      resources: [.process("Sources/ButtonCell.xib")],
      publicHeadersPath: "XLPagerTabStrip"),
    .testTarget(
      name: "XLPagerTabStripTests",
      dependencies: ["XLPagerTabStrip"],
      path: "Tests",
      exclude: ["Info.plist"])
  ]
)
