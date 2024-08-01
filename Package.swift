// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Client",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Client",
            targets: ["Client"]),
    ],
    dependencies: [
        .package(url: "https://github.com/sadikkemal/FormDataEncoder.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Client",
            dependencies: [
                .product(name: "FormDataEncoder", package: "FormDataEncoder")
            ]),
        .testTarget(
            name: "ClientTests",
            dependencies: ["Client"]),
    ]
)
