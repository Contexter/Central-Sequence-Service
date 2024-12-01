import Vapor

struct SimplifiedValidationMiddleware: Middleware {
    let supportedMethods: [HTTPMethod]
    let requiredFields: [String]

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        // Ensure the HTTP method is supported
        guard supportedMethods.contains(request.method) else {
            return request.eventLoop.makeFailedFuture(
                Abort(.methodNotAllowed, reason: "HTTP method \(request.method.rawValue) not allowed.")
            )
        }

        // Ensure required fields are present in the JSON body
        guard let body = request.body.string,
              let json = try? JSONSerialization.jsonObject(with: Data(body.utf8)) as? [String: Any] else {
            return request.eventLoop.makeFailedFuture(
                Abort(.badRequest, reason: "Invalid or missing JSON body.")
            )
        }

        for field in requiredFields {
            guard json[field] != nil else {
                return request.eventLoop.makeFailedFuture(
                    Abort(.badRequest, reason: "Missing required field: \(field).")
                )
            }
        }

        return next.respond(to: request)
    }
}
