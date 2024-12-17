import Vapor
import Atomics

// In-memory store for unique sequence numbers with thread safety
private var sequenceStore: [String: Int] = [:]
private let sequenceStoreQueue = DispatchQueue(label: "com.centralSequenceService.sequenceStore")
private var nextSequenceNumber = ManagedAtomic(1)

// Request and Response DTOs
public struct SequenceRequest: Codable {
    let elementId: String
}

public struct SequenceResponse: Codable, Content {
    let sequenceNumber: Int
    let message: String
}

public func iteration_4(app: Application) {
    print("Iteration 4 logic executed. Setting up POST /sequence endpoint...")

    // POST /sequence endpoint
    app.post("sequence") { req -> SequenceResponse in
        print("Received POST request on /sequence")
        
        let request = try req.content.decode(SequenceRequest.self)
        print("Decoded request with elementId: \(request.elementId)")

        // Input validation for elementId
        guard !request.elementId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Validation failed: elementId is empty or whitespace")
            throw Abort(.badRequest, reason: "elementId cannot be empty or contain only whitespace.")
        }

        var sequenceNumber: Int
        sequenceStoreQueue.sync {
            if sequenceStore[request.elementId] == nil {
                print("Generating new sequence number for elementId: \(request.elementId)")
                sequenceStore[request.elementId] = nextSequenceNumber.loadThenWrappingIncrement(ordering: .relaxed)
            }
            sequenceNumber = sequenceStore[request.elementId]!
            print("Retrieved sequence number: \(sequenceNumber) for elementId: \(request.elementId)")
        }
        
        print("Successfully generated response for elementId: \(request.elementId)")
        return SequenceResponse(
            sequenceNumber: sequenceNumber,
            message: "Sequence number successfully generated."
        )
    }
    
    print("POST /sequence endpoint is ready at http://localhost:8080/sequence")
}
