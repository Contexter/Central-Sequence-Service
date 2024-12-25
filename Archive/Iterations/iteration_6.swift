import Vapor

// In-memory structure to store versions
private var versionStore: [String: Int] = [:]
private let versionStoreQueue = DispatchQueue(label: "com.centralSequenceService.versionStore")

// DTOs for VersionRequest and VersionResponse
public struct VersionRequest: Codable {
    let elementId: String
}

public struct VersionResponse: Codable, Content {
    let versionNumber: Int
    let message: String
}

public func iteration_6(app: Application) {
    print("Iteration 6 logic executed. Setting up POST /sequence/version endpoint...")

    // POST /sequence/version endpoint
    app.post("sequence", "version") { req -> VersionResponse in
        print("Received POST request on /sequence/version")

        let request = try req.content.decode(VersionRequest.self)
        print("Decoded VersionRequest for elementId: \(request.elementId)")

        var versionNumber: Int = 0

        // Increment and store version
        versionStoreQueue.sync {
            versionNumber = (versionStore[request.elementId] ?? 0) + 1
            versionStore[request.elementId] = versionNumber
            print("Generated version \(versionNumber) for elementId: \(request.elementId)")
        }

        return VersionResponse(
            versionNumber: versionNumber,
            message: "Version successfully created for elementId: \(request.elementId)."
        )
    }

    print("POST /sequence/version endpoint is ready at http://localhost:8080/sequence/version")
    _ = try? app.run() // Keeps the server running without propagating errors
}
