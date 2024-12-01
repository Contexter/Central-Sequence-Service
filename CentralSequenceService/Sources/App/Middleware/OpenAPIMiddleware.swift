import Vapor

final class OpenAPIMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        // Check if the request is for the OpenAPI specification
        if request.url.path == "/openapi" {
            let openAPIFilePath = request.application.directory.publicDirectory + "Central-Sequence-Service.yml"
            
            // Check if the file exists
            if FileManager.default.fileExists(atPath: openAPIFilePath) {
                do {
                    // Read file content
                    let openAPIContent = try Data(contentsOf: URL(fileURLWithPath: openAPIFilePath))
                    
                    // Create response with YAML content
                    let response = Response(status: .ok, body: .init(data: openAPIContent))
                    response.headers.contentType = HTTPMediaType(type: "application", subType: "x-yaml")
                    return request.eventLoop.makeSucceededFuture(response)
                } catch {
                    // Handle file reading errors
                    return request.eventLoop.makeFailedFuture(error)
                }
            } else {
                // Return 404 if the file is not found
                return request.eventLoop.makeSucceededFuture(
                    Response(status: .notFound, body: "OpenAPI specification not found.")
                )
            }
        }

        // Default behavior for other routes
        return next.respond(to: request)
    }
}
