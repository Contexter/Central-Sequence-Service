// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "CentralSequenceService",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.99.3"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        // 🪶 Fluent driver for SQLite.
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.6.0"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors.
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        // 📝 OpenAPI parsing and validation.
        .package(url: "https://github.com/mattpolzin/OpenAPIKit", from: "3.0.0"),
        // 📄 YAML parsing (used by OpenAPIKit for decoding OpenAPI specs).
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                "OpenAPIKit",
                "Yams"
            ],
            resources: [
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor"),
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
