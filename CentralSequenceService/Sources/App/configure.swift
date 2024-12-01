import Fluent
import FluentSQLiteDriver
import Vapor
import OpenAPIKit
import Yams

// Configures your application
public func configure(_ app: Application) async throws {
    // Serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Load and parse OpenAPI specification
    let openAPIFilePath = app.directory.publicDirectory + "Central-Sequence-Service.yml"
    let openAPIContent = try Data(contentsOf: URL(fileURLWithPath: openAPIFilePath))
    let openAPIDocument = try YAMLDecoder().decode(OpenAPI.Document.self, from: openAPIContent)

    // Print loaded OpenAPI paths for debugging
    print("OpenAPI document successfully loaded!")
    print("OpenAPI Paths: \(openAPIDocument.paths.keys)")

    // Register OpenAPI middleware to serve the spec
    app.middleware.use(OpenAPIMiddleware())

    // Register OpenAPI validation middleware
    app.middleware.use(OpenAPIValidationMiddleware(openAPIDocument: openAPIDocument))

    // Database configuration
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    // Add migrations
    app.migrations.add(CreateSequenceRecord())

    // Register routes
    try routes(app)
}

// Custom storage key for OpenAPI.Document (if needed elsewhere in the application)
struct OpenAPIStorageKey: StorageKey {
    typealias Value = OpenAPI.Document
}
