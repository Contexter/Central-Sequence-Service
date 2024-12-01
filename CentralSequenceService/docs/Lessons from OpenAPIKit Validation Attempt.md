
# Lessons from OpenAPIKit Validation Attempt

---

## **Purpose**

This document captures the insights and learnings from the attempts to integrate OpenAPIKit for API validation in the Central Sequence Service. It outlines the rationale behind the approach, the challenges faced, and the conclusions that inform the decision to proceed with a simplified validation mechanism.

---

## **Background**

### **Why Validation?**
Validation ensures:
- Requests adhere to defined structures.
- Errors are caught early in the request lifecycle.
- Consistent adherence to API contracts defined in an OpenAPI specification.

### **Initial Approach**
We aimed to use **OpenAPIKit** for validation, leveraging:
1. An OpenAPI schema (`Central-Sequence-Service.yml`).
2. Middleware (`OpenAPIValidationMiddleware`) to:
   - Validate HTTP paths and methods against the schema.
   - Check JSON body structure and required fields.

---

## **Challenges Faced**

### 1. **Complexity of Integration**
- **OpenAPIKit's Design**: 
  - It is robust for OpenAPI 3.0 schema handling but requires expertise in:
    - Handling types like `Either`, `Optional`, and `Any`.
    - Mapping HTTP methods and paths correctly.
  - **Overhead**: Schema parsing and request validation add significant complexity to the app's lifecycle.

### 2. **Frequent Errors**
- Errors in implementation included:
  - Type mismatches (`Any` not conforming to `Decodable`).
  - Incorrect usage of OpenAPIKit APIs (e.g., resolving paths and operations).
  - Issues with optional and required fields in the schema.
- These issues compounded debugging efforts and delayed progress.

### 3. **Mismatch Between Requirements and Implementation**
- The actual need is to validate:
  - Basic HTTP methods.
  - JSON structure and required fields.
  - Simple request constraints.
- A full OpenAPI validation framework introduced unnecessary complexity.

---

## **Key Learnings**

1. **Scope of Validation Matters**
   - A full OpenAPI schema validation isn't always necessary. Simpler checks can cover most use cases.

2. **Start Simple**
   - Basic validation using tools like `JSONDecoder` or explicit field checks can achieve the same results with less effort.

3. **Incremental Complexity**
   - Complex frameworks like OpenAPIKit should be integrated incrementally, starting with isolated validation for specific endpoints.

---

## **Conclusion**

The current iteration demonstrates that using OpenAPIKit for middleware validation introduces more complexity than value at this stage. A simplified approach will provide faster implementation and greater flexibility.

---

## **Next Steps**

### 1. **Simplify Validation**
   - Implement lightweight middleware to validate:
     - HTTP methods.
     - JSON body presence and structure.
     - Required fields.

### 2. **Retain OpenAPI Spec for Documentation**
   - The OpenAPI spec (`Central-Sequence-Service.yml`) will remain for API documentation and manual validation purposes.

### 3. **Revisit Advanced Validation Later**
   - OpenAPIKit can be reintroduced for specific use cases once the simplified validation is in place.

---

### **Git Commit Message**

```
**Subject Line**: Document OpenAPIKit integration learnings and pivot to simplified validation

**Body**:
This commit documents the insights from our attempts to integrate OpenAPIKit for API validation in the Central Sequence Service. It highlights:

- The rationale for validation and why OpenAPIKit was chosen.
- Challenges faced, including technical complexity and scope mismatch.
- Key learnings about balancing complexity and requirements.

The conclusion is to pivot to a simplified validation approach, focusing on lightweight middleware to handle basic checks.

This documentation will be added to the repo's `docs/` directory as `validation-learnings.md`.

Next Steps:
1. Implement simplified validation middleware.
2. Retain OpenAPI spec for documentation purposes.
3. Revisit advanced validation as needed.
```

