import Vapor
import OpenAPIKit

struct BodyValidator: Validator {
    func validate(request: Request, operation: OpenAPI.Operation) throws {
        guard let contentType = request.headers.contentType?.description else {
            throw ValidationErrorFactory.missingContentTypeError()
        }

        guard let requestBody = operation.requestBody?.value else {
            throw ValidationErrorFactory.unexpectedRequestBodyError()
        }

        // Debug log the entire requestBody
        debugPrint("Raw requestBody:", requestBody)

        // Attempt a safe cast for `content`
        if let content = requestBody as? [String: Any] {
            debugPrint("requestBody content keys:", content.keys)
        } else {
            throw ValidationErrorFactory.unsupportedContentTypeError(contentType: contentType)
        }
    }
}
