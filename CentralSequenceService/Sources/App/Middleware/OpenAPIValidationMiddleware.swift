import Vapor
import OpenAPIKit

final class OpenAPIValidationMiddleware: Middleware {
    private let openAPIDocument: OpenAPI.Document

    init(openAPIDocument: OpenAPI.Document) {
        self.openAPIDocument = openAPIDocument
    }

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        // Parse the path from the request
        let path = OpenAPI.Path(rawValue: request.url.path)

        // Ensure the path exists in the OpenAPI document
        guard let pathItemEither = openAPIDocument.paths[path] else {
            return request.eventLoop.makeFailedFuture(
                Abort(.notFound, reason: "Path \(request.url.path) is not defined in the OpenAPI specification.")
            )
        }

        // Resolve the PathItem from Either
        let pathItem: OpenAPI.PathItem
        switch pathItemEither {
        case .a(let reference):
            return request.eventLoop.makeFailedFuture(
                Abort(.notImplemented, reason: "References are not supported in this middleware: \(reference).")
            )
        case .b(let item):
            pathItem = item
        }

        // Match HTTP method in the OpenAPI path item
        guard let httpMethod = OpenAPI.HttpMethod(rawValue: request.method.rawValue.lowercased()) else {
            return request.eventLoop.makeFailedFuture(
                Abort(.badRequest, reason: "Invalid HTTP method \(request.method.rawValue).")
            )
        }

        guard let operation = pathItem[httpMethod] else {
            return request.eventLoop.makeFailedFuture(
                Abort(.methodNotAllowed, reason: "HTTP method \(request.method.rawValue) not allowed on path \(request.url.path).")
            )
        }

        // Validate request body if defined in OpenAPI
        if let requestBody = operation.requestBody?.value {
            guard let contentType = OpenAPI.ContentType(rawValue: "application/json"),
                  let contentSchema = requestBody.content[contentType]?.schema else {
                return request.eventLoop.makeFailedFuture(
                    Abort(.badRequest, reason: "Unsupported content type or missing schema.")
                )
            }

            // Check if the request body is required
            if requestBody.required {
                guard let bodyBuffer = request.body.data else {
                    return request.eventLoop.makeFailedFuture(
                        Abort(.badRequest, reason: "Request body is required but missing.")
                    )
                }

                do {
                    // Decode the JSON request body for validation
                    let decodedRequest = try JSONDecoder().decode([String: String].self, from: Data(buffer: bodyBuffer))
                    print("Validated request body: \(decodedRequest)")
                    // Further validation can be done here with OpenAPIKit's schema tools
                } catch {
                    return request.eventLoop.makeFailedFuture(
                        Abort(.badRequest, reason: "Failed to decode request body: \(error.localizedDescription)")
                    )
                }
            }
        }

        // Continue to the next middleware or route handler
        return next.respond(to: request)
    }
}
