import Vapor

struct VersionHandler {
    let app: Application

    func handleCreateVersion(_ input: Operations.createVersion.Input) async throws -> Operations.createVersion.Output {
        guard case let .json(requestBody) = input.body else {
            throw Abort(.badRequest, reason: "Invalid content type")
        }

        let versionNumber = (versionStore[requestBody.elementId] ?? 0) + 1
        versionStore[requestBody.elementId] = versionNumber

        let response = Components.Schemas.VersionResponse(versionNumber: versionNumber, message: "Version successfully created.")
        return .created(.init(body: .json(response)))
    }
}
