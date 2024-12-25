# How to Use and Implement the Central Sequence Service OpenAPI Draft

This guide provides a comprehensive overview of the updated OpenAPI specification for the Central Sequence Service, along with references to supporting documentation. It serves as a standalone resource for understanding and implementing this specification.

---

## Overview

The Central Sequence Service API is designed to manage sequence numbers for story elements. The system ensures order and consistency by leveraging:

- **SQLite** for data persistence
- **Typesense** for synchronization and search capabilities

### Key Features:
- **Generate Sequence Numbers** for story elements
- **Reorder Elements** while maintaining consistency
- **Create Versions** of existing elements

---

## API Specification

The specification follows OpenAPI 3.1.0 standards and is optimized for both human readability and machine-generated code, including tools like Apple’s Swift OpenAPI Generator.

### Endpoints:

#### 1. **Generate Sequence Number**
**Path:** `/sequence`  
**Method:** `POST`  
**OperationId:** `generateSequenceNumber`  
**Tag:** `SequenceManagement`  
**Description:** Creates a new sequence number and synchronizes it with Typesense.

#### 2. **Reorder Elements**
**Path:** `/sequence/reorder`  
**Method:** `PUT`  
**OperationId:** `reorderElements`  
**Tag:** `SequenceManagement`  
**Description:** Updates the sequence order for multiple elements and syncs them with Typesense.

#### 3. **Create New Version**
**Path:** `/sequence/version`  
**Method:** `POST`  
**OperationId:** `createVersion`  
**Tag:** `VersionManagement`  
**Description:** Creates a new version of an element and synchronizes it with Typesense.

---

## Supporting Documentation

This OpenAPI draft references the following key documents for additional details:

1. **[Database Schema for Central Sequence Service](../../Docs/Database%20Schema%20for%20Central%20Sequence%20Service.md)**  
   - Provides the SQLite schema for the `sequences` table, including column details and constraints.

2. **[Typesense Synchronization for Central Sequence Service](../../Docs/Typesense%20Synchronization%20for%20Central%20Sequence%20Service.md)**  
   - Explains the indexing and synchronization process with Typesense, including retry mechanisms.

3. **[Critique of the Central Sequence Service OpenAPI v4](../../Docs/Critique%20of%20the%20Central%20Sequence%20Service%20OpenAPI%20v4.md)**  
   - Details the review process and justifications for updates in the current draft.

4. **[Swift OpenAPI Generator optimized Spec writing with Tags and OperationIDs](../../Docs/Swift%20OpenAPI%20Generator%20optimized%20Spec%20writing%20with%20Tags%20and%20OperationIDs.md)**  
   - Discusses the use of `operationId` and `tags` for better Swift server code generation.

5. **[Recommendations for Refactoring OpenAPI Specifications to Match a 300-Character Limit](../../Docs/Recommendations%20for%20Refactoring%20OpenAPI%20Specifications%20to%20Match%20a%20300-Character%20Limit.md)**  
   - Provides strategies for balancing machine readability and human usability in OpenAPI descriptions.

---

## Key Design Principles

### 1. **Clear and Concise Descriptions**
Descriptions are optimized for both human readability and machine processing, ensuring:
- Adherence to a 300-character limit for fields where applicable.
- Detailed implementation details moved to external documentation.

### 2. **Use of `operationId` and `tags`**
- Each endpoint is assigned a unique `operationId`, ensuring consistent function names in generated server/client code.
- Related operations are grouped under descriptive `tags` for better modularization.

### 3. **External Documentation References**
- Implementation-specific details (e.g., database schema, Typesense sync) are maintained separately to avoid cluttering the OpenAPI document.

---

## Implementation Workflow

1. **Review the OpenAPI Draft**
   - Familiarize yourself with the structure and content of the specification.
   - Access additional documentation for deeper insights into implementation.

2. **Setup SQLite and Typesense**
   - Use the database schema documentation to initialize the SQLite database.
   - Configure Typesense collections and sync logic based on the synchronization guide.

3. **Integrate with Server Code**
   - Use code generators (e.g., Apple’s Swift OpenAPI Generator) to produce server-side stubs.
   - Implement custom logic for each endpoint based on the external documentation.

4. **Validate and Test**
   - Ensure the API conforms to the specification by running automated tests.
   - Verify that the database and Typesense interactions work as expected.

---

## Conclusion

This OpenAPI draft is the first resource for implementing the Central Sequence Service. It balances clarity, usability, and extensibility by integrating structured descriptions, external documentation references, and a streamlined API design. Refer to the supporting documentation for detailed implementation steps and insights.

