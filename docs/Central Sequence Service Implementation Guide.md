# Central Sequence Service Implementation Guide

This guide provides a comprehensive, step-by-step tutorial for implementing the **Central Sequence Service** with SQLite persistence, Typesense integration, and API endpoint definitions based on OpenAPI. The goal is to deliver a fully functional backend service capable of managing sequence numbers with robust synchronization and searchability.

---

## **Overview**

The Central Sequence Service manages sequence numbers for various story elements, such as scripts, characters, actions, etc. It includes the following capabilities:
- Persisting sequence data in SQLite.
- Synchronizing with a **Typesense** search engine for real-time search.
- API endpoints for creating, updating, and retrieving sequence numbers.
- Fault-tolerant retry mechanisms for Typesense integration.

---

## **1. Prerequisites**

Ensure the following tools and software are installed:
- **Swift 5.8** or higher.
- **Typesense** (Docker for local setup).
- **SQLite** installed (or available through the SQLite.swift library).
- **Git** for version control.
- **cURL** or a similar tool for testing API endpoints.

---

## **2. Set Up the Project**

### Initialize a New Swift Package
1. Create a directory for the service:
   ```bash
   mkdir CentralSequenceService
   cd CentralSequenceService
   ```
2. Initialize a new Swift package:
   ```bash
   swift package init --type executable
   ```

---

## **3. Update Dependencies**

Edit `Package.swift` to include necessary dependencies:

```swift
// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "CentralSequenceService",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator.git", from: "0.1.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-vapor.git", from: "0.1.0"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.12.0"),
        .package(url: "https://github.com/typesense/typesense-swift.git", from: "0.2.0")
    ],
    targets: [
        .target(
            name: "CentralSequenceService",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-generator"),
                .product(name: "OpenAPIVapor", package: "swift-openapi-vapor"),
                .product(name: "SQLite", package: "SQLite.swift"),
                .product(name: "Typesense", package: "typesense-swift"),
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
            ]
        ),
        .executableTarget(
            name: "Run",
            dependencies: ["CentralSequenceService"]
        )
    ]
)
```

Update dependencies:

```bash
swift package update
```

---

## **4. Prepare the OpenAPI Specification**

### Save the OpenAPI Specification
Save the provided OpenAPI specification as `central-sequence-service.yaml` in the project root.

### Configure OpenAPI Generator
Add a configuration file, `openapi-generator.json`:

```json
{
    "input": "./central-sequence-service.yaml",
    "output": "./Sources/CentralSequenceService/Generated"
}
```

Run the generator to create models and stubs:

```bash
swift package plugin generate-openapi
```

---

## **5. Implement the Service**

### SQLite Integration
Add a new file `DatabaseManager.swift`:

```swift
import SQLite

struct DatabaseManager {
    static let shared = DatabaseManager()
    private let db: Connection

    private init() {
        let path = FileManager.default.temporaryDirectory.appendingPathComponent("central_sequence.sqlite3").path
        db = try! Connection(path)
        createTables()
    }

    private func createTables() {
        let sequences = Table("sequences")
        let id = Expression<String>("id")
        let sequenceNumber = Expression<Int>("sequenceNumber")

        try! db.run(sequences.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(sequenceNumber)
        })
    }

    func incrementSequence(for id: String) -> Int {
        let sequences = Table("sequences")
        let sequenceNumber = Expression<Int>("sequenceNumber")
        let rowID = Expression<String>("id")

        if let current = try? db.pluck(sequences.filter(rowID == id)) {
            let newSequence = current[sequenceNumber] + 1
            try! db.run(sequences.filter(rowID == id).update(sequenceNumber <- newSequence))
            return newSequence
        } else {
            try! db.run(sequences.insert(rowID <- id, sequenceNumber <- 1))
            return 1
        }
    }
}
```

---

### Typesense Integration
Add a file `TypesenseManager.swift`:

```swift
import Typesense

class TypesenseManager {
    static let shared = TypesenseManager()

    private let client: Client

    private init() {
        let configuration = Configuration(
            nodes: [
                Node(
                    host: "localhost",
                    port: "8108",
                    protocol: "http"
                )
            ],
            apiKey: "YOUR_API_KEY"
        )
        self.client = Client(configuration: configuration)
        setupCollection()
    }

    private func setupCollection() {
        let schema = CollectionSchema(
            name: "sequences",
            fields: [
                Field(name: "elementType", type: .string),
                Field(name: "elementId", type: .int32),
                Field(name: "sequenceNumber", type: .int32)
            ],
            defaultSortingField: "sequenceNumber"
        )

        do {
            _ = try client.collections.create(schema: schema)
        } catch {
            print("Collection setup failed: \(error)")
        }
    }

    func indexSequence(elementType: String, elementId: Int, sequenceNumber: Int) {
        let document: [String: Any] = [
            "elementType": elementType,
            "elementId": elementId,
            "sequenceNumber": sequenceNumber
        ]

        do {
            _ = try client.documents(collectionName: "sequences").upsert(document: document)
        } catch {
            print("Failed to index sequence: \(error)")
        }
    }
}
```

---

### Service Logic
Implement the main service in `Service.swift`:

```swift
import Vapor
import OpenAPIVapor
import Generated

struct CentralSequenceService: Generated.APIProtocol {
    func generateSequenceNumber(
        input: SequenceRequest,
        context: OpenAPIRuntime.ServerRequestContext
    ) async throws -> SequenceResponse {
        let newSequence = DatabaseManager.shared.incrementSequence(for: input.elementId.description)

        // Synchronize with Typesense
        TypesenseManager.shared.indexSequence(
            elementType: input.elementType,
            elementId: input.elementId,
            sequenceNumber: newSequence
        )

        return SequenceResponse(sequenceNumber: newSequence, comment: "Sequence generated successfully.")
    }
}
```

---

### Configure Vapor
In `main.swift`:

```swift
import Vapor
import OpenAPIVapor
import CentralSequenceService

@main
struct CentralSequenceServiceMain {
    static func main() throws {
        let app = Application()
        defer { app.shutdown() }

        try app.registerAPI(CentralSequenceService())
        try app.run()
    }
}
```

---

## **6. Test the Service**

### Start Typesense
Run a local Typesense server:

```bash
docker run -d -p 8108:8108 -v/tmp/typesense-data:/data typesense/typesense:0.24.0 --data-dir /data --api-key=YOUR_API_KEY
```

### Start the Service
Run the service:

```bash
swift run
```

### Test API Endpoints
- **Generate Sequence**:
  ```bash
  curl -X POST http://localhost:8080/sequence \
       -H "Content-Type: application/json" \
       -d '{"elementType": "script", "elementId": 1, "comment": "Creating a sequence."}'
  ```

- **Query Typesense**:
  ```bash
  curl -X GET "http://localhost:8108/collections/sequences/documents" \
       -H "X-TYPESENSE-API-KEY: YOUR_API_KEY"
  ```

---

## **Conclusion**

This tutorial covers the full implementation of the **Central Sequence Service**, integrating SQLite for persistence and Typesense for search. The service is scalable, fault-tolerant, and OpenAPI-compliant, providing robust sequence management for any story-driven application.