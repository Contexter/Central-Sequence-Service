import Vapor
import OpenAPIKit

struct ValidatorFactory {
    static func createValidators(for request: Request, operation: OpenAPI.Operation, openAPIDocument: OpenAPI.Document) -> [Validator] {
        return [
            PathValidator(paths: openAPIDocument.paths)
        ]
    }
}
