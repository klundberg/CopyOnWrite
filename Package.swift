// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "CopyOnWrite",
    products: [
        .library(name: "CopyOnWrite",
                 targets: ["CopyOnWrite"]),
    ],
    targets: [
        .target(name: "CopyOnWrite",
                dependencies: []),
        .testTarget(name: "CopyOnWriteTests",
                    dependencies: ["CopyOnWrite"]),
    ]
)
