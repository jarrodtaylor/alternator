// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "alternator",
  platforms: [.macOS(.v13)],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
    .package(url: "https://github.com/johnsundell/ink.git", from: "0.6.0")
  ],
  targets: [
    .executableTarget(
      name: "alternator",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Ink", package: "ink")
      ]
    )
  ]
)
