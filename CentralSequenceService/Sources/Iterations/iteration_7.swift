import Vapor
import Fluent
import OpenAPIVapor

/// Implement APIProtocol
struct CentralSequenceServiceAPI: APIProtocol {
    let app: Application

    // POST /sequence: Generate Sequence Number
    func generateSequenceNumber(_ input: Operations.generateSequenceNumber.Input) async throws -> Operations.generateSequenceNumber.Output {
        guard case let .json(requestBody) = input.body else {
            throw Abort(.badRequest, reason: "Invalid content type")
        }

        let sequenceNumber = try await findOrCreateSequenceNumber(elementId: requestBody.elementId, comment: requestBody.comment)

        let response = Components.Schemas.SequenceResponse(
            sequenceNumber: sequenceNumber,
            comment: "Generated sequence number for \(requestBody.elementType)"
        )
        return .created(.init(body: .json(response)))
    }

    // PUT /sequence/reorder: Stub implementation
    func reorderElements(_ input: Operations.reorderElements.Input) async throws -> Operations.reorderElements.Output {
        return .ok(.init(body: .json(Components.Schemas.ReorderResponse(comment: "Reordered successfully"))))
    }

    // POST /sequence/version: Stub implementation
    func createVersion(_ input: Operations.createVersion.Input) async throws -> Operations.createVersion.Output {
        return .created(.init(body: .json(Components.Schemas.VersionResponse(comment: "Version created successfully"))))
    }

    // Helper Function: Find or Create Sequence Number
    private func findOrCreateSequenceNumber(elementId: Int, comment: String?) async throws -> Int {
        return try await app.db.transaction { db in
            if let existing = try await Sequence.query(on: db)
                .filter(\.$elementId == "\(elementId)")
                .first() {
                existing.sequenceNumber += 1
                existing.comment = comment
                try await existing.save(on: db)
                return existing.sequenceNumber
            } else {
                let newSequence = Sequence(elementId: "\(elementId)", sequenceNumber: 1, comment: comment)
                try await newSequence.save(on: db)
                return newSequence.sequenceNumber
            }
        }
    }
}

/// Register the handlers with VaporTransport
public func iteration_7(app: Application) {
    do {
        let transport = VaporTransport(routesBuilder: app)
        let api = CentralSequenceServiceAPI(app: app)
        try api.registerHandlers(on: transport)
        app.logger.info("Iteration 7: Routes registered successfully with OpenAPIVapor.")
    } catch {
        app.logger.error("Failed to register OpenAPI handlers: \(error)")
    }

    _ = try? app.run()
}
