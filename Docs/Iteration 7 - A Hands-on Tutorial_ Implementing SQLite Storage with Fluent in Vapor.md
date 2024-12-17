# Iteration 7 - Resolving Swift 6 Compatibility Warnings and SQLite Integration in Vapor

This hands-on tutorial will guide you through integrating SQLite-backed persistence into a Vapor-based project using Fluent. Additionally, we'll address Swift 6 compatibility warnings regarding the `Sendable` protocol and improve the `configure.swift` file to register routes properly.

By the end of this tutorial, you will:

- Integrate Fluent and SQLite into the project.
- Define database models for sequences and versions.
- Create migrations to initialize the database schema.
- Implement and test routes that interact with the database.
- Resolve Swift 6 warnings related to `Sendable` compliance.
- Ensure the server remains running for testing.

Let's get started!

---

## **1. Project Structure**
We will add new models, migrations, and an iteration script. Here is the project structure after completing this tutorial:

```
CentralSequenceService/
├── Package.swift
├── Sources/
│   ├── main.swift
│   ├── configure.swift
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

---

## **2. Package Dependencies**
The `Package.swift` file already includes the required dependencies for Vapor, Fluent, and SQLite. No changes are needed:

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

Run the following command to fetch dependencies:

```bash
swift package update
```

---

## **3. Define Database Models**
We will define two models, `Sequence` and `Version`, to persist sequence and version data. Additionally, we will mark the classes as explicitly non-`Sendable` to resolve Swift 6 warnings.

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

## **4. Create Migrations**
Create two migration files to define the database schema.

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

## **5. Configure Fluent and Register Routes**
Update `configure.swift` to configure SQLite, register migrations, and define the missing `routes` method.

**`configure.swift`**:

```swift
import Fluent
import FluentSQLiteDriver
import Vapor

public func configure(_ app: Application) throws {
    // Configure SQLite database
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    // Register migrations
    app.migrations.add(CreateSequence())
    app.migrations.add(CreateVersion())

    try app.autoMigrate().wait()

    // Register routes
    routes(app)
}

func routes(_ app: Application) {
    app.get("health") { req -> String in
        return "Service is running"
    }
}
```

---

## **6. Implement the Routes**
Create `iteration_7.swift` to implement the `/sequence` endpoint using the database.

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
}
```

---

## **7. Running and Testing**

1. Start the application:

```bash
swift run CentralSequenceService --env production
```

2. Use `curl` to test the endpoint:

```bash
curl -X POST http://localhost:8080/sequence \
-H "Content-Type: application/json" \
-d '{ "elementId": "item1", "comment": "First sequence" }'
```

3. Verify that the server continues running for repeated requests.

---

## **Conclusion**
This tutorial demonstrates:

- Integrating Fluent and SQLite for persistence.
- Ensuring compliance with the OpenAPI specification by including fields like `comment`.
- Resolving Swift 6 warnings related to `Sendable` classes.
- Setting up routes and ensuring a persistent, functional server for testing.

Your application now supports robust, persistent storage with SQLite!

