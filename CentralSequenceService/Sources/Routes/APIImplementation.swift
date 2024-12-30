import Vapor

struct APIImplementation: APIProtocol {

    // MARK: - Generate Sequence Number
    func generateSequenceNumber(
        _ input: Operations.generateSequenceNumber.Input
    ) async throws -> Operations.generateSequenceNumber.Output {

        // Construct the response based on the defined schema
        let response = Components.Schemas.SequenceResponse(
            sequenceNumber: 1,
            comment: "New sequence initialized."
        )

        return .created(.init(body: .json(response)))
    }

    // MARK: - Reorder Elements
    func reorderElements(
        _ input: Operations.reorderElements.Input
    ) async throws -> Operations.reorderElements.Output {

        // Extract elements from the request body
        guard case let .json(body) = input.body else {
            throw Abort(.badRequest, reason: "Invalid body format")
        }

        // Map elements to updated elements payload
        let updatedElements = body.elements.map {
            Components.Schemas.ReorderResponse.updatedElementsPayloadPayload(
                elementId: $0.elementId,
                newSequence: $0.newSequence
            )
        }

        // Construct the response
        let response = Components.Schemas.ReorderResponse(
            updatedElements: updatedElements,
            comment: "Elements reordered successfully."
        )

        return .ok(.init(body: .json(response)))
    }

    // MARK: - Create Version
    func createVersion(
        _ input: Operations.createVersion.Input
    ) async throws -> Operations.createVersion.Output {

        // Construct the response based on the defined schema
        let response = Components.Schemas.VersionResponse(
            versionNumber: 1,
            comment: "Version 1 created."
        )

        return .created(.init(body: .json(response)))
    }
}
