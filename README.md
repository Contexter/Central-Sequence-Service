# **Central Sequence Service: Comprehensive Implementation Guide**

This guide provides a **detailed, step-by-step** approach for building the Central Sequence Service—a Swift-based application leveraging Vapor, SQLite, and Typesense, along with OpenAPI for server definitions. It covers everything from initial project setup, through database configuration, Typesense integration, service logic, routing, error handling, testing, and deployment considerations.

## **Overview**

The Central Sequence Service is intended to:

- **Assign and manage sequence numbers** for arbitrary “elements” (e.g., items in a list).
- **Reorder elements** by updating their sequence numbers.
- **Create and manage versions** of these elements.
- **Synchronize changes with Typesense** for fast and flexible searching.

This system consists of clearly separated layers:

1. **Controllers** for handling HTTP requests.
2. **Services** for business logic and data manipulation.
3. **Models** for defining request/response and internal data structures.
4. **Configuration and Middleware** for error handling and application setup.
5. **Database Layer** for persistent storage, using SQLite.
6. **Search Layer Integration** with Typesense for indexing and quick lookups.
7. **Tests** for ensuring correctness and reliability.

---

## **Project Structure**

A well-organized file structure is critical for maintainability and clarity:

```
CentralSequenceService/
├── Sources/
│   ├── CentralSequenceService/
│   │   ├── main.swift                            # Application entry point
│   │   ├── Controllers/                          # HTTP route handlers
│   │   │   ├── SequenceController.swift          # Routes for sequence operations
│   │   │   ├── ReorderController.swift           # Routes for reordering elements
│   │   │   ├── VersionController.swift           # Routes for versioning elements
│   │   ├── Services/                             # Business logic (independent of HTTP)
│   │   │   ├── SequenceService.swift             # Sequence number generation logic
│   │   │   ├── ReorderService.swift              # Reordering logic
│   │   │   ├── VersionService.swift              # Versioning logic
│   │   │   ├── DatabaseService.swift             # Database operations
│   │   │   ├── TypesenseService.swift            # Typesense synchronization
│   │   ├── Models/                               # Data models & DTOs
│   │   │   ├── SequenceModels.swift              # Sequence request/response models
│   │   │   ├── ReorderModels.swift               # Reorder request/response models
│   │   │   ├── VersionModels.swift               # Version request/response models
│   │   │   ├── ErrorModels.swift                 # Error response models
│   │   ├── Config/                               # Configuration & database setup
│   │   │   ├── DatabaseConfig.swift              # SQLite DB setup and migrations
│   │   │   ├── TypesenseConfig.swift             # Typesense client setup & schema
│   │   ├── Middleware/                           # Request and error handling
│   │   │   ├── ErrorMiddleware.swift             # Central error response handling
│   │   ├── GeneratedSources/                     # OpenAPI-generated code (if applicable)
│   │   │   ├── Server.swift                      # OpenAPI server scaffolding
│   │   │   ├── Types.swift                       # OpenAPI-generated types
│   │   ├── Tests/                                # Test cases
│   │   │   ├── ServiceTests.swift                # Unit tests for services
│   │   │   ├── IntegrationTests.swift            # Integration tests (end-to-end)
│   │   │   ├── MiddlewareTests.swift             # Tests for middleware
├── Package.swift                                  # SwiftPM manifest
```

---

## **1. Initial Project Setup**

### **Create and Configure the Swift Package**

1. **Initialize the project:**
   ```bash
   mkdir CentralSequenceService
   cd CentralSequenceService
   swift package init --type executable
   ```

   This creates a basic Swift package with a `main.swift` and `Package.swift`.

2. **Add Dependencies in `Package.swift`:**

   ```swift
   // swift-tools-version:5.7
   import PackageDescription

   let package = Package(
       name: "CentralSequenceService",
       platforms: [
           .macOS(.v12)
       ],
       products: [
           .executable(name: "CentralSequenceService", targets: ["CentralSequenceService"])
       ],
       dependencies: [
           .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
           .package(url: "https://github.com/vapor/sqlite-nio.git", from: "1.0.0"),
           .package(url: "https://github.com/typesense/typesense-swift.git", from: "1.0.0"),
           .package(url: "https://github.com/swift-server/swift-openapi-runtime.git", from: "0.1.0")
       ],
       targets: [
           .target(
               name: "CentralSequenceService",
               dependencies: [
                   .product(name: "Vapor", package: "vapor"),
                   .product(name: "SQLiteNIO", package: "sqlite-nio"),
                   .product(name: "Typesense", package: "typesense-swift"),
                   .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime")
               ],
               path: "Sources/CentralSequenceService"
           ),
           .testTarget(
               name: "CentralSequenceServiceTests",
               dependencies: ["CentralSequenceService"],
               path: "Sources/CentralSequenceService/Tests"
           )
       ]
   )
   ```

3. **Fetch and resolve dependencies:**
   ```bash
   swift package update
   swift build
   ```

---

## **2. Database Setup**

### **SQLite Integration & Schema**

We use SQLite via `sqlite-nio` and Vapor’s Fluent for schema management. Although Fluent isn’t explicitly required, it’s often simpler. If you prefer raw SQL, you can do that too—this guide assumes a simple, custom database service using SQLiteNIO directly.

**File: `DatabaseConfig.swift`**

```swift
import Vapor
import SQLiteNIO

struct DatabaseConfig {
    static func initialize(on app: Application) throws -> SQLiteConnectionSource {
        // Configure SQLite database
        app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
        
        let database = app.databases.database(.sqlite, logger: app.logger, on: app.eventLoopGroup.next())
        guard let db = database else {
            throw Abort(.internalServerError, reason: "Database could not be initialized.")
        }

        // Run migrations to ensure tables are set up
        try runMigrations(db: db).wait()

        return SQLiteConnectionSource(database: db)
    }

    static func runMigrations(db: Database) async throws {
        // Example schema creation:
        // Creates a table for sequences:
        // CREATE TABLE IF NOT EXISTS sequences (
        //   id TEXT PRIMARY KEY,
        //   element_type TEXT,
        //   element_id TEXT,
        //   sequence_number INTEGER,
        //   comment TEXT,
        //   version_number INTEGER DEFAULT 1
        // );

        try await db.execute(sql: """
        CREATE TABLE IF NOT EXISTS sequences (
            id TEXT PRIMARY KEY NOT NULL,
            element_type TEXT NOT NULL,
            element_id TEXT NOT NULL,
            sequence_number INTEGER NOT NULL,
            comment TEXT,
            version_number INTEGER NOT NULL DEFAULT 1
        );
        """, bindings: [])
    }
}
```

**Data Model Note:**  
We are not using Fluent's model objects here for brevity, but you could. The `sequences` table stores sequence data including a version number. For complex schema, add additional tables or columns as needed.

---

## **3. Typesense Setup**

Typesense is a search engine for indexing and retrieving documents quickly. We assume a single collection to store elements with their sequence data.

**File: `TypesenseConfig.swift`**

```swift
import Typesense

struct TypesenseConfig {
    static func initialize(client: TypesenseClient) async throws {
        let schema = CollectionSchema(
            name: "elements",
            fields: [
                Field(name: "element_id", type: .string),
                Field(name: "element_type", type: .string),
                Field(name: "sequence_number", type: .int32)
            ],
            defaultSortingField: "sequence_number"
        )
        // Create collection if it doesn't exist
        let collections = try await client.collections.retrieve()
        if !collections.contains(where: { $0.name == "elements" }) {
            try await client.collections.create(schema: schema)
        }
    }
}
```

You’ll call `TypesenseConfig.initialize(client:)` once your Typesense client is ready.

---

## **4. Application Entry Point**

**File: `main.swift`**

This file brings everything together:  
- Creates an `Application` instance.
- Configures database and Typesense.
- Instantiates services.
- Registers routes.
- Applies middleware.
- Runs the server.

```swift
import Vapor
import SQLiteNIO
import Typesense

@main
struct Run {
    static func main() async throws {
        let app = Application(.development)
        defer { app.shutdown() }

        // Initialize database
        let database = try DatabaseConfig.initialize(on: app)

        // Setup Typesense
        let typesenseClient = TypesenseClient(
            configuration: TypesenseConfiguration(
                nodes: [TypesenseNode(host: "localhost", port: 8108, `protocol`: "http")],
                apiKey: "your-api-key"
            )
        )
        try await TypesenseConfig.initialize(client: typesenseClient)

        // Initialize services
        let databaseService = DatabaseService(database: database)
        let typesenseService = TypesenseService(client: typesenseClient)
        let sequenceService = SequenceService(databaseService: databaseService, typesenseService: typesenseService)
        let reorderService = ReorderService(databaseService: databaseService, typesenseService: typesenseService)
        let versionService = VersionService(databaseService: databaseService, typesenseService: typesenseService)

        // Register routes
        try routes(app, sequenceService: sequenceService, reorderService: reorderService, versionService: versionService)
        
        // Middleware
        app.middleware.use(ErrorMiddleware())

        try app.run()
    }

    static func routes(
        _ app: Application,
        sequenceService: SequenceServiceProtocol,
        reorderService: ReorderServiceProtocol,
        versionService: VersionServiceProtocol
    ) throws {
        app.routes.group("api") { api in
            try SequenceController(service: sequenceService).registerRoutes(routes: api)
            try ReorderController(service: reorderService).registerRoutes(routes: api)
            try VersionController(service: versionService).registerRoutes(routes: api)
        }
    }
}
```

---

## **5. Models**

**File: `SequenceModels.swift`**

```swift
struct SequenceRequest: Content {
    let elementType: String
    let elementId: String
    let comment: String?
}

struct SequenceResponse: Content {
    let sequenceNumber: Int
    let comment: String
}
```

**File: `ReorderModels.swift`**

```swift
struct ReorderElement: Content {
    let elementId: String
    let newSequence: Int
}

struct ReorderRequest: Content {
    let elements: [ReorderElement]
}

struct ReorderResponse: Content {
    let comment: String
}
```

**File: `VersionModels.swift`**

```swift
struct VersionRequest: Content {
    let elementId: String
    let newVersionData: [String: AnyCodable] // or a structured type
    let comment: String?
}

struct VersionResponse: Content {
    let versionNumber: Int
    let comment: String
}
```

**File: `ErrorModels.swift`**

```swift
struct ErrorResponse: Content {
    let message: String
}
```

---

## **6. Controllers**

Controllers map HTTP endpoints to service calls.

**File: `SequenceController.swift`**

```swift
import Vapor

final class SequenceController {
    private let service: SequenceServiceProtocol

    init(service: SequenceServiceProtocol) {
        self.service = service
    }

    func registerRoutes(routes: RoutesBuilder) throws {
        let seq = routes.grouped("sequence")
        seq.post("generate", use: generateSequence)
    }

    func generateSequence(req: Request) async throws -> SequenceResponse {
        let requestBody = try req.content.decode(SequenceRequest.self)
        return try await service.generateSequence(for: requestBody)
    }
}
```

**File: `ReorderController.swift`**

```swift
import Vapor

final class ReorderController {
    private let service: ReorderServiceProtocol

    init(service: ReorderServiceProtocol) {
        self.service = service
    }

    func registerRoutes(routes: RoutesBuilder) throws {
        let reorder = routes.grouped("sequence", "reorder")
        reorder.put("", use: reorderElements)
    }

    func reorderElements(req: Request) async throws -> ReorderResponse {
        let requestBody = try req.content.decode(ReorderRequest.self)
        return try await service.reorderElements(for: requestBody)
    }
}
```

**File: `VersionController.swift`**

```swift
import Vapor

final class VersionController {
    private let service: VersionServiceProtocol

    init(service: VersionServiceProtocol) {
        self.service = service
    }

    func registerRoutes(routes: RoutesBuilder) throws {
        let version = routes.grouped("sequence", "version")
        version.post("", use: createVersion)
    }

    func createVersion(req: Request) async throws -> VersionResponse {
        let requestBody = try req.content.decode(VersionRequest.self)
        return try await service.createVersion(for: requestBody)
    }
}
```

---

## **7. Services**

Services contain core business logic and interact with the database and Typesense.

### **File: `DatabaseService.swift`**

```swift
import Vapor

protocol DatabaseServiceProtocol {
    func saveSequence(elementType: String, elementId: String, sequenceNumber: Int, comment: String?) async throws
    func updateSequence(elementId: String, newSequence: Int) async throws
    func createVersion(elementId: String, versionData: [String: AnyCodable], comment: String?) async throws -> Int
}

final class DatabaseService: DatabaseServiceProtocol {
    let database: SQLiteConnectionSource

    init(database: SQLiteConnectionSource) {
        self.database = database
    }

    func saveSequence(elementType: String, elementId: String, sequenceNumber: Int, comment: String?) async throws {
        let id = UUID().uuidString
        try await database.database.execute(sql: """
            INSERT INTO sequences (id, element_type, element_id, sequence_number, comment)
            VALUES (?, ?, ?, ?, ?)
            """, [
                .bind(id), .bind(elementType), .bind(elementId), .bind(sequenceNumber), .bind(comment)
            ]
        )
    }

    func updateSequence(elementId: String, newSequence: Int) async throws {
        try await database.database.execute(sql: """
            UPDATE sequences SET sequence_number = ? WHERE element_id = ?
            """, [
                .bind(newSequence), .bind(elementId)
            ]
        )
    }

    func createVersion(elementId: String, versionData: [String: AnyCodable], comment: String?) async throws -> Int {
        // Simple versioning: increment version_number for the given element_id
        // Retrieve current version:
        let rows = try await database.database.query(sql: "SELECT version_number FROM sequences WHERE element_id = ?", [.bind(elementId)])
        guard let row = rows.first else {
            throw Abort(.notFound, reason: "No element found with that ID")
        }

        let currentVersion = try row.decode(column: "version_number", as: Int.self)
        let newVersion = currentVersion + 1

        // Update version and comment:
        try await database.database.execute(sql: """
            UPDATE sequences SET version_number = ?, comment = ? WHERE element_id = ?
            """, [
                .bind(newVersion), .bind(comment), .bind(elementId)
            ]
        )

        // Optionally store versionData in a separate versions table if needed
        // For simplicity, we assume version_data stored elsewhere or not at all.

        return newVersion
    }
}
```

### **File: `TypesenseService.swift`**

```swift
import Typesense

protocol TypesenseServiceProtocol {
    func synchronizeSequence(id: String, sequenceNumber: Int) async throws
    func synchronizeReorder(_ elements: [ReorderElement]) async throws
    func synchronizeVersion(_ elementId: String, versionNumber: Int) async throws
}

final class TypesenseService: TypesenseServiceProtocol {
    let client: TypesenseClient

    init(client: TypesenseClient) {
        self.client = client
    }

    func synchronizeSequence(id: String, sequenceNumber: Int) async throws {
        // Upsert document:
        let doc: [String: Any] = [
            "element_id": id,
            "sequence_number": sequenceNumber,
            "element_type": "default" // Ideally this should be passed in or fetched from DB
        ]
        _ = try await client.collections["elements"].documents.upsert(document: doc)
    }

    func synchronizeReorder(_ elements: [ReorderElement]) async throws {
        // Batch upsert:
        let docs = elements.map { [
            "element_id": $0.elementId,
            "sequence_number": $0.newSequence,
            "element_type": "default"
        ] as [String : Any] }
        _ = try await client.collections["elements"].documents.importBatch(documents: docs, action: .upsert)
    }

    func synchronizeVersion(_ elementId: String, versionNumber: Int) async throws {
        // Update document with new version info if needed:
        // Typesense schema can be extended with a version_number field for searching/filtering.
        let doc: [String: Any] = [
            "element_id": elementId,
            "version_number": versionNumber
        ]
        _ = try await client.collections["elements"].documents.upsert(document: doc)
    }
}
```

### **File: `SequenceService.swift`**

```swift
protocol SequenceServiceProtocol {
    func generateSequence(for request: SequenceRequest) async throws -> SequenceResponse
}

final class SequenceService: SequenceServiceProtocol {
    private let databaseService: DatabaseServiceProtocol
    private let typesenseService: TypesenseServiceProtocol

    init(databaseService: DatabaseServiceProtocol, typesenseService: TypesenseServiceProtocol) {
        self.databaseService = databaseService
        self.typesenseService = typesenseService
    }

    func generateSequence(for request: SequenceRequest) async throws -> SequenceResponse {
        let sequenceNumber = Int.random(in: 1...1000)
        try await databaseService.saveSequence(
            elementType: request.elementType,
            elementId: request.elementId,
            sequenceNumber: sequenceNumber,
            comment: request.comment
        )
        try await typesenseService.synchronizeSequence(
            id: request.elementId,
            sequenceNumber: sequenceNumber
        )
        return SequenceResponse(sequenceNumber: sequenceNumber, comment: "Generated successfully")
    }
}
```

### **File: `ReorderService.swift`**

```swift
protocol ReorderServiceProtocol {
    func reorderElements(for request: ReorderRequest) async throws -> ReorderResponse
}

final class ReorderService: ReorderServiceProtocol {
    private let databaseService: DatabaseServiceProtocol
    private let typesenseService: TypesenseServiceProtocol

    init(databaseService: DatabaseServiceProtocol, typesenseService: TypesenseServiceProtocol) {
        self.databaseService = databaseService
        self.typesenseService = typesenseService
    }

    func reorderElements(for request: ReorderRequest) async throws -> ReorderResponse {
        for element in request.elements {
            try await databaseService.updateSequence(elementId: element.elementId, newSequence: element.newSequence)
        }
        try await typesenseService.synchronizeReorder(request.elements)
        return ReorderResponse(comment: "Elements reordered successfully")
    }
}
```

### **File: `VersionService.swift`**

```swift
protocol VersionServiceProtocol {
    func createVersion(for request: VersionRequest) async throws -> VersionResponse
}

final class VersionService: VersionServiceProtocol {
    private let databaseService: DatabaseServiceProtocol
    private let typesenseService: TypesenseServiceProtocol

    init(databaseService: DatabaseServiceProtocol, typesenseService: TypesenseServiceProtocol) {
        self.databaseService = databaseService
        self.typesenseService = typesenseService
    }

    func createVersion(for request: VersionRequest) async throws -> VersionResponse {
        let versionNumber = try await databaseService.createVersion(
            elementId: request.elementId,
            versionData: request.newVersionData,
            comment: request.comment
        )
        try await typesenseService.synchronizeVersion(request.elementId, versionNumber: versionNumber)
        return VersionResponse(versionNumber: versionNumber, comment: "Version created successfully")
    }
}
```

---

## **8. Middleware**

**File: `ErrorMiddleware.swift`**

```swift
import Vapor

final class ErrorMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) async throws -> Response {
        do {
            return try await next.respond(to: request)
        } catch {
            let errorResponse = ErrorResponse(message: "Something went wrong: \(error.localizedDescription)")
            let response = Response(status: .internalServerError)
            try response.content.encode(errorResponse)
            return response
        }
    }
}
```

---

## **9. Testing**

You should write unit and integration tests to ensure reliability.

**File: `ServiceTests.swift`** (example):

```swift
import XCTest
@testable import CentralSequenceService

final class ServiceTests: XCTestCase {
    func testSequenceGeneration() async throws {
        let mockDB = MockDatabaseService()
        let mockTS = MockTypesenseService()
        let service = SequenceService(databaseService: mockDB, typesenseService: mockTS)
        
        let req = SequenceRequest(elementType: "task", elementId: "element-123", comment: "test comment")
        let response = try await service.generateSequence(for: req)
        
        XCTAssertNotNil(response.sequenceNumber)
        XCTAssertEqual(response.comment, "Generated successfully")
    }
}
```

**File: `IntegrationTests.swift`** might simulate full HTTP requests against your Vapor app instance.

**File: `MiddlewareTests.swift`** could test error responses.

---

## **10. Running and Deployment**

- **Run locally:**
  ```bash
  swift run
  ```
  The service should be accessible at `http://localhost:8080/api/sequence/generate` and so forth.

- **Configuration:**
  - Use environment variables or configuration files to store database paths or Typesense keys.
  - For production, consider a more robust database (e.g., Postgres) and secure Typesense access.

- **Dockerization:**
  - Create a `Dockerfile` and run in a container if needed.
  - Ensure `db.sqlite` is on a persistent volume.

- **Logging and Monitoring:**
  - Use Vapor’s built-in logger.
  - Integrate health checks and metrics endpoints as needed.

---

## **11. Best Practices and Next Steps**

- **Security:** Add authentication and authorization if required.
- **Validation:** Validate inputs in controllers before sending to services.
- **Scalability:** Move to a more scalable DB if necessary.
- **Observability:** Add structured logs, tracing, and metrics.

---

## **Conclusion**

This comprehensive guide outlines every layer of the Central Sequence Service. You have:

- A structured Swift package with Vapor for HTTP.
- SQLite integration and migrations for persistent data.
- Typesense for indexing and fast retrieval.
- Clean separation of concerns with Controllers, Services, and Models.
- Middleware for error handling.
- Testing scaffolding for unit and integration tests.

Following this guide, you should be able to set up, run, test, and extend the Central Sequence Service according to your needs.
