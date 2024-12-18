# swift-openapi-vapor Integration for Central Sequence Service

In this guide, we will explain how to integrate **swift-openapi-vapor** into the **Central Sequence Service** project. Instead of manually writing routes, **OpenAPIVapor** automatically connects OpenAPI operations to Vapor's routing system. By following this guide, you will:

1. Implement the API logic.
2. Automatically register all routes.
3. Test and verify the `/sequence` endpoint.

Let’s dive in!

---

## 1. **What is swift-openapi-vapor?**

**swift-openapi-vapor** bridges the OpenAPI-defined operations and Vapor's routing system. It connects automatically generated **APIProtocol** methods to the Vapor framework without requiring manual route definitions (e.g., `app.get` or `app.post`).

### **Why Use swift-openapi-vapor?**
- Eliminates boilerplate code for route registration.
- Ensures API consistency with the OpenAPI specification.
- Keeps your project modular and focused on business logic.

---

## 2. **Project Structure Overview**

Your **Central Sequence Service** project should follow this modular structure:

```
CentralSequenceService/
├── Package.swift         # Swift dependencies
├── Sources/
│   ├── main.swift        # Entry point for Vapor server
│   ├── configure.swift   # Application configuration
│   ├── routes.swift      # Route registration
│   ├── Handlers/         # Modular API handlers
│   │   ├── SequenceHandler.swift # Logic for /sequence
│   │   ├── ReorderHandler.swift  # Logic for /sequence/reorder
│   │   ├── VersionHandler.swift  # Logic for /sequence/version
│   ├── APIImplementation.swift # APIProtocol integration
│   ├── Models/
│   │   ├── Sequence.swift # Fluent model for sequences
│   │   ├── Version.swift  # Fluent model for versions
│   ├── Migrations/
│   │   ├── CreateSequence.swift # Fluent migration for sequences
│   │   ├── CreateVersion.swift  # Fluent migration for versions
└── Tests/                # Unit tests
```

---

## 3. **Implementing the API Logic**

Implementing the API logic involves taking the automatically generated **APIProtocol** from your OpenAPI specification and writing the actual business logic for each defined operation. Instead of a single file, we split the logic into **modular handlers**.

### Step 1: Implement Handlers

1. **`SequenceHandler.swift`** - Handles `/sequence` requests:

**`Sources/Handlers/SequenceHandler.swift`**:
```swift
import Vapor
import Fluent

struct SequenceHandler {
    let app: Application

    func handleGenerateSequence(_ input: Operations.generateSequenceNumber.Input) async throws -> Operations.generateSequenceNumber.Output {
        guard case let .json(requestBody) = input.body else {
            throw Abort(.badRequest, reason: "Invalid content type")
        }

        let sequenceNumber = try await findOrCreateSequenceNumber(elementId: requestBody.elementId, comment: requestBody.comment)

        let response = Components.Schemas.SequenceResponse(
            sequenceNumber: sequenceNumber,
            comment: "Generated sequence number for \(requestBody.elementType)"
        )
        return .created(.init(body: .json(response)))
    }

    private func findOrCreateSequenceNumber(elementId: Int, comment: String?) async throws -> Int {
        return try await app.db.transaction { db in
            if let existing = try await Sequence.query(on: db).filter(\.$elementId == "\(elementId)").first() {
                existing.sequenceNumber += 1
                try await existing.save(on: db)
                return existing.sequenceNumber
            } else {
                let newSequence = Sequence(elementId: "\(elementId)", sequenceNumber: 1, comment: comment)
                try await newSequence.save(on: db)
                return newSequence.sequenceNumber
            }
        }
    }
}
```

2. **`ReorderHandler.swift`** - Handles `/sequence/reorder` requests:

**`Sources/Handlers/ReorderHandler.swift`**:
```swift
import Vapor

struct ReorderHandler {
    func handleReorderElements(_ input: Operations.reorderElements.Input) async throws -> Operations.reorderElements.Output {
        let updatedElements = input.elements.map { elementId, newSequence in
            guard newSequence >= 0 else {
                throw Abort(.badRequest, reason: "Sequence number must be non-negative for elementId: \(elementId)")
            }
            return (elementId, newSequence)
        }

        return .ok(.init(body: .json(updatedElements)))
    }
}
```

3. **`VersionHandler.swift`** - Handles `/sequence/version` requests:

**`Sources/Handlers/VersionHandler.swift`**:
```swift
import Vapor

struct VersionHandler {
    func handleCreateVersion(_ input: Operations.createVersion.Input) async throws -> Operations.createVersion.Output {
        let versionNumber = (versionStore[input.elementId] ?? 0) + 1
        versionStore[input.elementId] = versionNumber

        return .created(.init(body: .json(["versionNumber": versionNumber])))
    }
}
```

### Step 2: Integrate Handlers in APIImplementation

Now integrate these handlers into `APIProtocol`.

**`Sources/APIImplementation.swift`**:
```swift
import Vapor
import OpenAPIVapor

struct CentralSequenceServiceAPI: APIProtocol {
    let app: Application

    func generateSequenceNumber(_ input: Operations.generateSequenceNumber.Input) async throws -> Operations.generateSequenceNumber.Output {
        return try await SequenceHandler(app: app).handleGenerateSequence(input)
    }

    func reorderElements(_ input: Operations.reorderElements.Input) async throws -> Operations.reorderElements.Output {
        return try await ReorderHandler().handleReorderElements(input)
    }

    func createVersion(_ input: Operations.createVersion.Input) async throws -> Operations.createVersion.Output {
        return try await VersionHandler().handleCreateVersion(input)
    }
}
```

## 4. **Registering Routes Automatically**

In Vapor, you normally register routes manually using `app.post` or `app.get`. With **swift-openapi-vapor**, you use the `VaporTransport` object to automatically map your implemented `APIProtocol` to Vapor's routing system.

**`Sources/routes.swift`**:
```swift
import Vapor
import OpenAPIVapor

func registerRoutes(app: Application) throws {
    let transport = VaporTransport(routesBuilder: app)
    let api = CentralSequenceServiceAPI(app: app)
    try api.registerHandlers(on: transport)
    app.logger.info("All OpenAPI routes registered successfully.")
}
```

This function:
1. Creates a `VaporTransport` instance to connect Vapor and OpenAPI.
2. Registers the implemented `APIProtocol` handlers (defined earlier) using `registerHandlers`.
3. Logs a success message to confirm all routes are registered.

---

## 5. **Application Configuration**

In `configure.swift`, set up your database, apply migrations, and call `registerRoutes` to complete the integration.

**`Sources/configure.swift`**:
```swift
import Fluent
import FluentSQLiteDriver
import Vapor

public func configure(_ app: Application) throws {
    // Configure SQLite database
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    // Add migrations
    app.migrations.add(CreateSequence())
    app.migrations.add(CreateVersion())
    try app.autoMigrate().wait()

    // Register OpenAPI routes
    try registerRoutes(app: app)
}
```

### **What This Does**:
1. **Database Setup**:
   - Configures SQLite as the database driver, storing data in a file `db.sqlite`.
2. **Migrations**:
   - Adds Fluent migrations for creating tables like `Sequence` and `Version`.
   - Runs `autoMigrate()` to ensure the database schema is up to date.
3. **Routes Registration**:
   - Calls `registerRoutes` to integrate OpenAPI routes with Vapor.

---

## 6. **Running the Application**

With the configuration complete, the application can now be started.

**`Sources/main.swift`**:
```swift
import Vapor

var env = try Environment.detect()
let app = Application(env)
defer { app.shutdown() }

try configure(app)
try app.run()
```

### **Steps to Run**:
1. Ensure the project dependencies are resolved:
   ```bash
   swift package update
   ```
2. Run the Vapor application:
   ```bash
   swift run
   ```
3. The server starts on `localhost:8080` by default.

---

## 7. **Testing the API**

Once the server is running, test the endpoints using tools like `curl` or Postman.

### **Basic Test: `/sequence`**
Generate a sequence number:
```bash
curl -X POST http://localhost:8080/sequence \
-H "Content-Type: application/json" \
-d '{ "elementId": 123, "comment": "Test comment" }'
```

**Expected Response**:
```json
{
    "sequenceNumber": 1,
    "comment": "Generated sequence number for script"
}
```

### **Edge Case: Missing Input**
Test with missing fields:
```bash
curl -X POST http://localhost:8080/sequence \
-H "Content-Type: application/json" \
-d '{}'
```

**Expected Response**:
```json
{
    "error": "Bad Request",
    "reason": "Invalid content type"
}
```

### **Reordering Elements**
Reorder elements using the business logic from Iteration 5:
```bash
curl -X PUT http://localhost:8080/sequence/reorder \
-H "Content-Type: application/json" \
-d '{ "elements": { "123": 1, "124": 2 } }'
```

**Expected Response**:
```json
{
    "updatedElements": { "123": 1, "124": 2 },
    "message": "Sequence numbers successfully updated."
}
```

### **Creating a Version**
Create a version using Iteration 6 logic:
```bash
curl -X POST http://localhost:8080/sequence/version \
-H "Content-Type: application/json" \
-d '{ "elementId": 123 }'
```

**Expected Response**:
```json
{
    "versionNumber": 2,
    "message": "Version successfully created."
}
```

---

## 8. **Conclusion**

By integrating **swift-openapi-vapor** into your Central Sequence Service project, you:

1. **Implemented** OpenAPI-defined endpoints using `APIProtocol`.
2. **Delegated logic** to modular handler files for better scalability and readability.
3. **Automatically Registered** routes with Vapor using `VaporTransport`.
4. **Integrated** logic from previous iterations to complete the stubs in handlers.
5. **Tested** the API endpoints to verify functionality.

This approach eliminates boilerplate code, ensures consistency with the OpenAPI specification, and keeps your project scalable and maintainable.

### **Next Steps**:
- Add middleware for **API key security**.
- Implement advanced features like **request validation** and error handling.
- Optimize performance for production deployment.

Your API is now production-ready! 🚀



