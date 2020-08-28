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
        .library(name: "ProcedureKitCloud", targets: ["ProcedureKitCloud"]),
        .library(name: "ProcedureKitCoreData", targets: ["ProcedureKitCoreData"]),
        .library(name: "ProcedureKitLocation", targets: ["ProcedureKitLocation"]),
        .library(name: "ProcedureKitMac", targets: ["ProcedureKitMac"]),
        .library(name: "ProcedureKitMobile", targets: ["ProcedureKitMobile"]),
        .library(name: "ProcedureKitNetwork", targets: ["ProcedureKitNetwork"]),
        .library(name: "ProcedureKitTesting", targets: ["ProcedureKitTesting"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "ProcedureKit"),
        .target(name: "ProcedureKitCloud", dependencies: ["ProcedureKit"]),
        .target(name: "ProcedureKitCoreData", dependencies: ["ProcedureKit"]),
        .target(name: "ProcedureKitLocation", dependencies: ["ProcedureKit"]),
        .target(name: "ProcedureKitMac", dependencies: ["ProcedureKit"]),
        .target(name: "ProcedureKitMobile", dependencies: ["ProcedureKit"]),
        .target(name: "ProcedureKitNetwork", dependencies: ["ProcedureKit"]),
        .target(name: "ProcedureKitTesting", dependencies: ["ProcedureKit"], path: "Tests/ProcedureKitTesting"),
        .testTarget(name: "ProcedureKitTests", dependencies: ["ProcedureKit", "ProcedureKitTesting"]),
        .testTarget(name: "ProcedureKitStressTests", dependencies: ["ProcedureKit", "ProcedureKitTesting"]),
        .testTarget(name: "ProcedureKitCloudTests", dependencies: ["ProcedureKitCloud", "ProcedureKitTesting"]),
        .testTarget(name: "ProcedureKitCoreDataTests", dependencies: ["ProcedureKitCoreData", "ProcedureKitTesting"]),
        .testTarget(name: "ProcedureKitLocationTests", dependencies: ["ProcedureKitLocation", "ProcedureKitTesting"]),
        .testTarget(name: "ProcedureKitMacTests", dependencies: ["ProcedureKitMac", "ProcedureKitTesting"]),
        .testTarget(name: "ProcedureKitMobileTests", dependencies: ["ProcedureKitMobile", "ProcedureKitTesting"]),
        .testTarget(name: "ProcedureKitNetworkTests", dependencies: ["ProcedureKitNetwork", "ProcedureKitTesting"]),
    ],
    swiftLanguageVersions: [.v5]
)
