import Vapor
import OpenAPIRuntime
import OpenAPIVapor
import Generated

struct CentralSequenceService: APIProtocol {
    func generateSequenceNumber(
        input: SequenceRequest,
        context: OpenAPIRuntime.ServerRequestContext
    ) async throws -> SequenceResponse {
        let uniqueID = "\(input.elementType)-\(input.elementId)"
        let newSequence = DatabaseManager.shared.incrementSequence(for: uniqueID)

        // Synchronize with Typesense (with simple retry)
        do {
            try TypesenseManager.shared.indexSequence(
                elementType: input.elementType,
                elementId: input.elementId,
                sequenceNumber: newSequence
            )
        } catch {
            // Retry logic can be more robust; for brevity just retry once
            print("Failed to index with Typesense, retrying...")
            do {
                try TypesenseManager.shared.indexSequence(
                    elementType: input.elementType,
                    elementId: input.elementId,
                    sequenceNumber: newSequence
                )
            } catch {
                // If still fails, throw an appropriate error
                throw ServerError(.badGateway, message: "Failed to synchronize with Typesense.")
            }
        }

        return SequenceResponse(sequenceNumber: newSequence, comment: "Sequence generated successfully.")
    }

    func reorderElements(
        input: ReorderRequest,
        context: OpenAPIRuntime.ServerRequestContext
    ) async throws -> ReorderResponse {
        // Prepare updates
        let updates: [(String, Int)] = input.elements.map { elem in
            ("\(input.elementType)-\(elem.elementId)", elem.newSequence)
        }

        // Update SQLite
        DatabaseManager.shared.reorderSequences(updates)

        // Synchronize with Typesense
        // If any fails, we retry or handle errors accordingly
        for (idValue, newSeq) in updates {
            let parts = idValue.split(separator: "-")
            guard parts.count == 2,
                  let elementId = Int(parts[1])
            else {
                continue
            }

            do {
                try TypesenseManager.shared.indexSequence(
                    elementType: String(parts[0]),
                    elementId: elementId,
                    sequenceNumber: newSeq
                )
            } catch {
                // Retry logic or handle errors here
                throw ServerError(.badGateway, message: "Failed to synchronize with Typesense.")
            }
        }

        let updatedElements = input.elements.map { ReorderResponse.UpdatedElements(elementId: $0.elementId, newSequence: $0.newSequence) }
        return ReorderResponse(updatedElements: updatedElements, comment: "Elements reordered successfully.")
    }

    func createVersion(
        input: VersionRequest,
        context: OpenAPIRuntime.ServerRequestContext
    ) async throws -> VersionResponse {
        // For simplicity, we’ll treat "versioning" as incrementing a sequence number or setting it to a specific value.
        // In a real application, you'd store version info and other metadata as well.
        
        let uniqueID = "\(input.elementType)-\(input.elementId)"

        // Suppose every version increment just bumps the existing sequence by 1
        let newSequence = DatabaseManager.shared.incrementSequence(for: uniqueID)

        // Synchronize with Typesense
        do {
            try TypesenseManager.shared.indexSequence(
                elementType: input.elementType,
                elementId: input.elementId,
                sequenceNumber: newSequence
            )
        } catch {
            // Retry logic or error handling
            throw ServerError(.badGateway, message: "Failed to synchronize with Typesense.")
        }

        return VersionResponse(versionNumber: newSequence, comment: "New version created successfully.")
    }
}
