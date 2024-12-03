import Vapor
import OpenAPIKit

struct PathValidator: Validator {
    let paths: OpenAPI.PathItem.Map

    func validate(request: Request, operation: OpenAPI.Operation) throws {
        let path = OpenAPI.Path(rawValue: request.url.path)
        guard let _ = paths[path] else {
            throw Abort(.notFound, reason: "Path \(request.url.path) is not defined in the OpenAPI specification.")
        }
    }
}

