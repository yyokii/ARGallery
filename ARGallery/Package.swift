// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ARGallery",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "ARGallery",
            targets: ["HomeFeature"]),
    ],
    dependencies: [],
    targets: [
        
        .target(
            name: "HomeFeature",
            dependencies: []),
    ]
)
