import Vapor
import Fluent
import FluentSQLiteDriver
import OpenAPIKit
import Yams

var openAPIDocument: OpenAPI.Document!

public func configure(_ app: Application) throws {
    // Serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Load the OpenAPI specification
    let specPath = app.directory.publicDirectory + "Central-Sequence-Service.yml"
    do {
        let yamlString = try String(contentsOfFile: specPath)
        let decoded = try YAMLDecoder().decode(OpenAPI.Document.self, from: yamlString)
        openAPIDocument = decoded
    } catch {
        fatalError("Failed to load OpenAPI specification: \(error.localizedDescription)")
    }

    // Add middleware
    app.middleware.use(ValidationMiddleware(openAPIDocument: openAPIDocument))

    // Database configuration
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    // Add migrations
    app.migrations.add(CreateSequenceRecord())

    // Register routes through RoutesFactory
    try RoutesFactory.registerRoutes(app)
}
