# **Central Sequence Service: Comprehensive Architecture and Development Plan**

## **Architectural Overview**

The Central Sequence Service application is built on the Vapor framework and adheres to a modular, scalable design inspired by clean architecture principles. This document outlines the project's refactored architecture, detailing its file structure, responsibilities, and integration with OpenAPI-generated code. Additionally, a step-by-step development plan is provided for implementing the application.

---

## **High-Level Architecture**

### **1. Key Components**
- **Controllers**: Handle HTTP-specific logic and map routes to services.
- **Services**: Contain business logic and delegate operations to database or external integrations.
- **Database Layer**: Manages SQLite-based persistence.
- **External Integration**: Handles data synchronization with Typesense.

### **2. Integration with Generated Code**
- **Generated Files**: OpenAPI Generator produces `Server.swift` and `Types.swift`.
  - `Server.swift` defines routes and uses the `APIProtocol`.
  - `Types.swift` contains models for request and response payloads.
- **Custom Implementation**: The `APIProtocol` methods are implemented in `main.swift`, delegating to services.

---

## **Refactored Folder Structure**

```
CentralSequenceService/
├── Sources/
│   ├── CentralSequenceService/
│   │   ├── main.swift                     # App entry point
│   │   ├── Controllers/
│   │   │   ├── SequenceController.swift   # Handle sequence-related endpoints
│   │   ├── Services/
│   │   │   ├── SequenceService.swift      # Core sequence logic
│   │   │   ├── DatabaseService.swift      # SQLite integration
│   │   │   ├── TypesenseService.swift     # Typesense integration
│   │   ├── Models/
│   │   │   ├── DatabaseModels.swift       # Models for database operations
│   │   ├── Config/
│   │   │   ├── DatabaseConfig.swift       # SQLite configuration
│   │   │   ├── TypesenseConfig.swift      # Typesense configuration
│   │   ├── GeneratedSources/
│   │   │   ├── Server.swift               # Generated OpenAPI routes
│   │   │   ├── Types.swift                # Generated OpenAPI models
```

---

## **Development Plan**

### **Phase 1: Setup**

#### **1. Update Package.swift**
- Add dependencies for SQLite and Typesense.

```swift
.package(url: "https://github.com/vapor/sqlite-nio.git", from: "1.0.0"),
.package(url: "https://github.com/typesense/typesense-swift.git", from: "1.0.0"),
```

- Update targets to include these dependencies.

#### **2. Initialize Dependencies**
- Run the following commands to install and test dependencies:
  ```bash
  swift package update
  swift build
  ```

---

### **Phase 2: Define Services**

#### **1. SequenceService**
Handles core business logic, combining database and Typesense functionality.

- **File:** `Services/SequenceService.swift`
```swift
protocol SequenceServiceProtocol {
    func generateSequenceNumber(for request: Components.Schemas.SequenceRequest) async throws -> Components.Schemas.SequenceResponse
}

final class SequenceService: SequenceServiceProtocol {
    let databaseService: DatabaseServiceProtocol
    let typesenseService: TypesenseServiceProtocol

    init(databaseService: DatabaseServiceProtocol, typesenseService: TypesenseServiceProtocol) {
        self.databaseService = databaseService
        self.typesenseService = typesenseService
    }

    func generateSequenceNumber(for request: Components.Schemas.SequenceRequest) async throws -> Components.Schemas.SequenceResponse {
        let sequenceNumber = Int.random(in: 1...1000)
        try await databaseService.saveSequenceNumber(
            elementType: request.elementType.rawValue,
            elementId: request.elementId,
            sequenceNumber: sequenceNumber,
            comment: request.comment
        )
        try await typesenseService.synchronizeSequence(request.elementId, sequenceNumber: sequenceNumber)
        return Components.Schemas.SequenceResponse(sequenceNumber: sequenceNumber, comment: "Generated successfully")
    }
}
```

---

#### **2. DatabaseService**
Handles SQLite-based persistence.

- **File:** `Services/DatabaseService.swift`
```swift
protocol DatabaseServiceProtocol {
    func saveSequenceNumber(elementType: String, elementId: Int, sequenceNumber: Int, comment: String) async throws
}

final class DatabaseService: DatabaseServiceProtocol {
    private let db: SQLiteConnection

    init(database: SQLiteConnection) {
        self.db = database
    }

    func saveSequenceNumber(elementType: String, elementId: Int, sequenceNumber: Int, comment: String) async throws {
        let query = """
        INSERT INTO sequences (element_type, element_id, sequence_number, comment)
        VALUES (?, ?, ?, ?)
        """
        try await db.query(query, [elementType, elementId, sequenceNumber, comment])
    }
}
```

---

#### **3. TypesenseService**
Handles data synchronization with Typesense.

- **File:** `Services/TypesenseService.swift`
```swift
protocol TypesenseServiceProtocol {
    func synchronizeSequence(_ elementId: Int, sequenceNumber: Int) async throws
}

final class TypesenseService: TypesenseServiceProtocol {
    private let client: Client

    init(client: Client) {
        self.client = client
    }

    func synchronizeSequence(_ elementId: Int, sequenceNumber: Int) async throws {
        let document = ["id": "\(elementId)", "sequenceNumber": sequenceNumber]
        try await client.collections["sequences"].documents.create(document: document)
    }
}
```

---

### **Phase 3: Implement Controllers**

#### **1. SequenceController**
Handles HTTP routes for sequences.

- **File:** `Controllers/SequenceController.swift`
```swift
import Vapor

struct SequenceController: RouteCollection {
    let sequenceService: SequenceServiceProtocol

    func boot(routes: RoutesBuilder) throws {
        let sequenceRoutes = routes.grouped("sequence")
        sequenceRoutes.post(use: generateSequenceNumber)
    }

    func generateSequenceNumber(req: Request) async throws -> SequenceResponse {
        let requestBody = try req.content.decode(SequenceRequest.self)
        return try await sequenceService.generateSequenceNumber(for: requestBody)
    }
}
```

---

### **Phase 4: Connect the Pieces in `main.swift`**

- **File:** `main.swift`

```swift
import Vapor
import SQLiteNIO
import Typesense

let app = Application()

// Configure SQLite
let sqliteSource = SQLiteConnectionSource(
    configuration: .init(storage: .file(path: "database.sqlite"))
)
let database = try sqliteSource.makeConnection(logger: app.logger).wait()

// Configure Typesense
let typesenseClient = Client(
    configuration: Configuration(
        nodes: [Node(host: "localhost", port: 8108, protocol: "http")],
        apiKey: "your_api_key"
    )
)

// Initialize services
let databaseService = DatabaseService(database: database)
let typesenseService = TypesenseService(client: typesenseClient)
let sequenceService = SequenceService(
    databaseService: databaseService,
    typesenseService: typesenseService
)

// Implement APIProtocol
let apiImplementation = APIImplementation(sequenceService: sequenceService)

// Register routes
try apiImplementation.registerHandlers(on: app)

// Run the app
try app.run()
```

---

### **Phase 5: Testing**

#### **1. Build the App**
```bash
swift build
```

#### **2. Run the App**
```bash
swift run
```

#### **3. Test API Endpoints**
- Use tools like Postman or `curl` to test endpoints.

Example:
```bash
curl -X POST http://localhost:8080/sequence \
-H "Content-Type: application/json" \
-d '{
    "elementType": "script",
    "elementId": 123,
    "comment": "Test generation"
}'
```

---

### **Conclusion**

This architecture integrates OpenAPI-generated code with a modular, maintainable structure. Each component has clear responsibilities, making the app scalable and testable.


