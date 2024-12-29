// File: Sources/Middleware/APIKeyMiddleware.swift
// Position: CentralSequenceService/Sources/Middleware/APIKeyMiddleware.swift
// Purpose: Validates API key headers to restrict access to authorized clients only.

import Vapor

struct APIKeyMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) async throws -> Response {
        guard request.headers["X-API-KEY"].first == "valid-api-key" else {
            throw Abort(.unauthorized) // Rejects requests with invalid or missing keys.
        }
        return try await next.respond(to: request)
    }
}
