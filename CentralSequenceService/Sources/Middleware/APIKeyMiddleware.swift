// File: Sources/Middleware/APIKeyMiddleware.swift

import Vapor

/// Middleware to validate API keys in incoming requests.
struct APIKeyMiddleware: Middleware {
    // Secure API key storage or configuration
    private let validAPIKey = Environment.get("API_KEY") ?? "default-api-key"

    /// Processes incoming requests and validates the API key.
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        guard let apiKey = request.headers["X-API-KEY"].first, apiKey == validAPIKey else {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Invalid API Key"))
        }

        // Allow request to proceed if API key is valid
        return next.respond(to: request)
    }
}

/// Extension to register the middleware.
extension Application {
    func addAPIKeyMiddleware() {
        self.middleware.use(APIKeyMiddleware())
    }
}

/// Example usage in configure.swift
public func configure(_ app: Application) throws {
    app.addAPIKeyMiddleware() // Register the middleware
}
