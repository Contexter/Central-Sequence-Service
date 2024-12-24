# FountainAI Documentation: Central Sequence Service

---

## Table of Contents
1. [Overview of FountainAI](#1-overview-of-fountainai)
2. [Central Sequence Service](#2-central-sequence-service)
   - [2.1 Purpose](#21-purpose)
   - [2.2 Predefined Components CSS Enforces](#22-predefined-components-css-enforces)
   - [2.3 Components CSS Can Track](#23-components-css-can-track)
3. [Key Functions](#3-key-functions)
   - [3.1 Sequence Number Management](#31-sequence-number-management)
   - [3.2 Typesense Integration](#32-typesense-integration)
   - [3.3 Scalability and Synchronization](#33-scalability-and-synchronization)
   - [3.4 Optimistic Concurrency Control (OCC)](#34-optimistic-concurrency-control-occ)
   - [3.5 Error Handling and Recovery](#35-error-handling-and-recovery)
4. [Practical Use Cases in FountainAI](#4-practical-use-cases-in-fountainai)
5. [Conclusion](#5-conclusion)

---

## 1. Overview of FountainAI
FountainAI is a modular and scalable framework designed to power **narrative-driven workflows**, **collaborative editing**, and **interactive storytelling systems**. It leverages modern technologies like **Swift Vapor** and **Typesense** to provide seamless integration between **API-driven microservices**.

This documentation focuses on the **Central Sequence Service (CSS)**, a core component of FountainAI, responsible for **sequence management**, **versioning**, and **synchronization** across distributed systems.

---

## 2. Central Sequence Service

### 2.1 Purpose
The **Central Sequence Service (CSS)** is designed to be **component-agnostic**. While it enforces strict **sequence ordering** and **versioning** for predefined components, it also supports **tracking any component** as long as it adheres to the required schema defined in the **OpenAPI contract**. This makes CSS **extensible** and capable of adapting to evolving requirements.

### 2.2 Predefined Components CSS Enforces:
- **Scripts** - Represents overarching narrative structures.
- **Sections** - Subdivisions within scripts, such as scenes or chapters.
- **Actions** - Individual actions or events within sections.
- **Versions** - Historical snapshots of scripts, sections, or actions, enabling rollback and auditing.

### 2.3 Components CSS Can Track:
- **Contexts** - Metadata defining relationships between story elements, ensuring context-aware processing.
- **Performers** - Entities responsible for enacting scripts or actions.
- **Paraphrases** - Variations in text or dialogues that map to actions or scripts, providing narrative flexibility.
- **Spoken Words** - Dialogue content tied to actions and scripts, facilitating narrative and character interactions.
- **Custom Elements** - Any other user-defined component types, provided they include valid fields such as `elementType`, `elementId`, and `sequenceNumber`.

This flexibility ensures that CSS can evolve alongside FountainAI without requiring core architectural changes.

---

## 3. Key Functions

### 3.1 Sequence Number Management
**Purpose:**  
- Ensures every element in the system (scripts, sections, actions) has a **unique and ordered sequence number**.

**Key Operations:**  
1. **Generate Sequence Numbers (POST /sequence):**  
   - Creates a **new sequence number** for an element type (e.g., script, section).  
   - Synchronizes the sequence number with **Typesense** for indexing and search.  
   - Tracks comments to capture **context and reasons** for sequence generation.

2. **Reorder Sequences (PUT /sequence/reorder):**  
   - Updates the **ordering** of elements when changes occur (e.g., reordering actions in a script).  
   - Ensures the changes are **atomic** and **consistent** across the system.  
   - Synchronizes updates with **Typesense** for **fast retrieval and searchability**.

3. **Version Control (POST /sequence/version):**  
   - Creates **new versions** of elements while preserving old versions.  
   - Allows for **rollback** and **change tracking** to maintain **auditability**.  
   - Synchronizes new versions with **Typesense** for **history tracking**.

---

### 3.2 Typesense Integration
**Purpose:**  
- Ensures **fast, typo-tolerant search capabilities** for sequence numbers and versions.  
- Provides **instant synchronization** between database updates and the Typesense search index.  

**Use Cases:**
- Quickly locate an element by its **ID or sequence number**.
- Perform **search queries** based on metadata like comments or descriptions.
- Handle **fault-tolerant lookups** to improve user experience in dynamic workflows.

---

### 3.3 Scalability and Synchronization
**Purpose:**  
- Supports **distributed systems** by maintaining **order consistency** across multiple services in FountainAI.  
- Guarantees synchronization with the **Typesense index** even in cases of **failures or retries**.

**Features:**
- **Atomic Updates:** Prevents conflicts during simultaneous updates by grouping multiple operations into a single **database transaction**.
- **Sequence Locking:** Implements **optimistic concurrency control** to validate sequence numbers before applying updates.
- **Validation Checks:** Ensures all inputs conform to **OpenAPI schemas** before execution.

---

### 3.4 Optimistic Concurrency Control (OCC)
**Purpose:**
- Ensures **atomicity** by validating data consistency without using locks.

**Steps:**
1. **Read Phase:** Retrieve the current state of data.
2. **Validation Phase:** Check if data has changed since reading; reject updates if inconsistencies are detected.
3. **Write Phase:** Commit updates only if validation passes.

**Benefits:**
- Avoids locks, improving scalability.
- Prevents race conditions through version checks.
- Ensures consistency across distributed systems.

---

### 3.5 Error Handling and Recovery
**Purpose:**
- Handles errors gracefully to ensure data integrity and synchronization.

**Key Mechanisms:**
- **Validation Errors (400):** Immediate feedback for invalid requests.
- **Synchronization Errors (502):** Retries updates until consistency with Typesense is restored.
- **Server Errors (500):** Logs and reports unexpected failures.

**Benefits:**
- Ensures robustness even under failure scenarios.
- Enables debugging through detailed error logs.

---

## 4. Practical Use Cases in FountainAI
- **Story and Script Management:** Maintain sequences for narrative structures and support API-driven workflows for consistency.
- **Live Collaboration and Editing:** Enable multiple users to edit scripts concurrently while preserving ordering and consistency.
- **Interactive Storytelling Systems:** Dynamically reorder sequences based on audience inputs and experimental changes.
- **Content Versioning for Media Production:** Track and manage script iterations during development and production phases.
- **Search-Driven Applications:** Provide instant, typo-tolerant lookups and metadata filtering using Typesense integration.

---

## 5. Conclusion
The **Central Sequence Service (CSS)** forms the backbone of FountainAI's **scalable and modular architecture**. By enforcing **sequence consistency**, supporting **atomic updates**, and leveraging **Typesense integration**, it ensures robust **synchronization** and **version control** for distributed systems.

