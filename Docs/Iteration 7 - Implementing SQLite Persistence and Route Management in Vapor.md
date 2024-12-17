# Iteration 7 - Implementing SQLite Persistence and Route Management in Vapor

In this tutorial, you will set up a SQLite-backed persistence layer in a Vapor-based Swift project using Fluent. You will also implement route management in a clean, modular way to keep the application organized. By the end of this guide, the server will remain running for continuous testing.

## **1. Project Structure**
We organize the project to maintain a clear separation of responsibilities for configuration, route registration, migrations, and models. Here's the resulting structure:

```
CentralSequenceService/
├── Package.swift
├── Sources/
│   ├── main.swift
│   ├── configure.swift
│   ├── routes.swift
│   ├── Iterations/
│   │   ├── iteration_7.swift
│   ├── Migrations/
│   │   ├── CreateSequence.swift
│   │   ├── CreateVersion.swift
│   ├── Models/
│   │   ├── Sequence.swift
│   │   ├── Version.swift
└── Tests/
```

This layout ensures:

- **Models**: Define database entities.
- **Migrations**: Create and manage database schema.
- **Iterations**: Define specific iteration logic and routes.
- **routes.swift**: Centralize route registration for better maintainability.

---

## **2. Package Dependencies**
Your `Package.swift` already includes the required dependencies for Vapor, Fluent, and SQLite:

**`Package.swift`**:

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CentralSequenceService",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.3.0")
    ],
    targets: [
        .executableTarget(
            name: "CentralSequenceService",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver")
            ]
        )
    ]
)
```

To ensure dependencies are up to date, run:

```bash
swift package update
```

---

## **3. Define the Models**
We define two models, `Sequence` and `Version`, representing the database tables.

### **`Models/Sequence.swift`**

```swift
import Fluent
import Vapor

final class Sequence: Model, Content, @unchecked Sendable {
    static let schema = "sequences"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "element_id")
    var elementId: String

    @Field(key: "sequence_number")
    var sequenceNumber: Int

    @Field(key: "comment")
    var comment: String?

    init() {}

    init(id: UUID? = nil, elementId: String, sequenceNumber: Int, comment: String?) {
        self.id = id
        self.elementId = elementId
        self.sequenceNumber = sequenceNumber
        self.comment = comment
    }
}
```

### **`Models/Version.swift`**

```swift
import Fluent
import Vapor

final class Version: Model, Content, @unchecked Sendable {
    static let schema = "versions"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "element_id")
    var elementId: String

    @Field(key: "version_number")
    var versionNumber: Int

    @Field(key: "comment")
    var comment: String?

    init() {}

    init(id: UUID? = nil, elementId: String, versionNumber: Int, comment: String?) {
        self.id = id
        self.elementId = elementId
        self.versionNumber = versionNumber
        self.comment = comment
    }
}
```

---

## **4. Create Database Migrations**
Define schema for `sequences` and `versions` tables using Fluent migrations.

### **`Migrations/CreateSequence.swift`**

```swift
import Fluent

struct CreateSequence: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("sequences")
            .id()
            .field("element_id", .string, .required)
            .field("sequence_number", .int, .required)
            .field("comment", .string)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("sequences").delete()
    }
}
```

### **`Migrations/CreateVersion.swift`**

```swift
import Fluent

struct CreateVersion: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("versions")
            .id()
            .field("element_id", .string, .required)
            .field("version_number", .int, .required)
            .field("comment", .string)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("versions").delete()
    }
}
```

---

## **5. Route Management**
Organize routes into a dedicated `routes.swift` file to keep things modular.

### **`routes.swift`**

```swift
import Vapor

func routes(_ app: Application) {
    app.get("health") { req -> String in
        return "Service is running"
    }

    // Register Iteration 7
    iteration_7(app: app)
}
```

### **`Iterations/iteration_7.swift`**

```swift
import Vapor
import Fluent

public func iteration_7(app: Application) {
    app.post("sequence") { req -> EventLoopFuture<Sequence> in
        let input = try req.content.decode(Sequence.self)
        return Sequence.query(on: req.db)
            .filter(\.$elementId == input.elementId)
            .first()
            .flatMap { existing in
                if let existing = existing {
                    existing.sequenceNumber += 1
                    existing.comment = input.comment
                    return existing.save(on: req.db).map { existing }
                } else {
                    input.sequenceNumber = 1
                    return input.save(on: req.db).map { input }
                }
            }
    }
    print("POST /sequence endpoint is ready at http://localhost:8080/sequence")

    // Keep server running
    app.logger.info("Iteration 7 server is running and ready for testing")
}
```

The server **does not shut down** after this iteration. The `main.swift` file remains untouched and continues to run iterations based on its predefined logic.

---

## **6. Application Configuration**
Update `configure.swift` to initialize the database and routes:

**`configure.swift`**:

```swift
import Fluent
import FluentSQLiteDriver
import Vapor

public func configure(_ app: Application) throws {
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    app.migrations.add(CreateSequence())
    app.migrations.add(CreateVersion())
    try app.autoMigrate().wait()

    routes(app)
}
```

---

## **7. Testing the Application**
Test the `/sequence` endpoint:

```bash
curl -X POST http://localhost:8080/sequence \
-H "Content-Type: application/json" \
-d '{ "elementId": "item1", "comment": "First sequence" }'
```

Expected response:

```json
{
    "id": "<uuid>",
    "elementId": "item1",
    "sequenceNumber": 1,
    "comment": "First sequence"
}
```

---

## **Conclusion**
In this tutorial, you:

- Set up SQLite persistence with Fluent.
- Implemented database models and migrations.
- Registered routes modularly for clean organization.
- Ensured that the server remains active for testing.

Your application is now ready for sequence management and continuous testing!

