import Vapor
import Fluent

struct SequenceHandler {
    let app: Application

    func handleGenerateSequence(_ input: Operations.generateSequenceNumber.Input) async throws -> Operations.generateSequenceNumber.Output {
        guard case let .json(requestBody) = input.body else {
            throw Abort(.badRequest, reason: "Invalid content type")
        }

        let sequenceNumber = try await findOrCreateSequenceNumber(elementId: requestBody.elementId, comment: requestBody.comment)
        let response = Components.Schemas.SequenceResponse(sequenceNumber: sequenceNumber, comment: "Generated sequence number.")
        return .created(.init(body: .json(response)))
    }

    private func findOrCreateSequenceNumber(elementId: Int, comment: String?) async throws -> Int {
        return try await app.db.transaction { db in
            if let existing = try await Sequence.query(on: db).filter(\.$elementId == "\(elementId)").first() {
                existing.sequenceNumber += 1
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
