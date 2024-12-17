import Vapor

// In-memory dictionary to store sequences
private var sequenceStore: [String: Int] = [:]
private let sequenceStoreQueue = DispatchQueue(label: "com.centralSequenceService.sequenceStore")

// DTOs for ReorderRequest and ReorderResponse
public struct ReorderRequest: Codable {
    let elements: [String: Int] // Dictionary mapping element IDs to new sequence numbers
}

public struct ReorderResponse: Codable, Content {
    let updatedElements: [String: Int] // Updated element sequences
    let message: String
}

public func iteration_5(app: Application) {
    print("Iteration 5 logic executed. Setting up PUT /sequence/reorder endpoint...")

    // PUT /sequence/reorder endpoint
    app.put("sequence", "reorder") { req -> ReorderResponse in
        print("Received PUT request on /sequence/reorder")

        let request = try req.content.decode(ReorderRequest.self)
        print("Decoded ReorderRequest: \(request.elements)")

        var updatedElements: [String: Int] = [:]

        // Validate and update sequences
        try sequenceStoreQueue.sync {
            for (elementId, newSequence) in request.elements {
                guard newSequence >= 0 else {
                    print("Validation failed: Invalid sequence number for elementId: \(elementId)")
                    throw Abort(.badRequest, reason: "Sequence number must be non-negative for elementId: \(elementId)")
                }
                print("Updating sequence for elementId: \(elementId) to \(newSequence)")
                sequenceStore[elementId] = newSequence
                updatedElements[elementId] = newSequence
            }
        }

        print("Successfully updated sequences: \(updatedElements)")

        return ReorderResponse(
            updatedElements: updatedElements,
            message: "Sequence numbers successfully updated."
        )
    }

    print("PUT /sequence/reorder endpoint is ready at http://localhost:8080/sequence/reorder")
    _ = try? app.run() // Keeps the server running without propagating errors
}
