//
// File: Middleware/APIKeyMiddleware.swift
// Path: Sources/Middleware/APIKeyMiddleware.swift
//

import Vapor

struct APIKeyMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        // Validate API Key
        guard request.headers["X-API-KEY"].first == "valid-api-key" else {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized))
        }
        // Forward request to the next middleware or route handler
        return next.respond(to: request)
    }
}
