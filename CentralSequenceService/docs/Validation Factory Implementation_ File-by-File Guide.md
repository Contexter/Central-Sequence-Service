# **Validation Factory Implementation: File-by-File Guide**

This guide provides a structured file-by-file breakdown for implementing the **Validation Factory** within the Central-Sequence-Service project.

---

## **1. File: `CentralSequenceService/Public/Central-Sequence-Service.yml`**

### **Purpose**
- This is your OpenAPI specification file, defining the API paths, methods, parameters, and schemas.
- It’s already located in the `Public` directory.

### **What to Do**
- Ensure the file is up-to-date with all API definitions.
- Validation logic will rely entirely on the correctness of this spec.

---

## **2. File: `CentralSequenceService/Sources/App/Middleware/ValidationMiddleware.swift`**

### **Purpose**
- Create a new middleware file to house the **ValidationMiddleware** class.
- This file will:
  - Load the OpenAPI spec.
  - Use the **Validation Factory** to execute validators.

### **What to Do**
Create the file `ValidationMiddleware.swift` and implement the middleware logic.

#### **File Location**
```
CentralSequenceService/Sources/App/Middleware/ValidationMiddleware.swift
```

#### **Content**
```swift
import Vapor
import OpenAPIKit

final class ValidationMiddleware: Middleware {
    private let openAPIDocument: OpenAPI.Document

    init(openAPIDocument: OpenAPI.Document) {
        self.openAPIDocument = openAPIDocument
    }

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        do {
            let path = OpenAPI.Path(rawValue: request.url.path)
            guard let operation = openAPIDocument.paths[path]?.first(where: {
                $0.method.rawValue == request.method.rawValue.lowercased()
            }) else {
                throw Abort(.notFound, reason: "Operation not found.")
            }

            let validators = ValidatorFactory.createValidators(for: request, operation: operation, openAPIDocument: openAPIDocument)
            for validator in validators {
                try validator.validate(request: request, operation: operation)
            }

            return next.respond(to: request)
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
}
```

---

## **3. File: `CentralSequenceService/Sources/App/Validators/Validator.swift`**

### **Purpose**
- Define the `Validator` protocol that all individual validators will implement.
- This ensures consistency and modularity across all validators.

### **What to Do**
Create the file `Validator.swift` and define the protocol.

#### **File Location**
```
CentralSequenceService/Sources/App/Validators/Validator.swift
```

#### **Content**
```swift
protocol Validator {
    func validate(request: Request, operation: OpenAPI.Operation) throws
}
```

---

## **4. File: `CentralSequenceService/Sources/App/Validators/ConcreteValidators.swift`**

### **Purpose**
- Implement individual concrete validators (`PathValidator`, `MethodValidator`, `BodyValidator`).
- These validators handle specific validation tasks.

### **What to Do**
Create the file `ConcreteValidators.swift` and define all concrete validator classes.

#### **File Location**
```
CentralSequenceService/Sources/App/Validators/ConcreteValidators.swift
```

#### **Content**
```swift
import Vapor
import OpenAPIKit

struct PathValidator: Validator {
    private let paths: OpenAPI.PathItem.Map

    init(paths: OpenAPI.PathItem.Map) {
        self.paths = paths
    }

    func validate(request: Request, operation: OpenAPI.Operation) throws {
        let path = OpenAPI.Path(rawValue: request.url.path)
        guard paths[path] != nil else {
            throw Abort(.notFound, reason: "Path \(request.url.path) is not defined.")
        }
    }
}

struct MethodValidator: Validator {
    private let operation: OpenAPI.Operation

    init(operation: OpenAPI.Operation) {
        self.operation = operation
    }

    func validate(request: Request, operation: OpenAPI.Operation) throws {
        let method = OpenAPI.HttpMethod(rawValue: request.method.rawValue.lowercased())
        guard method != nil else {
            throw Abort(.methodNotAllowed, reason: "Method \(request.method.rawValue) is not allowed.")
        }
    }
}

struct BodyValidator: Validator {
    func validate(request: Request, operation: OpenAPI.Operation) throws {
        guard let body = request.body.data else {
            if operation.requestBody?.value.required == true {
                throw Abort(.badRequest, reason: "Request body is required but missing.")
            }
            return
        }
        // Add schema validation logic here
    }
}
```

---

## **5. File: `CentralSequenceService/Sources/App/Validators/ValidatorFactory.swift`**

### **Purpose**
- Dynamically create a list of validators based on the OpenAPI spec and request context.
- Centralize the creation logic for better maintainability.

### **What to Do**
Create the file `ValidatorFactory.swift` and implement the factory logic.

#### **File Location**
```
CentralSequenceService/Sources/App/Validators/ValidatorFactory.swift
```

#### **Content**
```swift
struct ValidatorFactory {
    static func createValidators(for request: Request, operation: OpenAPI.Operation, openAPIDocument: OpenAPI.Document) -> [Validator] {
        return [
            PathValidator(paths: openAPIDocument.paths),
            MethodValidator(operation: operation),
            BodyValidator()
        ]
    }
}
```

---

## **6. File: `CentralSequenceService/Sources/App/configure.swift`**

### **Purpose**
- Integrate the `ValidationMiddleware` into the application lifecycle.
- Parse the OpenAPI spec and register the middleware.

### **What to Do**
Edit the existing `configure.swift` file to include the `ValidationMiddleware`.

#### **File Location**
```
CentralSequenceService/Sources/App/configure.swift
```

#### **Changes**
```swift
import OpenAPIKit

public func configure(_ app: Application) throws {
    let specPath = "CentralSequenceService/Public/Central-Sequence-Service.yml"
    let openAPIDocument = try OpenAPI.Document(fromYAMLFileAtPath: specPath)

    app.middleware.use(ValidationMiddleware(openAPIDocument: openAPIDocument))
    try routes(app)
}
```

---

## **7. Testing**

### **File: `CentralSequenceService/Tests/AppTests/ValidationMiddlewareTests.swift`**

### **Purpose**
- Write unit tests for the `ValidationMiddleware` and individual validators.

### **What to Do**
Create the file `ValidationMiddlewareTests.swift` in the `AppTests` directory and add test cases.

#### **File Location**
```
CentralSequenceService/Tests/AppTests/ValidationMiddlewareTests.swift
```

#### **Content**
```swift
import XCTest
@testable import App

final class ValidationMiddlewareTests: XCTestCase {
    func testValidRequest() {
        // Test a valid request passes through the middleware
    }

    func testInvalidPath() {
        // Test that an invalid path is rejected
    }

    func testInvalidMethod() {
        // Test that an invalid HTTP method is rejected
    }

    func testMissingBody() {
        // Test that a missing required body is rejected
    }
}
```

---

## **Summary of Files**

### **Files to Create**
1. `Sources/App/Middleware/ValidationMiddleware.swift`
2. `Sources/App/Validators/Validator.swift`
3. `Sources/App/Validators/ConcreteValidators.swift`
4. `Sources/App/Validators/ValidatorFactory.swift`

### **Files to Edit**
1. `Public/Central-Sequence-Service.yml`
2. `Sources/App/configure.swift`

### **Files for Testing**
1. `Tests/AppTests/ValidationMiddlewareTests.swift`

---

This guide provides a complete roadmap for implementing the Validation Factory with clear instructions on where to edit or create files in the project. Let me know if you'd like further clarification or assistance!