import Vapor
import OpenAPIKit

/// ValidatorFactory creates and configures validators based on the OpenAPI document and request context.
struct ValidatorFactory {
    /// Creates a list of validators for the provided request and operation.
    /// - Parameters:
    ///   - request: The incoming HTTP request.
    ///   - operation: The OpenAPI operation related to the request.
    ///   - openAPIDocument: The OpenAPI document used for validation.
    /// - Returns: An array of validators applicable to the request.
    static func createValidators(for request: Request, operation: OpenAPI.Operation, openAPIDocument: OpenAPI.Document) -> [Validator] {
        let pathValidator = PathValidator(paths: openAPIDocument.paths)
        return [
            pathValidator
            // Add additional validators here as they are implemented.
        ]
    }
}
