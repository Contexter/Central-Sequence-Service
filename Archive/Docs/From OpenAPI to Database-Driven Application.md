# From OpenAPI to Database-Driven Application

> Using GPT-4 to switch from OpenAPI Design Time to Database Driven Runtime  

This documentation explains how to transition from using an OpenAPI specification as the design-time source of truth to implementing a database-driven application. It is structured to provide both theoretical background and practical steps, focusing on tools like the Apple OpenAPI Generator, Vapor, Fluent, and SQLite.

---

## Introduction

In software development, OpenAPI often serves as the initial blueprint for defining API contracts. However, as the project matures, it becomes critical to establish a reliable runtime source of truth. This guide illustrates how to:

1. Use OpenAPI as the design-time source of truth.
2. Generate code using the Apple OpenAPI Generator.
3. Transition to a database-driven architecture where the database serves as the runtime source of truth.
4. Leverage the generated `Types.swift` file for database schema derivation.

---

## 1. Understanding the Role of OpenAPI

OpenAPI provides a structured definition of your API, including endpoints, request/response schemas, and validations. It acts as a:

- **Single Source of Truth** during the design phase.
- **Code Generator Input** for stubs and data models.
- **API Contract** for clients and servers.

In this workflow, OpenAPI is used to generate the Swift types and stub implementations for Vapor, setting the foundation for transitioning to database-driven operations.

---

## 2. Using Apple OpenAPI Generator

> for the following we use the concrete example of the Central Sequence Service project . Pathes and Files match this - so we need to abstract out and generalize to workflows of future project creation 

### Installation and Setup

Ensure the following dependencies in your `Package.swift` file:

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CentralSequenceService",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        // OpenAPI Generator
        .package(url: "https://github.com/apple/swift-openapi-generator.git", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime.git", from: "1.5.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-vapor.git", from: "1.0.1"),

        // Vapor
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),

        // Fluent and SQLite Driver
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.3.0"),

        // Typesense Client
        .package(url: "https://github.com/typesense/typesense-swift.git", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "CentralSequenceService",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIVapor", package: "swift-openapi-vapor"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "Typesense", package: "typesense-swift"),
            ],
            path: "Sources",
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
            ]
        )
    ]
)
```

### Automatic Generation During Build

The Apple OpenAPI Generator integrates directly into the Swift build process. When you build your project, it automatically generates the necessary types and handler stubs based on your OpenAPI specification. This ensures that the generated code is always in sync with your OpenAPI document.

Steps:

1. **Add OpenAPI Document**: Place your OpenAPI document (`openapi.yaml`) and its configuration file (*openapi-generator-config.yaml*)  at the root of your project or a dedicated folder and ensure it is correctly referenced in the build settings.
2. **Build the Project**: Simply running `swift build` will trigger the OpenAPI Generator plugin, creating the necessary files , properly scoped to the source target , at .build/plugins/outputs/centralsequenceservice/CentralSequenceService/destination/OpenAPIGenerator/GeneratedSources

**Inspect Generated Files**: During each build, the following files are generated automatically:

- `Types.swift`: Contains models for OpenAPI schemas.
- `Server.swift`: Includes protocol definitions for API handlers.

This automation eliminates the need for manually running the generator and ensures consistency between the OpenAPI specification and the generated code.

---

## 3. Deriving the Database Schema

### Mapping OpenAPI Schemas to Database Tables

Use the generated `Types.swift` file to create Fluent models and migrations. This process can be facilitated by leveraging GPT-4 for complex schema interpretations and generating Fluent code mappings. Example mapping:

#### OpenAPI Schema Example

```yaml
components:
  schemas:
    Sequence:
      type: object
      properties:
        id:
          type: string
        elementId:
          type: integer
        sequenceNumber:
          type: integer
```

#### Generated Swift Type

```swift
public struct SequenceResponse: Codable {
    public let sequenceNumber: Int
    public let elementId: Int
}
```

#### Fluent Model

```swift
import Fluent

final class Sequence: Model, Content {
    static let schema = "sequences"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "sequence_number")
    var sequenceNumber: Int

    @Field(key: "element_id")
    var elementId: Int
}
```

#### Migration

```swift
import Fluent

struct CreateSequence: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("sequences")
            .id()
            .field("sequence_number", .int, .required)
            .field("element_id", .int, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("sequences").delete()
    }
}
```

---

## 4. Implementing API Handlers

### Using Generated Stubs

Modify the stubs in the `Server.swift` file to interact with the database:

#### Example Handler: Generating a Sequence

```swift
func generateSequenceNumber(_ input: Operations.generateSequenceNumber.Input) async throws -> Operations.generateSequenceNumber.Output {
    guard case let .json(requestBody) = input.body else {
        throw Abort(.badRequest, reason: "Invalid content type")
    }

    let sequenceNumber = try await findOrCreateSequenceNumber(elementId: requestBody.elementId)

    let response = Components.Schemas.SequenceResponse(sequenceNumber: sequenceNumber)
    return .created(.init(body: .json(response)))
}

private func findOrCreateSequenceNumber(elementId: Int) async throws -> Int {
    try await app.db.transaction { db in
        if let existing = try await Sequence.query(on: db).filter(\.$elementId == elementId).first() {
            existing.sequenceNumber += 1
            try await existing.save(on: db)
            return existing.sequenceNumber
        } else {
            let newSequence = Sequence(elementId: elementId, sequenceNumber: 1)
            try await newSequence.save(on: db)
            return newSequence.sequenceNumber
        }
    }
}
```

---

## 5. Synchronizing OpenAPI and Database

### Validation

Ensure the OpenAPI schema matches the database schema:

- Use automated tests to verify consistency.
- Add runtime validations to confirm API requests conform to database constraints.

### Schema Updates

For schema changes:

1. Update the OpenAPI specification.
2. Regenerate `Types.swift` during build.
3. Modify Fluent models and migrations accordingly.

---

## 6. Conclusion

This workflow demonstrates how OpenAPI can drive both API design and database implementation. While OpenAPI remains the design-time source of truth, the database ensures runtime consistency and scalability. Leveraging tools like the Apple OpenAPI Generator and Fluent simplifies this transition and enables a clean, maintainable architecture.

