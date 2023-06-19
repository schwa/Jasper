// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Jasper",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "Jasper",
            targets: ["Jasper"]),
    ],
    dependencies: [
        .package(url: "https://github.com/schwa/CoreGraphicsGeometrySupport", from: "0.0.2"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0-swift-5.9-DEVELOPMENT-SNAPSHOT-2023-04-25-b"),
    ],
    targets: [
        .target(
            name: "Jasper",
            dependencies: [
                "CoreGraphicsGeometrySupport",
                "JasperMacros",
            ]
        ),
        .testTarget(
            name: "JasperTests",
            dependencies: [
                "Jasper",
                "JasperMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
        .macro(
            name: "JasperMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        )
    ]
)
