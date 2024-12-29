# Central Sequence Service Documentation: Incremental Milestone-Based Project Plan

## **Objective**

Design a **modular and maintainable project tree** for a Swift Vapor-based application that integrates the **Swift OpenAPI Generator plugin**. The structure must facilitate clean separation of **generated** and **handwritten code** while supporting **scalability**, **extensibility**, and adherence to **Swift and Vapor conventions**.

---

## **Milestone-Based Plan**

### **1. Setup Phase**

**Step 1: Gather Inputs**
- Upload the OpenAPI specification (`openapi.yaml`). ✅ (Provided)
- Include generated Swift code files (`Server.swift` and `Types.swift`). ✅ (Provided)
- Verify compatibility and validate OpenAPI schema.

**Step 2: Generate Code (if needed)**
- Run the Swift OpenAPI Generator plugin if custom modifications are required.
- Place outputs into a dedicated `Generated/` directory.

**Step 3: Define Project Structure**

```
CentralSequenceService/
├── Package.swift
├── Sources/
│   ├── CentralSequenceService/
│   │   ├── main.swift
│   │   ├── configure.swift
│   │   ├── Routes/
│   │   ├── Handlers/
│   │   ├── Services/
│   │   ├── Models/
│   │   ├── Migrations/
│   │   ├── openapi.yaml
│   │   └── openapi-generator-config.yaml
├── Generated/
├── Tests/
└── README.md
```

---

### **2. Initial Implementation**

**Goal:** Establish a functional API endpoint framework.

1. **Routes:**
   - Register routes (`/sequence`, `/sequence/reorder`, `/sequence/version`).
   - Implement middleware (logging, API key authentication).

2. **Handlers:**
   - Connect each route to corresponding handler methods.
   - Implement error handling for API responses.

3. **Services:**
   - Create reusable business logic modules (e.g., Typesense sync service).
   - Ensure services work independently of routing and handler logic.

4. **Models and Migrations:**
   - Define database entities and schema migrations.
   - Integrate Fluent and SQLite for persistence.

5. **Tests:**
   - Unit tests for route handling.
   - Integration tests to verify database interactions.

---

### **3. Advanced Features**

**Goal:** Add scalability and extensibility.

1. **Custom Workflows:**
   - Introduce workflows for Typesense synchronization.
   - Add logic for fallback mechanisms in case of sync failure.

2. **Error Handling Middleware:**
   - Create a reusable middleware for unified error reporting.
   - Handle Typesense-specific errors gracefully.

3. **Configuration Management:**
   - Add support for environment variables.
   - Secure sensitive configurations.

---

### **4. Finalization Phase**

**Goal:** Prepare the project for production.

1. **Documentation:**
   - Auto-generate API documentation using OpenAPI specs.
   - Provide examples for cURL requests and API testing.

2. **Testing and Validation:**
   - Final compliance tests against OpenAPI specification.
   - Validate JSON serialization and deserialization.

3. **Deployment Scripts:**
   - Create Dockerfile for containerized deployment.
   - Add CI/CD pipeline for automated testing and deployment.

4. **Swagger UI Endpoint:**
   - Integrate Swagger UI endpoint as described in the [Swift OpenAPI Generator tutorial](https://swiftpackageindex.com/apple/swift-openapi-generator/1.6.0/tutorials/swift-openapi-generator/adding-openapi-and-swagger-ui-endpoints).
   - Ensure developers can view and test APIs interactively via the Swagger interface.

---

### **5. Milestone Compliance Checklist**

| Milestone          | Task                                              | Status |
|--------------------|---------------------------------------------------|--------|
| Setup Phase        | Inputs uploaded and validated                     | ✅     |
| Initial API Setup  | Routes, Handlers, Models, and Migrations defined  | ⬜     |
| Advanced Features  | Services, workflows, and middleware implemented   | ⬜     |
| Testing & Finalize | Unit, integration tests, and deployment scripts   | ⬜     |
| Compliance Checks  | Verified against OpenAPI and Typesense schemas    | ⬜     |

---

### **Dependencies**

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CentralSequenceService",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator.git", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime.git", from: "1.5.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-vapor.git", from: "1.0.1"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.3.0"),
        .package(url: "https://github.com/typesense/typesense-swift.git", from: "1.0.0")
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
                .product(name: "Typesense", package: "typesense-swift")
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
            ]
        )
    ]
)
```

---

## **Conclusion**

This plan ensures a **modular, test-driven, and scalable design** for the Swift Vapor application. Each milestone progressively builds functionality while verifying compliance with the **OpenAPI contract**. Developers can leverage this framework for building extensible API-driven applications using a **hybrid approach** that blends **automation** and **manual programming flexibility**.

