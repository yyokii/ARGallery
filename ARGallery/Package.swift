// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ARGallery",
    platforms: [
        .iOS(.v15)
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
            dependencies: [
                "ImagePickerFeature",
                "SwiftUIHelpers",
                "UIKitHelpers"
            ]),
        .target(
            name: "ImagePickerFeature",
            dependencies: []),
        .target(
            name: "SwiftUIHelpers",
            dependencies: []),
        .target(
            name: "UIKitHelpers",
            dependencies: []),
    ]
)
