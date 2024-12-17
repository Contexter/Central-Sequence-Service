import Fluent
import FluentSQLiteDriver
import Vapor

public func configure(_ app: Application) throws {
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    app.migrations.add(CreateSequence())
    app.migrations.add(CreateVersion())
    try app.autoMigrate().wait()

    routes(app) // Removed 'try' as it doesn't throw
}
