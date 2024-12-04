import Vapor
import OpenAPIKit

struct ValidationMiddleware: Middleware {
    private let openAPIDocument: OpenAPI.Document

    init(openAPIDocument: OpenAPI.Document) {
        self.openAPIDocument = openAPIDocument
    }

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        do {
            // Extract and resolve the path item from the OpenAPI document
            guard let eitherPathItem = openAPIDocument.paths[OpenAPI.Path(rawValue: request.url.path)] else {
                throw ValidationErrorFactory.pathNotFoundError(
                    requestedPath: request.url.path,
                    validPaths: openAPIDocument.paths.keys.map { $0.rawValue }
                )
            }

            // Resolve the actual path item
            let resolvedPathItem: OpenAPI.PathItem
            switch eitherPathItem {
            case .a(let reference):
                throw ValidationErrorFactory.pathNotFoundError(
                    requestedPath: request.url.path,
                    validPaths: ["Referenced path \(String(describing: reference)) is not resolved"]
                )
            case .b(let pathItem):
                resolvedPathItem = pathItem
            }

            // Locate the matching endpoint for the request's method
            guard let endpoint = resolvedPathItem.endpoints.first(where: {
                $0.method.rawValue.lowercased() == request.method.rawValue.lowercased()
            }) else {
                throw ValidationErrorFactory.methodNotAllowedError(
                    requestedMethod: request.method.rawValue,
                    allowedMethods: resolvedPathItem.endpoints.map { $0.method.rawValue.uppercased() }
                )
            }

            // Create validators and validate the request
            let validators = ValidatorFactory.createValidators(for: request, operation: endpoint.operation, openAPIDocument: openAPIDocument)
            try validators.forEach { try $0.validate(request: request, operation: endpoint.operation) }

            // Proceed with the next responder in the chain
            return next.respond(to: request)
        } catch let error as ValidationError {
            // Handle validation errors
            let response = Response(status: .badRequest)
            try? response.content.encode(error)
            return request.eventLoop.makeSucceededFuture(response)
        } catch {
            // Handle unexpected errors
            let fallbackError = ValidationErrorFactory.unexpectedError(context: error.localizedDescription)
            let response = Response(status: .internalServerError)
            try? response.content.encode(fallbackError)
            return request.eventLoop.makeSucceededFuture(response)
        }
    }
}
