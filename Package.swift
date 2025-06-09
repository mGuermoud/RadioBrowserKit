// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Package.swift
import PackageDescription

let package = Package(
    name: "RadioBrowserKit",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "RadioBrowserKit",
            targets: ["RadioBrowserKit"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "RadioBrowserKit",
            dependencies: []
        ),
        .testTarget(
            name: "RadioBrowserKitTests",
            dependencies: ["RadioBrowserKit"]
        ),
    ]
)
