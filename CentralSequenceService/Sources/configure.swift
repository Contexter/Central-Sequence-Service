//
// File: configure.swift
// Path: Sources/configure.swift
//

import Vapor
import OpenAPIVapor

func configure(_ app: Application) throws {
    // Register middleware
    app.middleware.use(APIKeyMiddleware())

    // Register OpenAPI handlers
    let transport = VaporTransport(routesBuilder: app)
    let api = APIImplementation() // Implementation using generated protocol
    try api.registerHandlers(on: transport)

    app.logger.info("Routes registered successfully.")

    // Start the application
    try app.run()
}
