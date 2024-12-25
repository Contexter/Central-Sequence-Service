import Vapor

struct ReorderHandler {
    let app: Application

    func handleReorderElements(_ input: Operations.reorderElements.Input) async throws -> Operations.reorderElements.Output {
        guard case let .json(requestBody) = input.body else {
            throw Abort(.badRequest, reason: "Invalid content type")
        }

        for (elementId, newSequence) in requestBody.elements {
            guard newSequence >= 0 else {
                throw Abort(.badRequest, reason: "Sequence number must be non-negative for elementId: \(elementId)")
            }
        }

        let response = Components.Schemas.ReorderResponse(message: "Sequence numbers successfully updated.")
        return .ok(.init(body: .json(response)))
    }
}
