import Fluent
import FluentSQLiteDriver
import Vapor

public func configure(_ app: Application) throws {
    // Configure SQLite database
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    // Register migrations
    app.migrations.add(CreateSequence())
    app.migrations.add(CreateVersion())

    try app.autoMigrate().wait()

    // Register routes
    try routes(app)
}
