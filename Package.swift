// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "QuitBuddy",
    platforms: [
        .macOS(.v13), .iOS(.v16)
    ],
    products: [
        .library(
            name: "QuitBuddyKit",
            targets: ["QuitBuddyKit"]
        )
    ],
    targets: [
        .target(
            name: "QuitBuddyKit"
        ),
        .testTarget(
            name: "QuitBuddyKitTests",
            dependencies: ["QuitBuddyKit"]
        )
    ]
)
