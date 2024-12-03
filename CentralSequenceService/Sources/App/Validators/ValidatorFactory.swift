import Vapor
import OpenAPIKit

struct ValidatorFactory {
    static func createValidators(for request: Request, operation: OpenAPI.Operation, openAPIDocument: OpenAPI.Document) -> [Validator] {
        return [
            PathValidator(), // Updated to match stub signature
            MethodValidator(), // Updated to match stub signature
            BodyValidator() // Updated to match stub signature
        ]
    }
}
