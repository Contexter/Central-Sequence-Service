import Vapor
import OpenAPIKit

struct MethodValidator: Validator {
    func validate(request: Request, operation: OpenAPI.Operation) throws {
        // Ensure the HTTP method matches one of the operation's allowed methods
        guard let method = OpenAPI.HttpMethod(rawValue: request.method.rawValue.lowercased()) else {
            throw ValidationErrorFactory.methodNotAllowedError(
                requestedMethod: request.method.rawValue,
                allowedMethods: [] // Fallback to an empty array if no methods are defined
            )
        }

        let allowedMethods: [String] = operation.vendorExtensions["x-allowed-methods"]?.value as? [String] ?? []
        if !allowedMethods.contains(method.rawValue.uppercased()) {
            throw ValidationErrorFactory.methodNotAllowedError(
                requestedMethod: request.method.rawValue,
                allowedMethods: allowedMethods
            )
        }
    }
}
