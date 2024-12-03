import Vapor
import OpenAPIKit

final class ValidationMiddleware: Middleware {
    private let openAPIDocument: OpenAPI.Document

    init(openAPIDocument: OpenAPI.Document) {
        self.openAPIDocument = openAPIDocument
    }

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        do {
            // Placeholder validation logic with a basic Operation stub
            let responses = OpenAPI.Response.Map() // Empty responses map
            let operation = OpenAPI.Operation(responses: responses)

            let validators = ValidatorFactory.createValidators(for: request, operation: operation, openAPIDocument: openAPIDocument)
            try validators.forEach { validator in
                try validator.validate(request: request, operation: operation)
            }
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }

        return next.respond(to: request)
    }
}
