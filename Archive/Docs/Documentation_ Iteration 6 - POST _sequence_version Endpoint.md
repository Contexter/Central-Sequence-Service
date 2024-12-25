# Documentation: Iteration 6 - POST `/sequence/version` Endpoint

## Overview
In **Iteration 6**, a new POST endpoint `/sequence/version` is introduced to simulate version creation logic. This endpoint accepts a version creation request, generates a new version, stores it in memory, and returns the version details.

The implementation leverages in-memory structures for simplicity, ensuring compliance with the OpenAPI schema and providing clear responses for success and error handling.

---

## Script Details
The script for `iteration_6.swift` is as follows:

```swift
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
```

---

## Key Implementation Details

### 1. **In-Memory Version Store**
- An in-memory dictionary `versionStore` is used to track the version numbers associated with specific `elementId` keys.
- Thread safety is achieved using a `DispatchQueue` to synchronize access to the shared dictionary.

### 2. **DTOs: Request and Response**
- **VersionRequest**: Represents the input data for version creation, requiring an `elementId`.
    ```swift
    public struct VersionRequest: Codable {
        let elementId: String
    }
    ```
- **VersionResponse**: Represents the response, returning the generated version number and a message.
    ```swift
    public struct VersionResponse: Codable, Content {
        let versionNumber: Int
        let message: String
    }
    ```

### 3. **Version Generation Logic**
- If an `elementId` already exists in the `versionStore`, its version number is incremented.
- If the `elementId` does not exist, it starts with version `1`.
- Thread-safe updates are performed inside the synchronous `DispatchQueue` block:
    ```swift
    versionStoreQueue.sync {
        versionNumber = (versionStore[request.elementId] ?? 0) + 1
        versionStore[request.elementId] = versionNumber
    }
    ```

### 4. **Error-Safe Server Execution**
- The `try? app.run()` ensures the server runs without propagating errors, maintaining compatibility with existing iteration selection logic.

---

## Expected Outcomes
When a POST request is sent to `/sequence/version` with a valid `elementId`, the server generates a new version, updates the version store, and returns the details.

### **Example Request**
```bash
curl -X POST http://localhost:8080/sequence/version \
     -H "Content-Type: application/json" \
     -d '{
         "elementId": "item1"
     }'
```

### **Example Response**
```json
{
    "versionNumber": 1,
    "message": "Version successfully created for elementId: item1."
}
```

### **Request for Existing Element**
If a subsequent request is made for the same `elementId`, the version number is incremented:

#### Request:
```bash
curl -X POST http://localhost:8080/sequence/version \
     -H "Content-Type: application/json" \
     -d '{
         "elementId": "item1"
     }'
```

#### Response:
```json
{
    "versionNumber": 2,
    "message": "Version successfully created for elementId: item1."
}
```

---

## Testing Steps
1. **Run the Application**:
   Start the server with:
   ```bash
   swift run CentralSequenceService
   ```

2. **Test POST Requests**:
   - Use `curl` or any REST client (e.g., Postman) to send POST requests with valid `elementId` values.
   - Verify that versions are incremented correctly and returned in the response.

3. **Inspect Logs**:
   Check the terminal logs to confirm the server's behavior, including input decoding, version generation, and updates.

---

## Conclusion
Iteration 6 introduces a POST endpoint for version creation logic. The implementation ensures:
- Proper version tracking using an in-memory structure.
- Thread-safe version generation using `DispatchQueue`.
- Clear and structured responses for successful version creation.

This iteration builds on the previous functionality while adding a new endpoint for managing versions, adhering to clean and maintainable code practices.

