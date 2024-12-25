# Comprehensive Guide to the Central Sequence Service Setup

## Overview
The Central Sequence Service is designed as a scalable, maintainable, and efficient server application built on Vapor 4. It uses OpenAPI as the **single source of truth** for API design and leverages Apple's OpenAPI generator for streamlined development.

This guide explains how the setup works, including:
1. Using OpenAPI as the foundation.
2. Integrating Vapor and Fluent for backend functionality.
3. Employing SQLite and Typesense for persistence and search.
4. How to develop, test, and extend iterations.

---

## Key Components

### 1. **OpenAPI as the Source of Truth**
- The OpenAPI YAML file defines the API structure, endpoints, request/response schemas, and error handling.
- Located in the `Sources/openapi.yaml` file.
- Enables contract-driven development:
  - Developers and consumers of the API agree on a single source.
  - Backend and client developers share the same definitions.

#### OpenAPI Generator
We use [Apple's OpenAPI Generator](https://github.com/apple/swift-openapi-generator) to:
- Generate Swift types (`Types.swift`) for request and response schemas.
- Generate a Vapor server scaffold (`Server.swift`) for routing and middleware.
- Keep the backend in sync with the OpenAPI specification.

**Command to generate code:**
```bash
swift build
```

**Generated files:**
- `Types.swift`: Defines the Swift representations of API request/response payloads.
- `Server.swift`: Includes route handlers and middleware for endpoints.

> **Important:** `Server.swift` and `Types.swift` are generated files and should never be modified manually. Instead, implement all logic in separate modules, files, or services that are imported into the Vapor app. The `Server.swift` file is exclusively used to wire endpoints to these external handlers, ensuring the generated code remains untouched and maintainable.

---

### 2. **Vapor Framework**
Vapor is the core framework for the backend application, providing routing, middleware, and request handling.

**Key Features Used:**
- **Routing**: Flexible routing for endpoints defined in the OpenAPI file.
- **Middleware**: Add logging, authentication, or validation layers.
- **Lifecycle Management**: Clean shutdown and resource management.

**Key Vapor Dependencies:**
- `vapor/vapor` for the core framework.
- `vapor/fluent` for ORM.
- `vapor/fluent-sqlite-driver` for SQLite support.

---

### 3. **Fluent and SQLite**
Fluent provides a type-safe ORM for managing database models. SQLite serves as the lightweight database backend.

- **Database Models**: Define entities (e.g., scripts, sections, versions) in Swift.
- **Migrations**: Use Fluent to handle schema changes.
- **SQLite**: Ideal for lightweight, embedded storage.

Example model:
```swift
final class Script: Model, Content {
    static let schema = "scripts"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "author")
    var author: String
}
```

---

### 4. **Typesense Integration**
Typesense is used for fast and powerful full-text search capabilities.
- Indexing and searching API data.
- Synchronized with SQLite to ensure data consistency.

**Setup in Code:**
```swift
let client = TypesenseClient(configuration: .init(apiKey: "YOUR_API_KEY"))
```

---

### 5. **Iteration System**
The Central Sequence Service supports iterative development with the `--run-iteration` flag.

- Each iteration is a separate Swift function with a clear setup.
- Pass `--run-iteration <number>` to execute specific logic.

Example command:
```bash
swift run CentralSequenceService -- --run-iteration 1
```

Example iteration:
```swift
func iteration1Setup(app: Application) {
    app.get("/iteration1") { req -> String in
        "Iteration 1 is running!"
    }
}
```

---

## Development Workflow

### Step 1: Modify the OpenAPI Specification
- Edit the `openapi.yaml` file to define new endpoints, request/response schemas, or errors.

### Step 2: Regenerate Code
- Run `swift build` to regenerate `Types.swift` and `Server.swift`.

### Step 3: Implement Logic
- Create new Swift files or modules to implement route handlers, services, or business logic.
- Use `Server.swift` only to wire endpoints to handlers or services implemented in separate modules or files. This ensures the generated code remains untouched and maintainable.

### Step 4: Test Iterations
- Use the iteration system to test and isolate new features before full integration.

Example:
```bash
swift run CentralSequenceService -- --run-iteration 2
```

---

## Key Benefits of This Setup
1. **Scalability**: OpenAPI keeps the API consistent and maintainable.
2. **Flexibility**: The iteration system enables experimental features.
3. **Efficiency**: Generated code reduces manual effort and bugs.
4. **Portability**: Runs seamlessly on macOS and Linux.

---

## Troubleshooting

**Problem:** `Unknown option '--run-iteration'`
- **Solution:** Ensure the correct syntax: `swift run CentralSequenceService -- --run-iteration <number>`.

**Problem:** `Application shutdown error`
- **Solution:** Ensure `app.shutdown()` is used synchronously outside async contexts.

---

## Future Directions
- Add CI/CD pipelines to automate builds and tests.
- Extend search capabilities using Typesense.
- Explore deployment with Docker for platform independence.

---

Congratulations on setting up a modern, OpenAPI-driven Vapor application. Happy coding! 🎉

