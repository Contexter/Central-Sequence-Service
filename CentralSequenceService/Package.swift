// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "CentralSequenceService",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
        .package(url: "https://github.com/mattpolzin/OpenAPIKit.git", from: "3.0.0"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "OpenAPIKit", package: "OpenAPIKit"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Yams", package: "Yams")
            ],
            exclude: []
        ),
        .executableTarget(
            name: "Run",
            dependencies: ["App"]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                "App",
                .product(name: "XCTVapor", package: "vapor") // XCTVapor for testing
            ]
        )
    ]
)
