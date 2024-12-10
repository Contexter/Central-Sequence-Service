// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CentralSequenceService",
    platforms: [
        .macOS(.v10_15) // Minimum macOS version
    ],
    dependencies: [
        // OpenAPI Generator and Runtime
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-vapor", from: "1.0.0"),
        
        // Vapor Framework
        .package(url: "https://github.com/vapor/vapor", from: "4.89.0"),
        
        // SQLite Support
        .package(url: "https://github.com/vapor/sqlite-nio.git", from: "1.0.0"),
        
        // Typesense Client
        .package(url: "https://github.com/typesense/typesense-swift.git", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "CentralSequenceService",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIVapor", package: "swift-openapi-vapor"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "SQLiteNIO", package: "sqlite-nio"), // SQLite support
                .product(name: "Typesense", package: "typesense-swift"), // Typesense support
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
            ]
        )
    ]
)
