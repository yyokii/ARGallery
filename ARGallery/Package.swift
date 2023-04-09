// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ARGallery",
    platforms: [
        .iOS(.v16)
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
                "SwiftUIHelpers"
            ]),
        .target(
            name: "ImagePickerFeature",
            dependencies: [
                "UIKitHelpers"
            ]),
        .target(
            name: "SwiftUIHelpers",
            dependencies: []),
        .target(
            name: "UIKitHelpers",
            dependencies: []),
    ]
)
