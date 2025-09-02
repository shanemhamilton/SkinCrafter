// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SkinCrafter",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "SkinCrafter",
            targets: ["SkinCrafter"]),
    ],
    dependencies: [
        // Google Mobile Ads SDK for COPPA-compliant monetization
        // Note: You'll need to add this via CocoaPods or SPM separately
        // .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "10.0.0")
    ],
    targets: [
        .target(
            name: "SkinCrafter",
            dependencies: [],
            path: "SkinCrafter"
        ),
        .testTarget(
            name: "SkinCrafterTests",
            dependencies: ["SkinCrafter"],
            path: "SkinCrafterTests"
        ),
    ]
)