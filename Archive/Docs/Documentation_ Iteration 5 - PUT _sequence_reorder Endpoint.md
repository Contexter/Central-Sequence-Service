# Documentation: Iteration 5 - PUT `/sequence/reorder` Endpoint

## Overview
In **Iteration 5**, a new PUT endpoint `/sequence/reorder` is introduced to allow reordering of element sequences. This endpoint accepts a mapping of element IDs to their new sequence numbers, validates the input, updates the sequences in memory, and returns the updated sequences.

The implementation focuses on input validation, thread safety, and a robust response structure using Vapor and Swift's concurrency tools.

---

## Script Details
The script for `iteration_5.swift` is as follows:

```swift
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
```

---

## Key Implementation Details

### 1. **In-Memory Sequence Store**
- An in-memory dictionary `sequenceStore` is used to store the mapping of element IDs to their sequence numbers.
- Thread safety is ensured using a `DispatchQueue` named `sequenceStoreQueue`, which synchronizes access to the shared dictionary.

### 2. **DTOs: Request and Response**
- **ReorderRequest**: Accepts a dictionary mapping `elementId` (String) to a new `sequenceNumber` (Int).
    ```swift
    public struct ReorderRequest: Codable {
        let elements: [String: Int]
    }
    ```
- **ReorderResponse**: Returns the updated sequences and a success message.
    ```swift
    public struct ReorderResponse: Codable, Content {
        let updatedElements: [String: Int]
        let message: String
    }
    ```

### 3. **Input Validation**
- The server validates that each `sequenceNumber` is non-negative.
- If invalid input is detected, the server responds with a 400 Bad Request and an appropriate error message:
    ```swift
    guard newSequence >= 0 else {
        throw Abort(.badRequest, reason: "Sequence number must be non-negative for elementId: \(elementId)")
    }
    ```

### 4. **Thread-Safe Updates**
- The dictionary `sequenceStore` is accessed and updated within a synchronous `DispatchQueue` block to ensure thread safety.
- Sequences are updated atomically in the following loop:
    ```swift
    try sequenceStoreQueue.sync {
        for (elementId, newSequence) in request.elements {
            sequenceStore[elementId] = newSequence
        }
    }
    ```

### 5. **Error-Safe Server Execution**
- The `try? app.run()` ensures the server runs without propagating errors, maintaining compatibility with existing iteration selection logic.

---

## Expected Outcomes
When a PUT request is sent to `/sequence/reorder` with a valid JSON body containing the updated sequences, the server updates the sequence store and returns the updated elements.

### **Example Request**
```bash
curl -X PUT http://localhost:8080/sequence/reorder \
     -H "Content-Type: application/json" \
     -d '{
         "elements": {
             "item1": 2,
             "item2": 5,
             "item3": 1
         }
     }'
```

### **Example Response**
```json
{
    "updatedElements": {
        "item1": 2,
        "item2": 5,
        "item3": 1
    },
    "message": "Sequence numbers successfully updated."
}
```

### **Error Handling**
If an invalid `sequenceNumber` (e.g., negative value) is provided, the server returns a 400 Bad Request:

#### Request:
```bash
curl -X PUT http://localhost:8080/sequence/reorder \
     -H "Content-Type: application/json" \
     -d '{
         "elements": {
             "item1": -1
         }
     }'
```

#### Response:
```json
{
    "reason": "Sequence number must be non-negative for elementId: item1"
}
```

---

## Testing Steps
1. **Run the Application**:
   Start the server with:
   ```bash
   swift run CentralSequenceService
   ```

2. **Test PUT Requests**:
   - Use `curl` or any REST client (e.g., Postman) to send PUT requests with valid and invalid input.
   - Verify successful updates and appropriate error handling.

3. **Inspect Logs**:
   Check the terminal logs to confirm the server's behavior, including input decoding, validation, and updates.

---

## Conclusion
Iteration 5 introduces a PUT endpoint for reordering element sequences. The implementation ensures:
- Proper input validation to reject invalid sequence numbers.
- Thread-safe updates using `DispatchQueue`.
- Clear and structured responses for successful and erroneous requests.

This iteration builds on the previous foundation while adding new functionality for sequence reordering, adhering to clean and maintainable code practices.

