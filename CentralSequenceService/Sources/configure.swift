// File: Sources/configure.swift
// Position: CentralSequenceService/Sources/configure.swift
// Purpose: Configures the Vapor application, registers middleware, and sets up API routes.

import Vapor
import OpenAPIVapor

func configure(_ app: Application) throws {
    // Adds default error middleware for handling uncaught errors and returning standard responses.
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))

    // Registers the API handler which automatically maps routes to OpenAPI protocol methods.
    try app.register(collection: APIImplementation())

    // Adds middleware for API key validation.
    app.middleware.use(APIKeyMiddleware())
}
