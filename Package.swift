// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "CentralSequenceService",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        // Vapor web framework
        .package(url: "https://github.com/vapor/vapor.git", from: "4.106.3"),
        // Fluent ORM for database interaction
        .package(url: "https://github.com/vapor/fluent.git", from: "4.12.0"),
        // SQLite driver for Fluent
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.8.0"),
        // Leaf template engine
        .package(url: "https://github.com/vapor/leaf.git", from: "4.4.1"),
        // OpenAPIServe dependency for OpenAPI middleware
        .package(url: "https://github.com/Contexter/OpenAPIServe.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "OpenAPIServe", package: "OpenAPIServe"),
            ],
            resources: [
                // Correct resource paths
                .process("Resources/Views"),
                .process("Resources/openapi.yml")
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor"),
            ]
        )
    ]
)
