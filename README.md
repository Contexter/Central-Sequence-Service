# **Dynamic Vapor App Generation Using OpenAPIKit**

## **Overview**
This documentation outlines the foundational approach to dynamically generate a Vapor application using OpenAPIKit with the FountainAI OpenAPI specifications as the single source of truth. This method removes the need for a static code generator, instead relying on runtime mechanisms to create routes, models, and middleware based on OpenAPI documents.

---

## **Objectives**
1. **Single Source of Truth**: Use FountainAI OpenAPIs to ensure consistency and synchronization of APIs across the system.
2. **Dynamic Integration**: Parse OpenAPI documents at runtime to dynamically configure a Vapor application.
3. **Scalability**: Support future changes in the API without requiring manual updates or re-generation of code.
4. **Validation**: Ensure all requests and responses are validated against OpenAPI schemas to maintain standards compliance.
5. **Flexibility**: Provide extensibility for developers to add custom behaviors or augment auto-generated components.

---

## **Key Components**

### **1. OpenAPI Specification as Input**
The OpenAPI specification (in YAML or JSON) provided by FountainAI acts as the blueprint for the entire application. The document defines:
- **Paths**: API endpoints and HTTP methods.
- **Schemas**: Request and response models.
- **Parameters**: Query, path, and body parameters.
- **Responses**: Expected results for each endpoint.
- **Security**: Authentication and authorization mechanisms.

### **2. OpenAPIKit Integration**
OpenAPIKit is the backbone of the parsing and validation process:
- **Parsing**: Converts the OpenAPI document into structured Swift types.
- **Validation**: Validates the document for compliance with OpenAPI 3.x standards.
- **Schemas**: Provides `JSONSchema` for validating request and response payloads.

### **3. Dynamic Components**
This approach dynamically generates the following at runtime:
- **Routes**: Extracted from OpenAPI paths and HTTP methods.
- **Models**: Derived from OpenAPI schemas for request/response handling.
- **Validation Middleware**: Ensures runtime payload validation against OpenAPI schemas.
- **Controllers**: Handles the core business logic for routes.

---

## **Implementation Details**

### **Step 1: Parse OpenAPI Document**
Use OpenAPIKit to parse the OpenAPI specification into a structured format:
```swift
import OpenAPIKit

let openAPIDocumentYAML = """
(openAPI YAML from FountainAI)
"""
let document = try OpenAPI.Document(yaml: openAPIDocumentYAML)
```

---

### **Step 2: Extract and Register Routes**
Dynamically extract routes and HTTP methods from the OpenAPI document and register them with Vapor:
```swift
func registerRoutes(from document: OpenAPI.Document, app: Application) {
    for (path, pathItem) in document.paths {
        if let getOperation = pathItem.get {
            app.get(path) { req -> Response in
                // Example GET handler
                let responseBody = ["message": "GET \(path) handled"]
                return Response(status: .ok, body: .init(string: responseBody.description))
            }
        }
        
        if let postOperation = pathItem.post {
            app.post(path) { req -> Response in
                let requestBody = try req.content.decode([String: String].self)
                // Example POST handler
                let responseBody = ["message": "POST \(path) handled", "data": requestBody]
                return Response(status: .created, body: .init(string: responseBody.description))
            }
        }
    }
}
```

---

### **Step 3: Dynamic Schema Validation**
Implement middleware for schema validation of incoming requests and outgoing responses:
```swift
struct SchemaValidationMiddleware: Middleware {
    let schema: OpenAPI.JSONSchema

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        do {
            let body = try request.content.decode([String: Any].self)
            if validateRequest(using: schema, body: body) {
                return next.respond(to: request)
            } else {
                return request.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Invalid payload"))
            }
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
}
```

Validation logic uses OpenAPIKit's `JSONSchema`:
```swift
func validateRequest(using schema: OpenAPI.JSONSchema, body: [String: Any]) -> Bool {
    do {
        let instance = try AnyCodable(body)
        return schema.validate(instance: instance)
    } catch {
        print("Validation failed: \(error)")
        return false
    }
}
```

---

### **Step 4: Generate Models**
Generate models for request and response handling dynamically from OpenAPI schemas:
```swift
func generateModel(from schema: OpenAPI.JSONSchema, name: String) -> String {
    var properties = ""
    if case let .object(_, objectContext) = schema.value {
        for (key, propertySchema) in objectContext.properties {
            let type = mapJSONSchemaToSwiftType(propertySchema)
            properties += "    var \(key): \(type)\n"
        }
    }
    return """
    struct \(name): Codable {
    \(properties)}
    """
}

func mapJSONSchemaToSwiftType(_ schema: OpenAPI.JSONSchema) -> String {
    switch schema.value {
    case .string: return "String"
    case .integer: return "Int"
    case .number: return "Double"
    case .boolean: return "Bool"
    default: return "Any"
    }
}
```

---

### **Step 5: Scaffold Vapor Application**
Integrate all components into a running Vapor application:
```swift
import Vapor

func configure(_ app: Application) throws {
    // Fetch and parse OpenAPI document
    let document = try OpenAPI.Document(yaml: openAPIDocumentYAML)
    
    // Register routes dynamically
    registerRoutes(from: document, app: app)
    
    // Optionally add schema validation middleware
    if let characterSchema = document.components.schemas["Character"] {
        app.middleware.use(SchemaValidationMiddleware(schema: characterSchema))
    }
}
```

---

### **Advantages of This Approach**
1. **Single Source of Truth**: The OpenAPI specification drives all aspects of the app.
2. **Dynamic Configuration**: Reflects API changes immediately without regenerating code.
3. **Standards Compliance**: OpenAPIKit ensures compliance with OpenAPI standards.
4. **Extensibility**: Easily add custom logic or behaviors.
5. **Validation Assurance**: Guarantees schema validation at runtime.

---

### **Future Enhancements**
1. **UI for API Composition**: Add an interface for creating and editing APIs dynamically.
2. **Integration Testing**: Generate and run tests against the implemented APIs.
3. **Real-Time Updates**: Automatically reload routes and models when the OpenAPI document changes.
4. **Error Handling**: Add comprehensive error handling for parsing and validation failures.

---

### **Conclusion**
This dynamic approach simplifies the creation of API-driven Vapor applications by leveraging OpenAPIKit and the OpenAPI specification as the single source of truth. It reduces manual effort, enhances consistency, and ensures standards compliance while offering high flexibility and scalability.
