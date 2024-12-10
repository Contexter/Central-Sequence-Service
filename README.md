 ** Development Plan for Central Sequence Service**

#### **Project Setup and Current State**
The **Central Sequence Service** project is structured as follows:

1. **OpenAPI Specification (`openapi.yaml`)**:
   - Defines the API's structure, endpoints, and schemas.
   - Location: `CentralSequenceService/Sources/openapi.yaml`.

2. **OpenAPI Generator Configuration (`openapi-generator-config.yaml`)**:
   - Specifies generation of types, server code, and client code.
   - Outputs to:
     ```
     .build/plugins/outputs/centralsequenceservice/CentralSequenceService/destination/OpenAPIGenerator/GeneratedSources
     ```

3. **Generated Files**:
   - **`Types.swift`**: Data models (e.g., request and response schemas).
   - **`Server.swift`**: Boilerplate route handlers for the API endpoints.
   - **`Client.swift`**: Optional client SDK for interacting with the API.

4. **Development Flow**:
   - The OpenAPI Generator is automatically triggered during the build process.
   - Business logic is implemented in the generated `Server.swift`.

---

### **Development Objectives**
Deliver a functional server application that:
1. Handles all API requests per the `openapi.yaml` definition.
2. Persists and retrieves data using SQLite.
3. Synchronizes data with Typesense.
4. Complies with the OpenAPI specification.

---

### **Detailed Development Plan**

#### **1. Implement Business Logic in Generated Code**

##### **a. Examine Generated Files**
- Locate the generated files:
  ```
  .build/plugins/outputs/centralsequenceservice/CentralSequenceService/destination/OpenAPIGenerator/GeneratedSources
  ```
- Focus on `Server.swift` for route handlers and `Types.swift` for data models.

##### **b. Implement Endpoints**

1. **`/sequence` (POST)**:
   - Handler in `Server.swift`:
     ```swift
     func generateSequenceNumber(req: Request) throws -> EventLoopFuture<SequenceResponse>
     ```
   - **Tasks**:
     - Parse request (decode `SequenceRequest`).
     - Generate a sequence number using business logic.
     - Persist the sequence number in SQLite.
     - Return a `SequenceResponse`.

2. **`/sequence/reorder` (PUT)**:
   - Handler in `Server.swift`:
     ```swift
     func reorderElements(req: Request) throws -> HTTPStatus
     ```
   - **Tasks**:
     - Parse request (decode `ReorderRequest`).
     - Update sequence numbers in SQLite.
     - Synchronize the reordered data with Typesense.
     - Return success status.

3. **`/sequence/version` (POST)**:
   - Handler in `Server.swift`:
     ```swift
     func createNewVersion(req: Request) throws -> HTTPStatus
     ```
   - **Tasks**:
     - Parse request (decode `VersionRequest`).
     - Create a new version entry in SQLite.
     - Synchronize with Typesense.
     - Return success status.

---

#### **2. Integrate SQLite for Persistence**

- **Define Schema**:
  Use SQLite to store sequence data. Example schema:
  ```sql
  CREATE TABLE sequences (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      element_type TEXT NOT NULL,
      element_id INTEGER NOT NULL,
      sequence_number INTEGER NOT NULL,
      comment TEXT NOT NULL
  );
  ```

- **Implement Models**:
  Define Swift models to map database entries.

  Example:
  ```swift
  import Vapor
  import FluentSQLiteDriver

  final class Sequence: Model, Content {
      static let schema = "sequences"

      @ID(key: .id)
      var id: UUID?

      @Field(key: "element_type")
      var elementType: String

      @Field(key: "element_id")
      var elementId: Int

      @Field(key: "sequence_number")
      var sequenceNumber: Int

      @Field(key: "comment")
      var comment: String
  }
  ```

- **Use Queries in Handlers**:
  Example for persisting a sequence:
  ```swift
  try await Sequence.query(on: req.db)
      .create(Sequence(elementType: sequenceRequest.elementType, elementId: sequenceRequest.elementId, sequenceNumber: generatedNumber, comment: "Generated successfully"))
  ```

---

#### **3. Synchronize with Typesense**

- If a Swift SDK for Typesense exists, integrate it. Otherwise, use Vapor's HTTP client.
- **Example Synchronization Logic**:
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

- Call this function from endpoint handlers after database operations.

---

#### **4. Validate OpenAPI Compliance**

- Use Swagger UI or Postman to validate endpoints against the `openapi.yaml` definition.
- Ensure all request/response payloads match their schemas.

---

#### **5. Automate Testing**

- Write unit and integration tests for endpoints.
- Example test for `/sequence`:
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

### **Timeline**

#### **Day 1: Setup and Planning**
- Validate project builds correctly.
- Inspect and understand `openapi.yaml`, `Server.swift`, and `Types.swift`.

#### **Day 2: Core Endpoint Implementation**
- Implement `/sequence` (POST):
  - Generate sequence numbers.
  - Persist data to SQLite.
  - Synchronize with Typesense.

#### **Day 3: Advanced Features**
- Implement `/sequence/reorder` (PUT) and `/sequence/version` (POST).
- Write database queries and synchronization logic for these endpoints.

#### **Day 4: Testing and Validation**
- Write unit tests for all endpoints.
- Validate API compliance with OpenAPI spec using Swagger or Postman.

#### **Day 5: Finalization**
- Optimize code and refactor if needed.
- Prepare documentation for the implemented API.

---

### **Deliverables**
1. Fully functional server with SQLite persistence and Typesense synchronization.
2. Automated tests for all endpoints.
3. Documentation and validation reports for OpenAPI compliance.
