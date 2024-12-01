import Fluent
import FluentSQLiteDriver
import Vapor

public func configure(_ app: Application) async throws {
    // Serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Register OpenAPI middleware
    app.middleware.use(OpenAPIMiddleware())

    // Database configuration
    app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)

    // Add migrations
    app.migrations.add(CreateSequenceRecord())

    // Register routes
    try routes(app)
}
