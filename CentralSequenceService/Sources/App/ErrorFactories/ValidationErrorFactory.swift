import Vapor

struct ValidationErrorFactory {
    static func pathNotFoundError(requestedPath: String, validPaths: [String]) -> ValidationError {
        return ValidationError(
            reason: "Path \(requestedPath) is not defined in the OpenAPI specification.",
            suggestion: "Verify the path in the request matches one of the supported paths.",
            context: "Valid paths: \(validPaths.joined(separator: ", "))"
        )
    }

    static func methodNotAllowedError(requestedMethod: String, allowedMethods: [String]) -> ValidationError {
        return ValidationError(
            reason: "HTTP method \(requestedMethod) is not allowed for the requested path.",
            suggestion: "Use one of the allowed methods: \(allowedMethods.joined(separator: ", ")).",
            context: "Ensure the method matches the OpenAPI specification."
        )
    }

    static func missingContentTypeError() -> ValidationError {
        return ValidationError(
            reason: "The 'Content-Type' header is missing in the request.",
            suggestion: "Include a valid 'Content-Type' header in the request.",
            context: "Commonly used content types include 'application/json'."
        )
    }

    static func unsupportedContentTypeError(contentType: String) -> ValidationError {
        return ValidationError(
            reason: "Content type \(contentType) is not supported by the operation.",
            suggestion: "Ensure the 'Content-Type' header matches the OpenAPI specification for this endpoint.",
            context: "Check the OpenAPI specification for supported content types."
        )
    }

    static func unexpectedRequestBodyError() -> ValidationError {
        return ValidationError(
            reason: "The operation does not expect a request body.",
            suggestion: "Remove the body from the request.",
            context: "Ensure the request body is only included when the OpenAPI specification allows it."
        )
    }

    static func unexpectedError(context: String) -> ValidationError {
        return ValidationError(
            reason: "An unexpected error occurred.",
            suggestion: "Check the server logs for more details.",
            context: context
        )
    }
}
