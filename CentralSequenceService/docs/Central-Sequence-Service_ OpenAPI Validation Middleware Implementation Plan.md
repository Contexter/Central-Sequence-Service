# **Central-Sequence-Service: OpenAPI Validation Middleware Implementation Plan**

## **Context and Background**

The **Central-Sequence-Service** is part of the FountainAI microservices architecture. Through rigorous efforts, we have finitely defined its OpenAPI specification (**Central-Sequence-Service.yml**), which serves as the single source of truth for the API's structure, requests, and responses. This milestone positions the service for precise, standards-compliant development and validation.

The hard work of finitely defining the FountainAI microservice APIs ensures:
- **Consistency**: A strict adherence to API contracts.
- **Clarity**: Precise documentation of expected behavior for both clients and developers.
- **Finite Scope**: Eliminating the need for generic or overly complex validation mechanisms, focusing solely on the defined API specification.

This document outlines the implementation plan for a tailored validation middleware that will validate incoming API requests against the Central-Sequence-Service OpenAPI specification.

---

## **Problem Statement**

While the OpenAPI spec is comprehensive and unambiguous, runtime request validation requires:
1. **Matching requests to the spec**:
   - Verifying paths and HTTP methods.
   - Ensuring query parameters, headers, and request bodies align with the defined schema.
2. **Enforcing the contract**:
   - Providing clear error messages for non-compliant requests.
   - Simplifying debugging by precisely pointing out schema violations.

---

## **Objective**

To implement a robust, efficient, and service-specific validation middleware for the **Central-Sequence-Service**, ensuring:
- Every incoming request adheres to the defined OpenAPI spec.
- Misconfigured or invalid requests are rejected with meaningful error messages.
- Validation is scoped strictly to the Central-Sequence-Service specification.

---

## **Implementation Plan**

### **1. Parse the OpenAPI Specification**

#### **Task**:
- Use **OpenAPIKit** to parse the Central-Sequence-Service YAML specification.
- Store the resulting document in memory for validation.

#### **Example**:
```swift
import OpenAPIKit

let specPath = "path/to/Central-Sequence-Service.yml"
let openAPIDocument = try OpenAPI.Document(fromYAMLFileAtPath: specPath)
```

---

### **2. Middleware Initialization**

#### **Task**:
- Create a `SpecificOpenAPIMiddleware` class that:
  - Loads the OpenAPI document during initialization.
  - Prepares lookup structures for paths, methods, and operations.

#### **Code Outline**:
```swift
final class SpecificOpenAPIMiddleware: Middleware {
    private let openAPIDocument: OpenAPI.Document

    init(openAPIDocument: OpenAPI.Document) {
        self.openAPIDocument = openAPIDocument
    }

    // Validation logic in `respond` method (see step 3)
}
```

---

### **3. Path and Method Validation**

#### **Task**:
- Match the request URL path and HTTP method against the OpenAPI spec.
- Reject requests with invalid paths or unsupported methods.

#### **Code Example**:
```swift
func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
    guard let pathItem = openAPIDocument.paths[OpenAPI.Path(rawValue: request.url.path)] else {
        return request.eventLoop.makeFailedFuture(
            Abort(.notFound, reason: "Path \(request.url.path) is not defined in the API spec.")
        )
    }

    guard let method = OpenAPI.HttpMethod(rawValue: request.method.rawValue.lowercased()),
          pathItem[method] != nil else {
        return request.eventLoop.makeFailedFuture(
            Abort(.methodNotAllowed, reason: "Method \(request.method.rawValue) not allowed on \(request.url.path).")
        )
    }

    return next.respond(to: request)
}
```

---

### **4. Parameter Validation**

#### **Task**:
- Validate query parameters, headers, and path parameters against the spec.

#### **Approach**:
1. Extract parameters from the request.
2. Compare them against the schema for the matched operation.
3. Return appropriate errors for missing or invalid parameters.

---

### **5. Request Body Validation**

#### **Task**:
- Parse and validate the request body if required for the matched operation.

#### **Approach**:
1. Verify that the request body is present if marked as required.
2. Validate the body structure and content type against the schema.

#### **Code Example**:
```swift
private func validateRequestBody(_ request: Request, against requestBody: OpenAPI.RequestBody) throws {
    guard let bodyData = request.body.data else {
        if requestBody.required {
            throw Abort(.badRequest, reason: "Request body is required but missing.")
        }
        return
    }

    guard let contentType = OpenAPI.ContentType(rawValue: "application/json"),
          let schema = requestBody.content[contentType]?.schema else {
        throw Abort(.unsupportedMediaType, reason: "Unsupported content type.")
    }

    // Validate body against schema (custom logic or OpenAPIKit tools)
}
```

---

### **6. Testing and Iteration**

#### **Task**:
- Use tools like Postman or Swagger UI to generate requests based on the OpenAPI spec.
- Test valid and invalid scenarios to ensure:
  - Correct requests pass validation.
  - Invalid requests return meaningful errors.

#### **Deliverables**:
- A suite of automated tests for all API endpoints.

---

## **Benefits of This Approach**

1. **Precision**:
   - Ensures all requests are validated strictly against the Central-Sequence-Service spec.
2. **Efficiency**:
   - Tailored validation avoids overhead from generic OpenAPI validation mechanisms.
3. **Future-Proof**:
   - Changes to the API spec can be directly reflected in the middleware by updating the YAML file.

---

## **Next Steps**

1. Implement the middleware as outlined.
2. Integrate it into the Central-Sequence-Service project.
3. Document the middleware behavior and usage for other developers.

---

This plan builds on the foundational work of finitely defining the FountainAI microservices APIs. By focusing on validating this **specific OpenAPI spec**, we ensure robust and reliable request validation while maintaining simplicity and performance.

