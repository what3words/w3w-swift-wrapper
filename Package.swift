// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "w3w-swift-wrapper",

  platforms: [.macOS(.v10_12), .iOS(.v10), .tvOS(.v10), .watchOS(.v2)],

  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(name: "W3WSwiftApi", targets: ["W3WSwiftApi"]),
    .library(name: "W3WSwiftVoiceApi", targets: ["W3WSwiftVoiceApi"]),
  ],

  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(url: "git@github.com:what3words/w3w-swift-core.git", "1.0.0" ..< "2.0.0")
  ],

  targets: [
    .target(name: "W3WSwiftApi", dependencies: ["W3WSwiftVoiceApi", .product(name: "W3WSwiftCore", package: "w3w-swift-core")]),
    .target(name: "W3WSwiftVoiceApi", dependencies: [.product(name: "W3WSwiftCore", package: "w3w-swift-core")]),
    .testTarget(name: "w3w-swift-wrapperTests", dependencies: ["W3WSwiftApi"]),
    .testTarget(name: "w3w-swift-wrapper-voiceTests", dependencies: ["W3WSwiftVoiceApi"]),
  ]
)
