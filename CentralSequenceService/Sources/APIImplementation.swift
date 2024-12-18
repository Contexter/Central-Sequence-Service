import Vapor
import OpenAPIVapor

struct CentralSequenceServiceAPI: APIProtocol {
    let app: Application

    func generateSequenceNumber(_ input: Operations.generateSequenceNumber.Input) async throws -> Operations.generateSequenceNumber.Output {
        return try await SequenceHandler(app: app).handleGenerateSequence(input)
    }

    func reorderElements(_ input: Operations.reorderElements.Input) async throws -> Operations.reorderElements.Output {
        return try await ReorderHandler().handleReorderElements(input)
    }

    func createVersion(_ input: Operations.createVersion.Input) async throws -> Operations.createVersion.Output {
        return try await VersionHandler().handleCreateVersion(input)
    }
}
