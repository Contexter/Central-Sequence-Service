# Central Sequence Service Implementation Guide

This guide will show you how to implement the **Central Sequence Service**, an API designed to manage sequence numbers for story elements. We will cover:

- **Project Setup & Structure**
- **OpenAPI Integration**
- **Database (SQLite) Management**
- **Typesense Integration**
- **Core Service Logic & Endpoints**
- **Error Handling & Retry Mechanisms**
- **Testing & Validation**
- **CI/CD & Deployment Considerations**

The final service will be a Swift-based server using Vapor, leveraging SQLite for storage and Typesense for search indexing. It will comply with the OpenAPI specification provided, ensuring interoperability, discoverability, and clear documentation of your API.

---

## **1. Prerequisites**

Before beginning, ensure you have the following:

- **Swift 5.8+:**  
  Install or upgrade from [swift.org](https://www.swift.org/download/).
  
- **Vapor CLI (optional):**  
  ```bash
  brew tap vapor/homebrew-tap
  brew install vapor
  ```
  
- **SQLite:**  
  SQLite is typically bundled with macOS and Linux distributions. If needed, see [SQLite Installation Instructions](https://www.sqlite.org/download.html).

- **Typesense:**  
  Run a local Typesense instance using Docker:  
  ```bash
  docker run -d -p 8108:8108 -v/tmp/typesense-data:/data typesense/typesense:0.24.0 \
    --data-dir /data --api-key=YOUR_API_KEY
  ```
  Replace `YOUR_API_KEY` with a secure key you choose.

- **Git:**  
  For version control, if desired.

- **cURL or HTTP Client:**  
  To test your API endpoints.

---

## **2. Project Setup**

### **Initialize the Swift Package**

1. Create and navigate into your project directory:
   ```bash
   mkdir CentralSequenceService
   cd CentralSequenceService
   ```

2. Initialize a Swift executable package:
   ```bash
   swift package init --type executable
   ```

Your structure now looks like this:
```
CentralSequenceService/
  ├─ Package.swift
  ├─ Sources/
  │   └─ CentralSequenceService/
  │       └─ main.swift
  └─ Tests/
```

3. For clarity, we’ll separate the run target from the service logic:
   ```bash
   mkdir -p Sources/CentralSequenceService Sources/Run
   mv Sources/CentralSequenceService/main.swift Sources/Run/main.swift
   ```

After this, your structure might be:
```
CentralSequenceService/
  ├─ Package.swift
  ├─ Sources/
  │   ├─ CentralSequenceService/
  │   └─ Run/
  │       └─ main.swift
  └─ Tests/
```

---

## **3. Dependencies**

We will use the following dependencies:

- **Vapor:** For server and routing.
- **Swift OpenAPI Generator:** To generate OpenAPI-compliant code from our spec.
- **SQLite.swift:** For SQLite database interaction.
- **Typesense Swift:** For indexing and searching sequence data.
- **swift-openapi-vapor:** Integration layer for OpenAPI and Vapor.

### **Edit `Package.swift`**

Open `Package.swift` and add the dependencies:

```swift
// swift-tools-version:5.8
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
        ),
        .testTarget(
            name: "CentralSequenceServiceTests",
            dependencies: ["CentralSequenceService", "XCTVapor"]
        )
    ]
)
```

### **Fetch & Resolve Dependencies**

```bash
swift package update
```

---

## **4. OpenAPI Integration**

Save the provided OpenAPI specification into the project root:

**`central-sequence-service.yaml`**

*(The specification was provided in the initial request. Ensure it matches exactly the file in your project.)*

### **Configure the Generator**

Create a `openapi-generator.json` config file to instruct the plugin:

```json
{
  "input": "./central-sequence-service.yaml",
  "output": "./Sources/CentralSequenceService/Generated"
}
```

### **Generate the OpenAPI Code**

Run:

```bash
swift package plugin generate-openapi
```

This command uses the Swift OpenAPI Generator plugin to:
- Parse the YAML file.
- Generate corresponding Swift types, request and response models, and handler protocol stubs into `Sources/CentralSequenceService/Generated`.

---

## **5. Database Integration (SQLite)**

We will use SQLite to persist and retrieve sequence numbers for each element. A simple schema includes a `sequences` table with columns: `id` (a string concatenation of elementType and elementId), and `sequenceNumber` (an integer).

### **Implementing `DatabaseManager`**

Create a file: `Sources/CentralSequenceService/DatabaseManager.swift`

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

    /// Increments the sequence number for a given element or initializes it if it doesn’t exist.
    func incrementSequence(for uniqueID: String) -> Int {
        let sequences = Table("sequences")
        let sequenceNumber = Expression<Int>("sequenceNumber")
        let rowID = Expression<String>("id")

        if let current = try? db.pluck(sequences.filter(rowID == uniqueID)) {
            let newSequence = current[sequenceNumber] + 1
            try! db.run(sequences.filter(rowID == uniqueID).update(sequenceNumber <- newSequence))
            return newSequence
        } else {
            try! db.run(sequences.insert(rowID <- uniqueID, sequenceNumber <- 1))
            return 1
        }
    }

    /// Reorder sequences in batch.
    func reorderSequences(_ updates: [(String, Int)]) {
        let sequences = Table("sequences")
        let sequenceNumber = Expression<Int>("sequenceNumber")
        let rowID = Expression<String>("id")

        for (idValue, newSeq) in updates {
            try! db.run(sequences.filter(rowID == idValue).update(sequenceNumber <- newSeq))
        }
    }

    /// Insert a new version or update existing one (if needed).
    func setSequence(for uniqueID: String, to sequence: Int) {
        let sequences = Table("sequences")
        let sequenceNumber = Expression<Int>("sequenceNumber")
        let rowID = Expression<String>("id")

        if let _ = try? db.pluck(sequences.filter(rowID == uniqueID)) {
            try! db.run(sequences.filter(rowID == uniqueID).update(sequenceNumber <- sequence))
        } else {
            try! db.run(sequences.insert(rowID <- uniqueID, sequenceNumber <- sequence))
        }
    }
}
```

---

## **6. Typesense Integration**

Typesense indexes the sequences for quick search and retrieval. We will create or upsert documents whenever we update a sequence number.

### **Implementing `TypesenseManager`**

Create `Sources/CentralSequenceService/TypesenseManager.swift`:

```swift
import Typesense

class TypesenseManager {
    static let shared = TypesenseManager()

    private let client: Client

    private init() {
        let configuration = Configuration(
            nodes: [ Node(host: "localhost", port: "8108", protocol: "http") ],
            apiKey: "YOUR_API_KEY" // Replace with your Typesense API key.
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

        // Create or ensure existing collection.
        do {
            let collections = try client.collections.retrieve()
            if !collections.contains(where: { $0.name == "sequences" }) {
                _ = try client.collections.create(schema: schema)
            }
        } catch {
            print("Collection setup failed: \(error)")
        }
    }

    func indexSequence(elementType: String, elementId: Int, sequenceNumber: Int) throws {
        let document: [String: Any] = [
            "elementType": elementType,
            "elementId": elementId,
            "sequenceNumber": sequenceNumber
        ]
        try client.documents(collectionName: "sequences").upsert(document: document)
    }
}
```

---

## **7. Core Service Logic**

We’ll implement the API protocol defined by the generated OpenAPI interfaces. The OpenAPI generator created a protocol `APIProtocol` with stubs matching our endpoints. We will implement these in a `Service.swift` file.

Create `Sources/CentralSequenceService/Service.swift`:

```swift
import Vapor
import OpenAPIRuntime
import OpenAPIVapor
import Generated

struct CentralSequenceService: APIProtocol {
    func generateSequenceNumber(
        input: SequenceRequest,
        context: OpenAPIRuntime.ServerRequestContext
    ) async throws -> SequenceResponse {
        let uniqueID = "\(input.elementType)-\(input.elementId)"
        let newSequence = DatabaseManager.shared.incrementSequence(for: uniqueID)

        // Synchronize with Typesense (with simple retry)
        do {
            try TypesenseManager.shared.indexSequence(
                elementType: input.elementType,
                elementId: input.elementId,
                sequenceNumber: newSequence
            )
        } catch {
            // Retry logic can be more robust; for brevity just retry once
            print("Failed to index with Typesense, retrying...")
            do {
                try TypesenseManager.shared.indexSequence(
                    elementType: input.elementType,
                    elementId: input.elementId,
                    sequenceNumber: newSequence
                )
            } catch {
                // If still fails, throw an appropriate error
                throw ServerError(.badGateway, message: "Failed to synchronize with Typesense.")
            }
        }

        return SequenceResponse(sequenceNumber: newSequence, comment: "Sequence generated successfully.")
    }

    func reorderElements(
        input: ReorderRequest,
        context: OpenAPIRuntime.ServerRequestContext
    ) async throws -> ReorderResponse {
        // Prepare updates
        let updates: [(String, Int)] = input.elements.map { elem in
            ("\(input.elementType)-\(elem.elementId)", elem.newSequence)
        }

        // Update SQLite
        DatabaseManager.shared.reorderSequences(updates)

        // Synchronize with Typesense
        // If any fails, we retry or handle errors accordingly
        for (idValue, newSeq) in updates {
            let parts = idValue.split(separator: "-")
            guard parts.count == 2,
                  let elementId = Int(parts[1])
            else {
                continue
            }

            do {
                try TypesenseManager.shared.indexSequence(
                    elementType: String(parts[0]),
                    elementId: elementId,
                    sequenceNumber: newSeq
                )
            } catch {
                // Retry logic or handle errors here
                throw ServerError(.badGateway, message: "Failed to synchronize with Typesense.")
            }
        }

        let updatedElements = input.elements.map { ReorderResponse.UpdatedElements(elementId: $0.elementId, newSequence: $0.newSequence) }
        return ReorderResponse(updatedElements: updatedElements, comment: "Elements reordered successfully.")
    }

    func createVersion(
        input: VersionRequest,
        context: OpenAPIRuntime.ServerRequestContext
    ) async throws -> VersionResponse {
        // For simplicity, we’ll treat "versioning" as incrementing a sequence number or setting it to a specific value.
        // In a real application, you'd store version info and other metadata as well.
        
        let uniqueID = "\(input.elementType)-\(input.elementId)"

        // Suppose every version increment just bumps the existing sequence by 1
        let newSequence = DatabaseManager.shared.incrementSequence(for: uniqueID)

        // Synchronize with Typesense
        do {
            try TypesenseManager.shared.indexSequence(
                elementType: input.elementType,
                elementId: input.elementId,
                sequenceNumber: newSequence
            )
        } catch {
            // Retry logic or error handling
            throw ServerError(.badGateway, message: "Failed to synchronize with Typesense.")
        }

        return VersionResponse(versionNumber: newSequence, comment: "New version created successfully.")
    }
}
```

**Note:** The above code uses a simplistic versioning approach. You could store actual version data in separate tables and track them more rigorously depending on your application’s needs.

---

## **8. Vapor Configuration**

Edit `Sources/Run/main.swift` to boot the Vapor app and register our API:

```swift
import Vapor
import OpenAPIVapor
import CentralSequenceService

@main
struct CentralSequenceServiceMain {
    static func main() throws {
        let app = Application()
        defer { app.shutdown() }

        // Register OpenAPI-defined API implementations
        try app.registerAPI(CentralSequenceService())

        // Optionally, serve OpenAPI spec at a route:
        // app.get("openapi.json") { req -> Response in
        //     let jsonData = try Data(contentsOf: URL(fileURLWithPath: "central-sequence-service.yaml"))
        //     return Response(body: Response.Body(data: jsonData))
        // }

        try app.run()
    }
}
```

---

## **9. Error Handling and Retry Mechanisms**

In a production environment, you’ll need more robust error handling and retry logic:

- **Retry Policies:**  
  Implement exponential backoff for Typesense indexing failures.
- **Custom Errors:**  
  Throw `ServerError` or custom errors, and convert them to OpenAPI-defined error responses.

You can wrap Typesense indexing in a small function that retries a few times before giving up:

```swift
func safeIndexSequence(elementType: String, elementId: Int, sequenceNumber: Int, attempts: Int = 3) throws {
    var remaining = attempts
    while remaining > 0 {
        do {
            try TypesenseManager.shared.indexSequence(
                elementType: elementType,
                elementId: elementId,
                sequenceNumber: sequenceNumber
            )
            return
        } catch {
            remaining -= 1
            if remaining == 0 {
                throw ServerError(.badGateway, message: "Failed to synchronize with Typesense after multiple attempts.")
            }
        }
    }
}
```

Integrate this helper into your main service methods as needed.

---

## **10. Testing & Validation**

### **Unit Tests**

Create tests under `Tests/CentralSequenceServiceTests`. For example, `SequenceTests.swift`:

```swift
import XCTVapor
@testable import CentralSequenceService

final class SequenceTests: XCTestCase {
    func testGenerateSequenceNumber() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try app.registerAPI(CentralSequenceService())

        let reqBody = """
        {
          "elementType": "script",
          "elementId": 1,
          "comment": "Creating a sequence."
        }
        """

        try app.test(.POST, "/sequence", beforeRequest: { req in
            try req.content.encode(json: reqBody)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .created)
        })
    }
}
```

Run tests:
```bash
swift test
```

### **Integration Tests**

You can also run integration tests against a running instance of the service and a running Typesense instance.

### **OpenAPI Validation**

Use tools like [Speccy](https://github.com/wework/speccy) or [Redocly CLI](https://redocly.com/docs/cli/) to validate your `central-sequence-service.yaml`.

---

## **11. Continuous Integration & Deployment**

- **CI Tools:**  
  Use GitHub Actions or GitLab CI to run `swift test` on every commit.

- **Linting & Style Checks:**  
  Integrate [SwiftLint](https://github.com/realm/SwiftLint) to maintain code quality.

- **Containerization:**  
  Create a `Dockerfile` for deployment:
  ```dockerfile
  FROM swift:5.8-focal as builder
  WORKDIR /app
  COPY . .
  RUN swift build -c release --disable-sandbox

  FROM ubuntu:20.04
  WORKDIR /app
  COPY --from=builder /app/.build/release/Run .
  EXPOSE 8080
  CMD ["./Run"]
  ```

- **Deployment:**  
  Push the image to a registry and run on a cloud platform, ensuring access to your Typesense service.

---

## **12. Production Considerations**

- **Scalability:**  
  For high-load environments, consider using PostgreSQL or another more scalable database. SQLite can be a single-node embedded database suitable for smaller applications.
  
- **Security:**  
  Protect the API endpoints using `X-API-KEY` or OAuth. The OpenAPI spec includes an `apiKeyAuth` header scheme.  
  Validate API keys in a middleware before handling requests.

- **Load Balancing & Caching:**  
  If performance is critical, cache responses or apply a load balancer in front of multiple service instances.

- **Monitoring & Logging:**  
  Use Vapor’s logging and integrate with a monitoring solution like Prometheus or Datadog.

---

## **Conclusion**

This comprehensive guide has walked you through:

1. **Setting up a Swift-based backend with Vapor.**
2. **Defining endpoints via OpenAPI and generating code stubs automatically.**
3. **Implementing persistent storage via SQLite.**
4. **Integrating with Typesense for real-time search indexing.**
5. **Implementing robust error handling, retries, and test coverage.**
6. **Preparing for production deployment with CI/CD, containerization, and security.**

By following these steps, you have a fully operational, extensible, and maintainable Central Sequence Service ready for integration into larger storytelling or content management systems.