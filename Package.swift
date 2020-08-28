// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProcedureKit",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v12),
        .tvOS(.v12),
        .watchOS(.v5),
    ],
    products: [
        .library(name: "ProcedureKit", targets: ["ProcedureKit"]),
        .library(name: "ProcedureKitTesting", targets: ["ProcedureKitTesting"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "ProcedureKit"),
        .target(name: "ProcedureKitTesting", dependencies: ["ProcedureKit"], path: "Tests/ProcedureKitTesting"),
        .testTarget(name: "ProcedureKitTests", dependencies: ["ProcedureKit", "ProcedureKitTesting"]),
        .testTarget(name: "ProcedureKitStressTests", dependencies: ["ProcedureKit", "ProcedureKitTesting"]),
    ],
    swiftLanguageVersions: [.v5]
)
