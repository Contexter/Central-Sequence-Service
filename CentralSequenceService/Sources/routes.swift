//
// File: routes.swift
// Path: Sources/routes.swift
//

import Vapor
import OpenAPIVapor

func registerRoutes(app: Application) throws {
    let transport = VaporTransport(routesBuilder: app)
    let api = APIImplementation() // Uses generated code
    try api.registerHandlers(on: transport)

    app.logger.info("All OpenAPI routes registered successfully.")
}
