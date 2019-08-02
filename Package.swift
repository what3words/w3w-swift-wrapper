// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "what3words",
    products: [
        .library(name: "what3words", targets: ["what3words"]),
    ],
    targets: [
        .target(
            name: "what3words",
            dependencies: [],
            path: "Sources")
    ]
)
