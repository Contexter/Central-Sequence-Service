import NIOSSL
import Fluent
import FluentSQLiteDriver
import Leaf
import Vapor
import OpenAPIServe

public func configure(_ app: Application) async throws {
    // Middleware configuration for OpenAPIServe
    let openapiFilePath = app.directory.resourcesDirectory + "openapi.yml"
    let dataProvider = FileDataProvider(filePath: openapiFilePath)
    app.middleware.use(OpenAPIMiddleware(dataProvider: dataProvider))
    
    // Uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Configure database
    app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)
    
    // Register routes
    try routes(app)
}
