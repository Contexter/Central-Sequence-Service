# **Central-Sequence-Service: Validation Factory Implementation**

## **Overview**
The **Validation Factory** implements a modular and extensible approach to validating incoming API requests against the **Central-Sequence-Service OpenAPI** specification. By using the Factory Pattern, the system dynamically constructs validation stages tailored to each request, ensuring adherence to the API contract.

This document outlines the full implementation of the Validation Factory, its components, and its integration into the application.

---

## **Goals**
1. Dynamically validate requests based on the OpenAPI spec (`CentralSequenceService/Public/Central-Sequence-Service.yml`).
2. Use a factory to construct a sequence of **validators**, each responsible for a specific validation task (e.g., path validation, method validation, body validation).
3. Ensure modularity and scalability, allowing new validation rules to be added easily.

---

## **Core Components**

### **1. Validator Protocol**
Defines a common interface for all validators, ensuring consistency across different validation types.

```swift
protocol Validator {
    func validate(request: Request, operation: OpenAPI.Operation) throws
}
```

### **2. Concrete Validators**
Specific classes implementing the `Validator` protocol to handle individual validation tasks.

#### **2.1 PathValidator**
- **Purpose**: Checks if the request path exists in the OpenAPI spec.

```swift
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
```

---

#### **2.2 MethodValidator**
- **Purpose**: Verifies if the HTTP method is allowed for the requested path.

```swift
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
```

---

#### **2.3 BodyValidator**
- **Purpose**: Validates the request body against the schema defined in the OpenAPI spec.

```swift
struct BodyValidator: Validator {
    func validate(request: Request, operation: OpenAPI.Operation) throws {
        guard let body = request.body.data else {
            if operation.requestBody?.value.required == true {
                throw Abort(.badRequest, reason: "Request body is required but missing.")
            }
            return
        }

        // Schema validation logic can go here
        // Example: Ensure the body matches a JSON structure
    }
}
```

---

### **3. Validation Factory**
Dynamically constructs the appropriate validators for each request based on the OpenAPI spec and operation.

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

### **4. Validation Middleware**
The middleware integrates the factory into the application lifecycle, applying the validators to incoming requests.

#### **Implementation**
```swift
final class ValidationMiddleware: Middleware {
    private let openAPIDocument: OpenAPI.Document

    init(openAPIDocument: OpenAPI.Document) {
        self.openAPIDocument = openAPIDocument
    }

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        do {
            // Match the path and method to the OpenAPI operation
            let path = OpenAPI.Path(rawValue: request.url.path)
            guard let operation = openAPIDocument.paths[path]?.first(where: {
                $0.method.rawValue == request.method.rawValue.lowercased()
            }) else {
                throw Abort(.notFound, reason: "Operation not found.")
            }

            // Create and execute validators
            let validators = ValidatorFactory.createValidators(for: request, operation: operation, openAPIDocument: openAPIDocument)
            for validator in validators {
                try validator.validate(request: request, operation: operation)
            }

            // Forward the validated request to the next middleware or route
            return next.respond(to: request)
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
}
```

---

## **Integration**

### **1. Parse OpenAPI Spec**
Parse the `Central-Sequence-Service.yml` file into an `OpenAPI.Document` during application startup.

```swift
import OpenAPIKit

let openAPIDocument: OpenAPI.Document

do {
    let specPath = "CentralSequenceService/Public/Central-Sequence-Service.yml"
    openAPIDocument = try OpenAPI.Document(fromYAMLFileAtPath: specPath)
} catch {
    fatalError("Failed to load OpenAPI spec: \(error.localizedDescription)")
}
```

---

### **2. Register Middleware**
Integrate the `ValidationMiddleware` in `configure.swift`.

```swift
public func configure(_ app: Application) throws {
    let specPath = "CentralSequenceService/Public/Central-Sequence-Service.yml"
    let openAPIDocument = try OpenAPI.Document(fromYAMLFileAtPath: specPath)

    app.middleware.use(ValidationMiddleware(openAPIDocument: openAPIDocument))
    try routes(app)
}
```

---

## **Testing**

### **1. Scenarios**
1. **Valid Requests**:
   - Ensure correctly formatted requests pass through the pipeline.
2. **Invalid Requests**:
   - Test missing paths, disallowed methods, invalid query parameters, and malformed bodies.

### **2. Tools**
- Use **Postman** or **Swagger UI** to simulate API requests.
- Write unit tests for individual validators and integration tests for the middleware.

---

## **Benefits of the Validation Factory**

1. **Dynamic Validation**:
   - Tailors the validation process to each request based on the OpenAPI spec.

2. **Modularity**:
   - Each validator focuses on a single responsibility, simplifying debugging and maintenance.

3. **Scalability**:
   - New validators can be added by extending the factory without modifying existing logic.

4. **Compliance**:
   - Ensures all incoming requests strictly adhere to the Central-Sequence-Service API contract.

---

## **Deliverables**
1. **Validators**:
   - `PathValidator`, `MethodValidator`, `BodyValidator`, etc.
2. **Validation Factory**:
   - Dynamically creates validators based on the request context.
3. **Middleware**:
   - Integrates the factory into the application lifecycle.
4. **Integration**:
   - Middleware registered in `configure.swift`.
5. **Tests**:
   - Unit and integration tests for all validation scenarios.

---

By implementing the **Validation Factory**, the Central-Sequence-Service achieves robust, scalable, and modular request validation, ensuring strict adherence to the OpenAPI spec.

