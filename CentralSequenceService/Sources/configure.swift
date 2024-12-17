import Fluent
import FluentSQLiteDriver
import Vapor

public func configure(_ app: Application) throws {
    // Register SQLite database
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite, isDefault: true)

    // Add migrations
    app.migrations.add(CreateSequence())
    app.migrations.add(CreateVersion())

    // Run auto-migrations
    try app.autoMigrate().wait()

    // Register routes
    routes(app)
}
