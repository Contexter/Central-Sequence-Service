import Fluent
import FluentSQLiteDriver
import Vapor

// Configures your application
public func configure(_ app: Application) throws {
    // Serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Simplified validation middleware
    let validationMiddleware = SimplifiedValidationMiddleware(
        supportedMethods: [.POST, .PUT],
        requiredFields: ["name", "email"]
    )
    app.middleware.use(validationMiddleware)

    // Database configuration
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    // Add migrations
    app.migrations.add(CreateSequenceRecord())

    // Register routes
    try routes(app)
}
