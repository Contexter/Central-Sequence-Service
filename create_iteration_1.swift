import Foundation

// MARK: - Helper Functions

enum FileError: Error {
    case invalidPath
}

func createDirectory(at path: String) throws {
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: path) {
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        print("Created directory: \(path)")
    } else {
        print("Directory already exists: \(path)")
    }
}

func createFile(at path: String, withContent content: String) throws {
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: path) {
        try content.write(toFile: path, atomically: true, encoding: .utf8)
        print("Created file: \(path)")
    } else {
        print("File already exists: \(path)")
    }
}

// MARK: - Directory and File Creation

let root = FileManager.default.currentDirectoryPath

let directories = [
    "Sources/App/Handlers",
    "Sources/App/Middleware",
    "Sources/App/Models",
    "Sources/App/Config",
    "Sources/Run"
]

do {
    // Create directories
    for dir in directories {
        try createDirectory(at: "\(root)/\(dir)")
    }

    // Create CentralSequenceHandler.swift
    let handlerContent = """
    import Vapor

    final class CentralSequenceHandler: APIProtocol {
        func generateSequenceNumber(_ input: SequenceRequest) async throws -> SequenceResponse {
            return SequenceResponse(sequenceNumber: 1, comment: \"Placeholder sequence number generated.\")
        }

        func reorderElements(_ input: ReorderRequest) async throws -> ReorderResponse {
            let updatedElements = input.elements.map { element in
                ReorderResponse.UpdatedElement(elementId: element.elementId, newSequence: element.newSequence)
            }
            return ReorderResponse(updatedElements: updatedElements, comment: \"Placeholder reordering complete.\")
        }

        func createVersion(_ input: VersionRequest) async throws -> VersionResponse {
            return VersionResponse(versionNumber: 1, comment: \"Placeholder version created.\")
        }
    }
    """
    try createFile(at: "\(root)/Sources/App/Handlers/CentralSequenceHandler.swift", withContent: handlerContent)

    // Create APIErrorMiddleware.swift
    let errorMiddlewareContent = """
    import Vapor

    struct APIErrorMiddleware: Middleware {
        func respond(to request: Request, chainingTo next: Responder) async throws -> Response {
            do {
                return try await next.respond(to: request)
            } catch let abort as AbortError {
                let errorResponse = ErrorResponse(
                    errorCode: \"\(abort.status.code)\",
                    message: abort.reason,
                    details: nil
                )
                let response = Response(status: abort.status)
                try response.content.encode(errorResponse)
                return response
            } catch {
                let errorResponse = ErrorResponse(
                    errorCode: \"500\",
                    message: \"Internal Server Error\",
                    details: error.localizedDescription
                )
                let response = Response(status: .internalServerError)
                try response.content.encode(errorResponse)
                return response
            }
        }
    }
    """
    try createFile(at: "\(root)/Sources/App/Middleware/APIErrorMiddleware.swift", withContent: errorMiddlewareContent)

    // Create APIKeyMiddleware.swift
    let keyMiddlewareContent = """
    import Vapor

    struct APIKeyMiddleware: Middleware {
        func respond(to request: Request, chainingTo next: Responder) async throws -> Response {
            guard let apiKey = request.headers[\"X-API-KEY\"].first,
                  apiKey == Environment.get(\"API_KEY\") else {
                throw Abort(.unauthorized, reason: \"Invalid or missing API Key.\")
            }
            return try await next.respond(to: request)
        }
    }
    """
    try createFile(at: "\(root)/Sources/App/Middleware/APIKeyMiddleware.swift", withContent: keyMiddlewareContent)

    // Create ValidationExtensions.swift
    let validationExtensionsContent = """
    import Vapor

    extension SequenceRequest: Validatable {
        public static func validations(_ validations: inout Validations) {
            validations.add(\"elementType\", as: String.self, is: .in(\"script\", \"section\", \"character\", \"action\", \"spokenWord\"))
            validations.add(\"elementId\", as: Int.self, is: .greaterThan(0))
            validations.add(\"comment\", as: String.self, is: .count(1...))
        }
    }

    extension VersionRequest: Validatable {
        public static func validations(_ validations: inout Validations) {
            validations.add(\"elementType\", as: String.self, is: .in(\"script\", \"section\", \"character\", \"action\", \"spokenWord\"))
            validations.add(\"elementId\", as: Int.self, is: .greaterThan(0))
            validations.add(\"newVersionData\", as: [String: Any].self)
            validations.add(\"comment\", as: String.self, is: .count(1...))
        }
    }
    """
    try createFile(at: "\(root)/Sources/App/Models/ValidationExtensions.swift", withContent: validationExtensionsContent)

    // Create EnvironmentConfig.swift
    let environmentConfigContent = """
    import Vapor

    struct EnvironmentConfig {
        static func baseURL(for environment: Environment) -> String {
            switch environment {
            case .production:
                return \"https://centralsequence.fountain.coach\"
            case .testing:
                return \"https://staging.centralsequence.fountain.coach\"
            default:
                return \"http://localhost:8080\"
            }
        }
    }
    """
    try createFile(at: "\(root)/Sources/App/Config/EnvironmentConfig.swift", withContent: environmentConfigContent)

    // Create main.swift
    let mainContent = """
    import Vapor
    import OpenAPIGeneratorServer

    @main
    struct App {
        static func main() throws {
            let app = Application()
            defer { app.shutdown() }

            let handler = CentralSequenceHandler()
            try configureRouter(app: app, handler: handler)

            app.middleware.use(APIErrorMiddleware())
            app.middleware.use(APIKeyMiddleware())

            let baseURL = EnvironmentConfig.baseURL(for: app.environment)
            app.logger.info(\"Base URL: \(baseURL)\")

            try app.run()
        }
    }

    func configureRouter(app: Application, handler: APIProtocol) throws {
        let router = try ServerRouter(
            app: app,
            handler: handler,
            specification: URL(fileURLWithPath: \"./openapi.yaml\")
        )
        app.middleware.use(router.middleware)
    }
    """
    try createFile(at: "\(root)/Sources/Run/main.swift", withContent: mainContent)

} catch {
    print("Error: \(error)")
}

