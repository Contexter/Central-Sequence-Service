// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "CentralSequenceService",
    platforms: [
        .macOS(.v13),
        .iOS(.v12),
        .tvOS(.v12),
        .watchOS(.v5)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator.git", from: "0.1.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-vapor.git", from: "1.0.1"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.12.0"),
        .package(url: "https://github.com/typesense/typesense-swift.git", from: "0.2.0")
    ],
    targets: [
        .target(
            name: "CentralSequenceService",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-generator"),
                .product(name: "OpenAPIVapor", package: "swift-openapi-vapor"),
                .product(name: "SQLite", package: "SQLite.swift"),
                .product(name: "Typesense", package: "typesense-swift")
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
            ]
        ),
        .executableTarget(
            name: "Run",
            dependencies: ["CentralSequenceService"]
        )
    ]
)
