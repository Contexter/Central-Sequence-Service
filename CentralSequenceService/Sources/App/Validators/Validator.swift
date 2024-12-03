import Vapor
import OpenAPIKit

protocol Validator {
    func validate(request: Request, operation: OpenAPI.Operation) throws
}
