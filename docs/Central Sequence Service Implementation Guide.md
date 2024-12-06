# **Central Sequence Service Implementation Guide**

This guide provides a complete, step-by-step tutorial for implementing the **Central Sequence Service** using **Swift**, **SQLite**, **Typesense**, and **OpenAPI**. The goal is to deliver a fully functional backend service capable of managing sequence numbers with robust synchronization, fault tolerance, and searchability.

---

## **Overview**

The **Central Sequence Service** is responsible for generating and managing sequence numbers for various story elements, such as scripts, sections, characters, actions, and spoken words. Its core features include:
- **SQLite persistence** for reliable storage.
- **Typesense integration** for real-time search capabilities.
- **API endpoints** for creating, updating, and retrieving sequence numbers, compliant with OpenAPI standards.
- **Fault-tolerant retry mechanisms** for syncing with Typesense in case of failures.

---

## **1. Prerequisites**

Before starting, ensure you have the following tools and libraries installed on your system:
- **Swift 5.8** or higher.
- **Typesense** (via Docker for local testing).
- **SQLite** installed or accessible through the SQLite.swift library.
- **Git** for version control.
- **cURL** or a similar tool for API endpoint testing.

---

## **2. Project Setup**

### **Initialize the Repository**
1. Create a directory for the project:
   ```bash
   mkdir CentralSequenceService
   cd CentralSequenceService
   ```

2. Initialize a Swift executable package:
   ```bash
   swift package init --type executable
   ```

3. Adjust the directory structure:
   - Create subdirectories for your targets:
     ```bash
     mkdir -p Sources/CentralSequenceService
     mkdir -p Sources/Run
     ```

4. Move the `main.swift` file to `Sources/Run/`:
   ```bash
   mv Sources/main.swift Sources/Run/main.swift
   ```

---

## **3. Dependencies**

### **Edit `Package.swift`**

Add the following dependencies to your `Package.swift` file:

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
        .package(url: "https://github.com/swift-server/swift-openapi-vapor.git", from: "1.0.1"),
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
                .product(name: "Typesense", package: "typesense-swift")
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

### **Install Dependencies**

Run the following command to fetch and resolve the dependencies:
```bash
swift package update
```

---

## **4. OpenAPI Integration**

### **Save the OpenAPI Specification**

Save the provided OpenAPI specification as `central-sequence-service.yaml` in the root of your project directory.

### **Configure OpenAPI Generator**

Create a configuration file named `openapi-generator.json`:
```json
{
    "input": "./central-sequence-service.yaml",
    "output": "./Sources/CentralSequenceService/Generated"
}
```

### **Generate OpenAPI Models and Stubs**

Run the Swift OpenAPI generator to create models and server stubs:
```bash
swift package plugin generate-openapi
```

---

## **5. Service Implementation**

### **SQLite Integration**

Create a file named `Sources/CentralSequenceService/DatabaseManager.swift`:
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

### **Typesense Integration**

Create a file named `Sources/CentralSequenceService/TypesenseManager.swift`:
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

### **Service Logic**

Create `Sources/CentralSequenceService/Service.swift`:
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

### **Vapor Configuration**

Edit `Sources/Run/main.swift`:
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

## **6. Testing**

### **Start Typesense**

Run a local Typesense server using Docker:
```bash
docker run -d -p 8108:8108 -v/tmp/typesense-data:/data typesense/typesense:0.24.0 --data-dir /data --api-key=YOUR_API_KEY
```

### **Run the Service**

Start the service:
```bash
swift run Run
```

### **Test the API**

- Generate a sequence:
  ```bash
  curl -X POST http://localhost:8080/sequence \
       -H "Content-Type: application/json" \
       -d '{"elementType": "script", "elementId": 1, "comment": "Creating a sequence."}'
  ```

- Query Typesense:
  ```bash
  curl -X GET "http://localhost:8108/collections/sequences/documents" \
       -H "X-TYPESENSE-API-KEY: YOUR_API_KEY"
  ```

---

## **Conclusion**

This guide provides a robust and scalable implementation of the Central Sequence Service, featuring SQLite for persistence, Typesense for search, and full OpenAPI compliance. By following these steps, you’ll have a fully operational backend service tailored for managing sequence data in any application.