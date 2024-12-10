# Central Sequence Service


Follow along:
https://swiftpackageindex.com/apple/swift-openapi-generator/1.5.0/tutorials/swift-openapi-generator/serverswiftpm


### **Development Plan for Central Sequence Service**

#### **Project Setup and Current State**
The **Central Sequence Service** project is set up as follows:

1. **OpenAPI Specification (`openapi.yaml`)**:
   - Defines the API's structure, endpoints, request/response models, and metadata.
   - Located at: `CentralSequenceService/Sources/openapi.yaml`.

2. **OpenAPI Generator Configuration (`openapi-generator-config.yaml`)**:
   - Specifies generation of types, server code, and client code.
   - Outputs are automatically placed in:
     ```
     .build/plugins/outputs/centralsequenceservice/CentralSequenceService/destination/OpenAPIGenerator/GeneratedSources
     ```

3. **Generated Files**:
   - **`Types.swift`**: Contains data models (e.g., request and response schemas).
   - **`Server.swift`**: Implements routes and placeholder handlers for API endpoints.
   - **`Client.swift`**: Provides an SDK for consuming the API.

4. **Execution Flow**:
   - The OpenAPI Generator is invoked during the build process (`swift build`), ensuring that generated files remain up-to-date with the `openapi.yaml` specification.
   - Developers are expected to implement business logic within the generated `Server.swift`.

5. **Existing Framework**:
   - The project uses Vapor, a powerful server-side Swift framework.
   - SQLite is likely integrated for persistence, given the context of the application.

---

### **Development Objectives**
The primary goal is to implement a fully functional server application that:
1. Processes API requests as defined in `openapi.yaml`.
2. Persists and retrieves data using SQLite.
3. Synchronizes changes with Typesense.
4. Complies with the OpenAPI specification.

---

### **Detailed Development Plan**

#### **1. Confirm Environment Setup**
- Ensure the following are installed and functional:
  - Swift
  - Vapor toolbox (`brew install vapor`)
  - OpenAPI Generator (`brew install openapi-generator`)
- Validate the project builds without errors:
  ```bash
  swift build
  ```

---

#### **2. Implement Business Logic in Generated Code**

##### **a. Explore Generated Files**
- Locate the generated files in:
  ```
  .build/plugins/outputs/centralsequenceservice/CentralSequenceService/destination/OpenAPIGenerator/GeneratedSources
  ```
- Inspect `Server.swift` for placeholder route handlers.
- Identify required business logic for each endpoint based on `openapi.yaml`.

##### **b. Implement Specific Endpoints**

1. **`/sequence` (POST)**:
   - Handler in `Server.swift`:
     ```swift
     func generateSequenceNumber(req: Request) throws -> EventLoopFuture<SequenceResponse>
     ```
   - Tasks:
     - Parse the request (decode `SequenceRequest`).
     - Generate a sequence number (implement logic).
     - Persist data to SQLite.
     - Return a `SequenceResponse`.

2. **`/sequence/reorder` (PUT)**:
   - Handler in `Server.swift`:
     ```swift
     func reorderElements(req: Request) throws -> HTTPStatus
     ```
   - Tasks:
     - Parse the request (decode `ReorderRequest`).
     - Update sequence numbers in SQLite.
     - Synchronize changes with Typesense.
     - Return appropriate status.

3. **`/sequence/version` (POST)**:
   - Handler in `Server.swift`:
     ```swift
     func createNewVersion(req: Request) throws -> HTTPStatus
     ```
   - Tasks:
     - Parse the request (decode `VersionRequest`).
     - Create a new version entry in SQLite.
     - Synchronize with Typesense.
     - Return appropriate status.

---

#### **3. Integrate SQLite for Persistence**
- Add database setup code in `main.swift` or a dedicated initialization file.
- Define models for tables (`sequences`, `reorder_logs`, etc.).
- Example table for sequences:
  ```sql
  CREATE TABLE sequences (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      element_type TEXT NOT NULL,
      element_id INTEGER NOT NULL,
      sequence_number INTEGER NOT NULL,
      comment TEXT NOT NULL
  );
  ```
- Use SQLite queries for data operations.

---

#### **4. Synchronize with Typesense**
- If a Typesense SDK for Swift is available, integrate it into the project.
- Otherwise, use Vapor's `Client` to make HTTP requests to the Typesense API.
- Example synchronization logic:
  ```swift
  func synchronizeWithTypesense(sequence: Sequence, req: Request) async throws {
      let response = try await req.client.post("https://your-typesense-instance.com/sync") { req in
          try req.content.encode(sequence)
      }
      guard response.status == .ok else {
          throw Abort(.badRequest, reason: "Failed to synchronize with Typesense")
      }
  }
  ```

---

#### **5. Validate OpenAPI Compliance**
- Use Swagger UI or Postman to test endpoints and validate responses.
- Ensure all responses match the schemas defined in `openapi.yaml`.

---

#### **6. Automate Testing**
- Write unit tests for handlers in `Server.swift`.
- Use Vapor's XCTest integration for API testing.
- Example test:
  ```swift
  func testGenerateSequenceNumber() throws {
      let app = Application(.testing)
      defer { app.shutdown() }

      try app.test(.POST, "/sequence", beforeRequest: { req in
          try req.content.encode(SequenceRequest(elementType: "script", elementId: 1, comment: "Test"))
      }, afterResponse: { res in
          XCTAssertEqual(res.status, .created)
          let response = try res.content.decode(SequenceResponse.self)
          XCTAssertNotNil(response.sequenceNumber)
      })
  }
  ```

---

### **Milestones**

1. **Day 1**: Initial setup
   - Validate the build process.
   - Inspect and understand the generated code.
   - Write initial database schema and models.

2. **Day 2**: Implement core business logic
   - Complete `/sequence` (POST).
   - Add SQLite persistence for sequence data.
   - Synchronize sequence generation with Typesense.

3. **Day 3**: Implement advanced features
   - Complete `/sequence/reorder` (PUT).
   - Add logic for reordering elements in SQLite.
   - Synchronize reordered elements with Typesense.

4. **Day 4**: Finalize and test
   - Complete `/sequence/version` (POST).
   - Write unit and integration tests.
   - Validate OpenAPI compliance.

---

### **Deliverables**
1. Fully functional server application.
2. Persisted data in SQLite.
3. Synchronized data with Typesense.
4. Comprehensive tests for all endpoints.

This plan ensures a systematic approach while leveraging the existing OpenAPI Generator setup without unnecessary configuration changes. Let me know if you'd like adjustments or additional details!
