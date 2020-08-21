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
        .library(name: "TestingProcedureKit", targets: ["TestingProcedureKit"])
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
        .target(name: "TestingProcedureKit", dependencies: ["ProcedureKit"]),
        .testTarget(name: "ProcedureKitTests", dependencies: ["ProcedureKit", "TestingProcedureKit"]),
        .testTarget(name: "ProcedureKitStressTests", dependencies: ["ProcedureKit", "TestingProcedureKit"]),
        .testTarget(name: "ProcedureKitCloudTests", dependencies: ["ProcedureKitCloud", "TestingProcedureKit"]),
        .testTarget(name: "ProcedureKitCoreDataTests", dependencies: ["ProcedureKitCoreData", "TestingProcedureKit"]),
        .testTarget(name: "ProcedureKitLocationTests", dependencies: ["ProcedureKitLocation", "TestingProcedureKit"]),
        .testTarget(name: "ProcedureKitMacTests", dependencies: ["ProcedureKitMac", "TestingProcedureKit"]),
        .testTarget(name: "ProcedureKitMobileTests", dependencies: ["ProcedureKitMobile", "TestingProcedureKit"]),
        .testTarget(name: "ProcedureKitNetworkTests", dependencies: ["ProcedureKitNetwork", "TestingProcedureKit"]),
    ],
    swiftLanguageVersions: [.v5]
)
