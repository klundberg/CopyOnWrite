// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "CopyOnWrite",
  platforms: [.iOS(.v9), .macOS(.v10_10), .tvOS(.v9), .watchOS(.v2)],
  products: [
    .library(
      name: "CopyOnWrite",
      targets: ["CopyOnWrite"]
    ),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "CopyOnWrite",
      dependencies: []
    ),
    .testTarget(
      name: "CopyOnWriteTests",
      dependencies: ["CopyOnWrite"]
    ),
  ]
)
