# FountainAI OpenAPI Guidelines for Microservices

## **Introduction**

This document provides detailed guidelines for creating and updating OpenAPI specifications for FountainAI microservices. These guidelines are based on the practices refined during the development of the Central Sequence Service API (CSS). The objective is to ensure consistency, maintainability, and tool compatibility across all FountainAI microservices.

---

## **1. General Structure**

### **1.1 Use OpenAPI 3.1.0**
- All APIs must use the OpenAPI 3.1.0 standard, which supports JSON Schema Draft 2020-12, improving compatibility and extensibility.

### **1.2 Centralized Documentation Links**
- Use relative paths to external documentation:

```yaml
info:
  description: >
    Detailed implementation notes are available in the
    [external documentation](https://github.com/Contexter/FountainAI/blob/main/Docs/Implementation%20Notes.md).
  contact:
    name: FountainAI Repository
    url: https://github.com/Contexter/FountainAI
```

### **1.3 Server Definitions**
- Define both production and staging servers in the `servers` section:

```yaml
servers:
  - url: https://{service-name}.fountain.coach
    description: Production server for {Service Name} API
  - url: https://staging.{service-name}.fountain.coach
    description: Staging server for {Service Name} API
```

### **1.4 Tags and Operation IDs**
- Use descriptive `tags` to group related endpoints.
- Assign a unique `operationId` to each endpoint, adhering to naming conventions for server/client code generation:

```yaml
  /example-path:
    post:
      tags:
        - Example Tag
      operationId: exampleOperation
      summary: Short operation description
```

### **1.5 Short Descriptions**
- Keep `summary` and `description` fields concise (under 300 characters) to improve readability and tool compatibility.
- Delegate detailed implementation specifics to external documentation.

---

## **2. Standard Endpoint Patterns**

### **2.1 Create (POST)**
```yaml
  /resource:
    post:
      tags:
        - Resource Management
      summary: Create a new resource
      operationId: createResource
      description: >
        Creates a new resource and persists it to the database. Synchronization with Typesense will be triggered automatically.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateResourceRequest'
      responses:
        '201':
          description: Resource created successfully.
        '400':
          description: Invalid request parameters.
        '500':
          description: Internal server error.
```

### **2.2 Read (GET)**
```yaml
  /resource/{id}:
    get:
      tags:
        - Resource Management
      summary: Get a resource
      operationId: getResource
      description: Retrieves a resource by its ID.
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: Resource retrieved successfully.
        '404':
          description: Resource not found.
        '500':
          description: Internal server error.
```

### **2.3 Update (PUT)**
```yaml
  /resource/{id}:
    put:
      tags:
        - Resource Management
      summary: Update a resource
      operationId: updateResource
      description: Updates a resource’s details.
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UpdateResourceRequest'
      responses:
        '200':
          description: Resource updated successfully.
        '400':
          description: Invalid request parameters.
        '404':
          description: Resource not found.
        '500':
          description: Internal server error.
```

---

## **3. Components**

### **3.1 Reusable Schemas**
- Define schemas under `components/schemas` for request and response bodies:

```yaml
components:
  schemas:
    ExampleRequest:
      type: object
      properties:
        exampleId:
          type: integer
          description: Unique identifier for the example.
        details:
          type: string
          description: Additional information about the request.
      required:
        - exampleId
```

### **3.2 Error Handling**
- Define standard error schemas:

```yaml
    ErrorResponse:
      type: object
      properties:
        errorCode:
          type: string
          description: Application-specific error code.
        message:
          type: string
          description: Human-readable error message.
        details:
          type: string
          description: Additional information about the error, if available.
```

---

## **4. SQLite and Typesense Integration**

### **4.1 SQLite Schema Reference**
- Link SQLite schema documentation to the OpenAPI file:

```yaml
info:
  description: >
    Data is persisted to SQLite. Refer to the
    [SQLite Schema Documentation](https://github.com/Contexter/FountainAI/blob/main/Docs/Database%20Schema%20for%20ServiceName.md) for detailed schema information.
```

### **4.2 Typesense Integration**
- Include synchronization and retry logic in endpoint descriptions.
- Define a `TypesenseErrorResponse` schema:

```yaml
    TypesenseErrorResponse:
      type: object
      properties:
        errorCode:
          type: string
          description: Error code from Typesense.
        retryAttempt:
          type: integer
          description: Number of retry attempts.
        message:
          type: string
          description: Human-readable error message.
        details:
          type: string
          description: Additional information about the Typesense error.
```

---

## **5. Security**

### **5.1 API Key Authentication**
- Apply API Key authentication to all operations:

```yaml
components:
  securitySchemes:
    apiKeyAuth:
      type: apiKey
      in: header
      name: X-API-KEY
security:
  - apiKeyAuth: []
```

---

## **6. Implementation Process**

1. **Review Existing OpenAPI Specification**
   - Compare the service’s current state with the Central Sequence Service OpenAPI as a baseline.

2. **Apply Consistent Practices**
   - Follow the structure, schemas, and naming conventions defined here.

3. **Incorporate External Documentation**
   - Reference SQLite and Typesense documentation where relevant.

4. **Validate and Test**
   - Use Swagger or other OpenAPI tools to ensure validity.
   - Test endpoints for compatibility with SQLite and Typesense.

5. **Iterate**
   - Refine the specification based on team feedback and new requirements.

---

## **Conclusion**

These guidelines ensure consistency and maintainability across all FountainAI microservices, facilitating smoother development workflows, better API usability, and seamless tool integration. Apply this framework as the standard for all new and updated APIs within the FountainAI ecosystem.

