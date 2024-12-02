import Fluent
import FluentSQLiteDriver
import Vapor

// Configures your application
public func configure(_ app: Application) throws {
    // Serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Commented out Simplified Validation Middleware
    /*
    let validationMiddleware = SimplifiedValidationMiddleware(
        supportedMethods: [.POST, .PUT],
        requiredFields: ["name", "email"]
    )
    app.middleware.use(validationMiddleware)
    */

    // Commented out OpenAPIMiddleware
    /*
    app.middleware.use(OpenAPIMiddleware())
    */

    // Commented out OpenAPIValidationMiddleware
    /*
    let openAPIDocument = try OpenAPI.Document(fromYAMLFileAtPath: app.directory.publicDirectory + "Central-Sequence-Service.yml")
    app.middleware.use(OpenAPIValidationMiddleware(openAPIDocument: openAPIDocument))
    */

    // Database configuration
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    // Add migrations
    app.migrations.add(CreateSequenceRecord())

    // Register routes
    try routes(app)
}
