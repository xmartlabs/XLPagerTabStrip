// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XLPagerTabStrip",
    defaultLocalization: "de",
    platforms: [
            .iOS(.v12),
    ],
    products: [
         .library(
            name: "XLPagerTabStrip",
            targets: ["XLPagerTabStrip"])
    ],
    targets: [
         .target(
            name: "XLPagerTabStrip",
			path: "Sources",
			exclude: ["ButtonCell.xib", "FXPageControl.h", "FXPageControl.m", "TwitterPagerTabStripViewController.swift"],
            resources: [
                .process("ButtonCell.xib")
            ])
    ]
)
