# **FountainAI Documentation: Refined Meta Prompt for Incremental Milestone-Based Project Development and Final Implementation**

## **Objective**

Design a **modular and maintainable project tree** for a Swift Vapor-based application that integrates the **Swift OpenAPI Generator plugin**. The structure must facilitate clean separation of **generated** and **handwritten code** while supporting **scalability**, **extensibility**, and adherence to **Swift and Vapor conventions**.

This refined prompt addresses lessons learned from previous attempts by emphasizing **clarity**, **testing integration**, **file-by-file instructions**, and **version tracking** to avoid inconsistencies and omissions.

---

## **Meta Prompt**

### **Task:**

Create a **project tree** for a Swift Vapor application using the **Swift OpenAPI Generator plugin**. The solution must:

---

### **1. Gather Necessary Inputs:**

**Setup Steps:**

1. **Provide Input Files:**
   - Upload the **OpenAPI specification file** (`openapi.yaml`) as the contract.
   - Upload the **generated code** (`Server.swift` and `Types.swift`) if too large for direct integration.

2. **Generate Code (if needed):**
   - Use the **Swift OpenAPI Generator plugin** to produce the code.
   - Place generated files (`Server.swift` and `Types.swift`) in the `Generated/` directory.

3. **Validate Inputs:**
   - Confirm the OpenAPI specification aligns with requirements.
   - Analyze the generated code for schema definitions, routes, and serialization.

**Key Refinements:**
- Maintain **explicit version tracking** for files and updates to prevent loss of edits.
- Specify **testing requirements** early to ensure validations start at each milestone.

---

### **2. Meet the Overall Goals:**

- **Clean and Maintainable Structure:** Design scalable and modular code components.
- **Seamless Integration:** Combine **generated files** (`Server.swift`, `Types.swift`) with **custom logic** using a **hybrid approach**.
- **Incremental Development:** Ensure each milestone **extends the previous state** and supports progressive development.
- **Testing-Driven Workflow:** Incorporate **unit and integration tests** directly into each milestone rather than leaving them for later phases.
- **Git Version Control:** Integrate proper **Git workflows** for source code tracking, including:
  - **Branches for Features:** Create feature-specific branches for isolated development.
  - **Commits with Context:** Ensure meaningful commit messages to document changes.
  - **Tags for Milestones:** Mark each milestone with Git tags to provide reference points.
  - **Pull Requests and Reviews:** Facilitate code reviews before merging into main branches.

---

### **3. Follow Swift Package and Vapor Conventions:**

- Organize code under `Sources/` for **modularity**.
- Directories to include:
  - **Handlers:** Implements business logic for API operations.
  - **Routes:** Registers routes and middleware.
  - **Models and Migrations:** Defines database entities and schema changes.
  - **Services:** Encapsulates reusable business logic.
  - **Tests:** Implements **unit**, **integration**, and **contract compliance tests**.

**Avoid Pitfalls:**
- **No Placeholder Sections:** Avoid “content pending” or placeholders—provide **complete implementations**.
- **Prevent Fragmentation:** Keep related files (e.g., routes and handlers) grouped for logical flow.

---

### **4. Plugin Configuration and Integration (Hybrid Approach):**

- Include `openapi-generator-config.yaml` to guide code generation.
- Place generated files (`Server.swift`, `Types.swift`) into the `Generated/` directory.

> **Note:** The generated code eliminates much of the **ceremonial code**—serialization, deserialization, and schema compliance—allowing developers to focus on **business logic**. This hybrid approach ensures transparency and supports extending functionality with custom workflows.

**Leverage Generated Code:**
- **Schemas and Models:** Ensure compliance with OpenAPI definitions.
- **Routes and Serialization:** Utilize auto-generated handlers for basic API functionality.

**Extend with Manual Logic:**
- **Custom Workflows:** Add services for database sync, external APIs, and custom operations.
- **Error Handling and Middleware:** Implement additional layers for specific cases.

**Clarify Generated Code Behavior:**
- Specify that generated files are created **at build time** via **target configuration** and should not be **manually copied**.
- Demonstrate **where and how** to extend generated code safely without breaking compliance.

---

### **5. Typesense Integration:**

- Integrate the [Typesense Swift Client](https://github.com/typesense/typesense-swift.git) for **fast, typo-tolerant search capabilities**.
- Implement **manual sync logic** where needed, ensuring compliance with the OpenAPI-defined schemas.

**Refinement Tip:** Provide **unit tests for sync operations** and validate schema adherence during synchronization.

---

### **6. Incremental Milestones and Compliance Checks:**

- Each milestone must:
  - Introduce **working code** that compiles successfully.
  - Provide **unit and integration tests** validating correctness.
  - Include **cURL examples** to verify routes manually.
  - Verify compliance with the **OpenAPI contract** by comparing outputs with schemas.

**Enhanced Milestone Focus:**
- Track each phase as a **versioned snapshot** to retain edits and prevent regressions.
- Add testing targets at **each milestone** instead of deferring them to later stages.
- Use **Git tags and branches** to align code history with milestone progress.

---

### **7. Error Handling and Scalability Focus:**

- Implement reusable **error models** (e.g., `ErrorResponse`, `TypesenseErrorResponse`).
- Add middleware to log and process errors in a unified format.
- Design database migrations with constraints to support **scalability**.
- **Expand tests** to validate error responses under edge cases.

---

### **8. Inputs:**

#### **1. OpenAPI Specification**
- Require a specific OpenAPI specification file (`openapi.yaml`) as the contract.

#### **2. Templated Package.swift**

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "{{ProjectName}}",
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
            name: "{{ProjectName}}",
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

### **9. Example Project Tree (Milestone Updates):**

```
{{ProjectName}}/
├── Package.swift
├── Sources/
│   ├── {{ProjectName}}/
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

## **Conclusion**

This meta prompt ensures a **modular, test-driven, and scalable design** for a Swift Vapor application. It integrates key refinements such as **version tracking**, **explicit testing tasks**, **Git workflows**, and **generated code explanations**, addressing earlier shortcomings to guarantee a smoother implementation process.

