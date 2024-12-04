import Vapor
import OpenAPIKit

struct PathValidator: Validator {
    let paths: OpenAPI.PathItem.Map

    func validate(request: Request, operation: OpenAPI.Operation) throws {
        let path = OpenAPI.Path(rawValue: request.url.path)
        guard let _ = paths[path] else {
            throw ValidationErrorFactory.pathNotFoundError(
                requestedPath: request.url.path,
                validPaths: paths.keys.map { $0.rawValue }
            )
        }
    }
}
