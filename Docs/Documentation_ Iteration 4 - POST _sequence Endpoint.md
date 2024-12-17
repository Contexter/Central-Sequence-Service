# Documentation: Iteration 4 - POST `/sequence` Endpoint

## Overview
In **Iteration 4**, a new POST endpoint `/sequence` is introduced to generate and return unique sequence numbers for incoming requests. This iteration focuses on implementing thread-safe in-memory storage for sequence generation while ensuring clean input validation and robust logging for easier debugging.

The implementation uses **Vapor** for routing and Swift's `Atomics` library for thread-safe atomic operations.

---

## Script Details
The script for `iteration_4.swift` is as follows:

```swift
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
```

---

## Key Implementation Details

### 1. **Thread-Safe In-Memory Store**
- The `sequenceStore` is a dictionary (`[String: Int]`) that maps each unique `elementId` to a sequence number.
- Thread safety is achieved using a `DispatchQueue` named `sequenceStoreQueue`, ensuring atomic access to the store.

### 2. **Atomic Integer for Sequence Generation**
- `ManagedAtomic` (from the Swift `Atomics` library) ensures the counter `nextSequenceNumber` is incremented safely in concurrent environments.
- This approach eliminates the need for manual locks on the counter.

### 3. **Input Validation**
- The `elementId` is validated to ensure it is not empty or whitespace-only. If validation fails, an HTTP 400 Bad Request is thrown:

```swift
guard !request.elementId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
    throw Abort(.badRequest, reason: "elementId cannot be empty or contain only whitespace.")
}
```

### 4. **Logging for Debugging**
- Print statements are added throughout the logic to provide insights into:
    - When a request is received.
    - Input decoding and validation.
    - Sequence number generation.
    - Final response preparation.

This facilitates easier debugging and traceability during development.

### 5. **Response Encodable**
- The `SequenceResponse` structure now conforms to `Content` to make it compatible with Vapor's response handling requirements.

---

## Expected Outcomes
When a POST request is sent to `/sequence` with a valid JSON body containing `elementId`, the server responds with a sequence number.

### **Example Request**
```bash
curl -X POST http://localhost:8080/sequence \
     -H "Content-Type: application/json" \
     -d '{"elementId": "item1"}'
```

### **Example Response**
```json
{
    "sequenceNumber": 1,
    "message": "Sequence number successfully generated."
}
```

### **Handling Duplicate Requests**
If the same `elementId` is sent again, the server will return the previously assigned sequence number:

#### Request:
```bash
curl -X POST http://localhost:8080/sequence \
     -H "Content-Type: application/json" \
     -d '{"elementId": "item1"}'
```

#### Response:
```json
{
    "sequenceNumber": 1,
    "message": "Sequence number successfully generated."
}
```

### **Error Handling**
If an invalid `elementId` (e.g., empty string) is sent, the server returns a 400 Bad Request:

#### Request:
```bash
curl -X POST http://localhost:8080/sequence \
     -H "Content-Type: application/json" \
     -d '{"elementId": " "}'
```

#### Response:
```json
{
    "error": true,
    "reason": "elementId cannot be empty or contain only whitespace."
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
   - Use `curl` or any REST client (e.g., Postman) to send POST requests.
   - Validate successful responses and error handling.

3. **Inspect Logs**:
   Check the printed logs in the terminal to ensure the flow of execution matches expectations.

---

## Conclusion
Iteration 4 introduces a robust and thread-safe endpoint for generating unique sequence numbers. The implementation ensures:
- Proper input validation.
- Thread safety using `DispatchQueue` and `ManagedAtomic`.
- Debugging clarity through comprehensive logs.
- Conformance to Vapor's `Content` protocol for response encoding.

This iteration provides a scalable foundation for sequence generation while adhering to clean and maintainable code practices.

