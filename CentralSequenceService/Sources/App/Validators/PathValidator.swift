import Vapor
import OpenAPIKit

/// PathValidator validates whether a request's path exists in the OpenAPI specification.
struct PathValidator: Validator {
    private let paths: OpenAPI.PathItem.Map

    /// Initializes the PathValidator with OpenAPI paths.
    /// - Parameter paths: The OpenAPI paths map used for validation.
    init(paths: OpenAPI.PathItem.Map) {
        self.paths = paths
    }

    /// Validates the path of an incoming request against the OpenAPI specification.
    /// - Parameters:
    ///   - request: The incoming HTTP request.
    ///   - operation: The OpenAPI operation related to the request.
    /// - Throws: An Abort error if the path is not found in the OpenAPI specification.
    func validate(request: Request, operation: OpenAPI.Operation) throws {
        let path = OpenAPI.Path(rawValue: request.url.path)
        guard let _ = paths[path] else {
            throw Abort(.notFound, reason: "Path \(request.url.path) is not defined in the OpenAPI specification.")
        }
    }
}
