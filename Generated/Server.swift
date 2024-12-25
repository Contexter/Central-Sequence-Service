// Generated by swift-openapi-generator, do not modify.
@_spi(Generated) import OpenAPIRuntime
#if os(Linux)
@preconcurrency import struct Foundation.URL
@preconcurrency import struct Foundation.Data
@preconcurrency import struct Foundation.Date
#else
import struct Foundation.URL
import struct Foundation.Data
import struct Foundation.Date
#endif
import HTTPTypes
extension APIProtocol {
    /// Registers each operation handler with the provided transport.
    /// - Parameters:
    ///   - transport: A transport to which to register the operation handlers.
    ///   - serverURL: A URL used to determine the path prefix for registered
    ///   request handlers.
    ///   - configuration: A set of configuration values for the server.
    ///   - middlewares: A list of middlewares to call before the handler.
    internal func registerHandlers(
        on transport: any ServerTransport,
        serverURL: Foundation.URL = .defaultOpenAPIServerURL,
        configuration: Configuration = .init(),
        middlewares: [any ServerMiddleware] = []
    ) throws {
        let server = UniversalServer(
            serverURL: serverURL,
            handler: self,
            configuration: configuration,
            middlewares: middlewares
        )
        try transport.register(
            {
                try await server.generateSequenceNumber(
                    request: $0,
                    body: $1,
                    metadata: $2
                )
            },
            method: .post,
            path: server.apiPathComponentsWithServerPrefix("/sequence")
        )
        try transport.register(
            {
                try await server.reorderElements(
                    request: $0,
                    body: $1,
                    metadata: $2
                )
            },
            method: .put,
            path: server.apiPathComponentsWithServerPrefix("/sequence/reorder")
        )
        try transport.register(
            {
                try await server.createVersion(
                    request: $0,
                    body: $1,
                    metadata: $2
                )
            },
            method: .post,
            path: server.apiPathComponentsWithServerPrefix("/sequence/version")
        )
    }
}

fileprivate extension UniversalServer where APIHandler: APIProtocol {
    /// Generate Sequence Number
    ///
    /// Creates a sequence number for an element and synchronizes it with Typesense.
    ///
    ///
    /// - Remark: HTTP `POST /sequence`.
    /// - Remark: Generated from `#/paths//sequence/post(generateSequenceNumber)`.
    func generateSequenceNumber(
        request: HTTPTypes.HTTPRequest,
        body: OpenAPIRuntime.HTTPBody?,
        metadata: OpenAPIRuntime.ServerRequestMetadata
    ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
        try await handle(
            request: request,
            requestBody: body,
            metadata: metadata,
            forOperation: Operations.generateSequenceNumber.id,
            using: {
                APIHandler.generateSequenceNumber($0)
            },
            deserializer: { request, requestBody, metadata in
                let headers: Operations.generateSequenceNumber.Input.Headers = .init(accept: try converter.extractAcceptHeaderIfPresent(in: request.headerFields))
                let contentType = converter.extractContentTypeIfPresent(in: request.headerFields)
                let body: Operations.generateSequenceNumber.Input.Body
                let chosenContentType = try converter.bestContentType(
                    received: contentType,
                    options: [
                        "application/json"
                    ]
                )
                switch chosenContentType {
                case "application/json":
                    body = try await converter.getRequiredRequestBodyAsJSON(
                        Components.Schemas.SequenceRequest.self,
                        from: requestBody,
                        transforming: { value in
                            .json(value)
                        }
                    )
                default:
                    preconditionFailure("bestContentType chose an invalid content type.")
                }
                return Operations.generateSequenceNumber.Input(
                    headers: headers,
                    body: body
                )
            },
            serializer: { output, request in
                switch output {
                case let .created(value):
                    suppressUnusedWarning(value)
                    var response = HTTPTypes.HTTPResponse(soar_statusCode: 201)
                    suppressMutabilityWarning(&response)
                    let body: OpenAPIRuntime.HTTPBody
                    switch value.body {
                    case let .json(value):
                        try converter.validateAcceptIfPresent(
                            "application/json",
                            in: request.headerFields
                        )
                        body = try converter.setResponseBodyAsJSON(
                            value,
                            headerFields: &response.headerFields,
                            contentType: "application/json; charset=utf-8"
                        )
                    }
                    return (response, body)
                case let .badRequest(value):
                    suppressUnusedWarning(value)
                    var response = HTTPTypes.HTTPResponse(soar_statusCode: 400)
                    suppressMutabilityWarning(&response)
                    return (response, nil)
                case let .badGateway(value):
                    suppressUnusedWarning(value)
                    var response = HTTPTypes.HTTPResponse(soar_statusCode: 502)
                    suppressMutabilityWarning(&response)
                    return (response, nil)
                case let .internalServerError(value):
                    suppressUnusedWarning(value)
                    var response = HTTPTypes.HTTPResponse(soar_statusCode: 500)
                    suppressMutabilityWarning(&response)
                    return (response, nil)
                case let .undocumented(statusCode, _):
                    return (.init(soar_statusCode: statusCode), nil)
                }
            }
        )
    }
    /// Reorder Elements
    ///
    /// Reorders sequence numbers for elements and syncs them with Typesense.
    ///
    ///
    /// - Remark: HTTP `PUT /sequence/reorder`.
    /// - Remark: Generated from `#/paths//sequence/reorder/put(reorderElements)`.
    func reorderElements(
        request: HTTPTypes.HTTPRequest,
        body: OpenAPIRuntime.HTTPBody?,
        metadata: OpenAPIRuntime.ServerRequestMetadata
    ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
        try await handle(
            request: request,
            requestBody: body,
            metadata: metadata,
            forOperation: Operations.reorderElements.id,
            using: {
                APIHandler.reorderElements($0)
            },
            deserializer: { request, requestBody, metadata in
                let headers: Operations.reorderElements.Input.Headers = .init(accept: try converter.extractAcceptHeaderIfPresent(in: request.headerFields))
                let contentType = converter.extractContentTypeIfPresent(in: request.headerFields)
                let body: Operations.reorderElements.Input.Body
                let chosenContentType = try converter.bestContentType(
                    received: contentType,
                    options: [
                        "application/json"
                    ]
                )
                switch chosenContentType {
                case "application/json":
                    body = try await converter.getRequiredRequestBodyAsJSON(
                        Components.Schemas.ReorderRequest.self,
                        from: requestBody,
                        transforming: { value in
                            .json(value)
                        }
                    )
                default:
                    preconditionFailure("bestContentType chose an invalid content type.")
                }
                return Operations.reorderElements.Input(
                    headers: headers,
                    body: body
                )
            },
            serializer: { output, request in
                switch output {
                case let .ok(value):
                    suppressUnusedWarning(value)
                    var response = HTTPTypes.HTTPResponse(soar_statusCode: 200)
                    suppressMutabilityWarning(&response)
                    let body: OpenAPIRuntime.HTTPBody
                    switch value.body {
                    case let .json(value):
                        try converter.validateAcceptIfPresent(
                            "application/json",
                            in: request.headerFields
                        )
                        body = try converter.setResponseBodyAsJSON(
                            value,
                            headerFields: &response.headerFields,
                            contentType: "application/json; charset=utf-8"
                        )
                    }
                    return (response, body)
                case let .badRequest(value):
                    suppressUnusedWarning(value)
                    var response = HTTPTypes.HTTPResponse(soar_statusCode: 400)
                    suppressMutabilityWarning(&response)
                    return (response, nil)
                case let .badGateway(value):
                    suppressUnusedWarning(value)
                    var response = HTTPTypes.HTTPResponse(soar_statusCode: 502)
                    suppressMutabilityWarning(&response)
                    return (response, nil)
                case let .internalServerError(value):
                    suppressUnusedWarning(value)
                    var response = HTTPTypes.HTTPResponse(soar_statusCode: 500)
                    suppressMutabilityWarning(&response)
                    return (response, nil)
                case let .undocumented(statusCode, _):
                    return (.init(soar_statusCode: statusCode), nil)
                }
            }
        )
    }
    /// Create New Version
    ///
    /// Creates a new version of an element and syncs it with Typesense.
    ///
    ///
    /// - Remark: HTTP `POST /sequence/version`.
    /// - Remark: Generated from `#/paths//sequence/version/post(createVersion)`.
    func createVersion(
        request: HTTPTypes.HTTPRequest,
        body: OpenAPIRuntime.HTTPBody?,
        metadata: OpenAPIRuntime.ServerRequestMetadata
    ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
        try await handle(
            request: request,
            requestBody: body,
            metadata: metadata,
            forOperation: Operations.createVersion.id,
            using: {
                APIHandler.createVersion($0)
            },
            deserializer: { request, requestBody, metadata in
                let headers: Operations.createVersion.Input.Headers = .init(accept: try converter.extractAcceptHeaderIfPresent(in: request.headerFields))
                let contentType = converter.extractContentTypeIfPresent(in: request.headerFields)
                let body: Operations.createVersion.Input.Body
                let chosenContentType = try converter.bestContentType(
                    received: contentType,
                    options: [
                        "application/json"
                    ]
                )
                switch chosenContentType {
                case "application/json":
                    body = try await converter.getRequiredRequestBodyAsJSON(
                        Components.Schemas.VersionRequest.self,
                        from: requestBody,
                        transforming: { value in
                            .json(value)
                        }
                    )
                default:
                    preconditionFailure("bestContentType chose an invalid content type.")
                }
                return Operations.createVersion.Input(
                    headers: headers,
                    body: body
                )
            },
            serializer: { output, request in
                switch output {
                case let .created(value):
                    suppressUnusedWarning(value)
                    var response = HTTPTypes.HTTPResponse(soar_statusCode: 201)
                    suppressMutabilityWarning(&response)
                    let body: OpenAPIRuntime.HTTPBody
                    switch value.body {
                    case let .json(value):
                        try converter.validateAcceptIfPresent(
                            "application/json",
                            in: request.headerFields
                        )
                        body = try converter.setResponseBodyAsJSON(
                            value,
                            headerFields: &response.headerFields,
                            contentType: "application/json; charset=utf-8"
                        )
                    }
                    return (response, body)
                case let .badRequest(value):
                    suppressUnusedWarning(value)
                    var response = HTTPTypes.HTTPResponse(soar_statusCode: 400)
                    suppressMutabilityWarning(&response)
                    return (response, nil)
                case let .badGateway(value):
                    suppressUnusedWarning(value)
                    var response = HTTPTypes.HTTPResponse(soar_statusCode: 502)
                    suppressMutabilityWarning(&response)
                    return (response, nil)
                case let .internalServerError(value):
                    suppressUnusedWarning(value)
                    var response = HTTPTypes.HTTPResponse(soar_statusCode: 500)
                    suppressMutabilityWarning(&response)
                    return (response, nil)
                case let .undocumented(statusCode, _):
                    return (.init(soar_statusCode: statusCode), nil)
                }
            }
        )
    }
}