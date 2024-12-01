import Fluent
import FluentSQLiteDriver
import Vapor
import OpenAPIKit
import Yams

// Configures your application
public func configure(_ app: Application) async throws {
    // Serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Register OpenAPI middleware
    app.middleware.use(OpenAPIMiddleware())

    // Database configuration
    app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)

    // Add migrations
    app.migrations.add(CreateSequenceRecord())

    // Load and parse OpenAPI specification
    let openAPIFilePath = app.directory.publicDirectory + "Central-Sequence-Service.yml"
    do {
        let openAPIContent = try Data(contentsOf: URL(fileURLWithPath: openAPIFilePath))
        let openAPIDocument = try YAMLDecoder().decode(OpenAPI.Document.self, from: openAPIContent)
        app.storage[OpenAPIStorageKey.self] = openAPIDocument
        print("OpenAPI document successfully loaded!")
        print("OpenAPI Paths: \(openAPIDocument.paths.keys)")
    } catch {
        fatalError("Failed to load OpenAPI document: \(error)")
    }

    // Register routes
    try routes(app)
}

// Custom storage key for OpenAPI.Document
struct OpenAPIStorageKey: StorageKey {
    typealias Value = OpenAPI.Document
}
