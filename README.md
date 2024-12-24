# FountainAI Documentation: Central Sequence Service

---

## **1. Overview of FountainAI**
FountainAI is a modular and scalable framework designed to power **narrative-driven workflows**, **collaborative editing**, and **interactive storytelling systems**. It leverages modern technologies like **Swift Vapor** and **Typesense** to provide seamless integration between **API-driven microservices**.

This documentation focuses on the **Central Sequence Service (CSS)**, a core component of FountainAI, responsible for **sequence management**, **versioning**, and **synchronization** across distributed systems.

---

## **2. Central Sequence Service**

### **Purpose**
The **Central Sequence Service (CSS)** is designed to be **component-agnostic**. While it enforces strict **sequence ordering** and **versioning** for predefined components, it also supports **tracking any component** as long as it adheres to the required schema defined in the **OpenAPI contract**. This makes CSS **extensible** and capable of adapting to evolving requirements.

### **Predefined Components CSS Enforces:**
- **Scripts** - Represents overarching narrative structures.
- **Sections** - Subdivisions within scripts, such as scenes or chapters.
- **Actions** - Individual actions or events within sections.
- **Versions** - Historical snapshots of scripts, sections, or actions, enabling rollback and auditing.

### **Components CSS Can Track:**
- **Contexts** - Metadata defining relationships between story elements, ensuring context-aware processing.
- **Performers** - Entities responsible for enacting scripts or actions.
- **Paraphrases** - Variations in text or dialogues that map to actions or scripts, providing narrative flexibility.
- **Spoken Words** - Dialogue content tied to actions and scripts, facilitating narrative and character interactions.
- **Custom Elements** - Any other user-defined component types, provided they include valid fields such as `elementType`, `elementId`, and `sequenceNumber`.

This flexibility ensures that CSS can evolve alongside FountainAI without requiring core architectural changes.

---

## **3. Key Functions**

### **1. Sequence Number Management**
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

### **2. Typesense Integration**
**Purpose:**  
- Ensures **fast, typo-tolerant search capabilities** for sequence numbers and versions.  
- Provides **instant synchronization** between database updates and the Typesense search index.  

**Use Cases:**
- Quickly locate an element by its **ID or sequence number**.
- Perform **search queries** based on metadata like comments or descriptions.
- Handle **fault-tolerant lookups** to improve user experience in dynamic workflows.

---

### **3. Scalability and Synchronization**
**Purpose:**  
- Supports **distributed systems** by maintaining **order consistency** across multiple services in FountainAI.  
- Guarantees synchronization with the **Typesense index** even in cases of **failures or retries**.

**Features:**
- **Atomic Updates:** Prevents conflicts during simultaneous updates.  
- **Retry Mechanism:** Ensures failed synchronization attempts with Typesense are retried automatically.  
- **Error Handling:** Provides detailed error responses for failures (e.g., 502 for Typesense sync errors).  

---

### **4. Version Control and Auditability**
**Purpose:**  
- Maintains **historical records** for tracking changes.  
- Allows **rollback** to previous versions for audit purposes.  

**Scenarios:**
- **Story Edits:** Track how scripts or sections evolve over time.  
- **Collaboration Logs:** Record who made changes and why (via comments).  
- **Recovery Options:** Roll back to previous states if errors occur.

---

### **5. Error Handling and Recovery**
**Purpose:**  
- Handles synchronization failures with **Typesense** gracefully.  
- Provides structured **error responses** for debugging (e.g., error codes, retry counts).  

**Key Error Types:**
- **400:** Invalid input validation errors.  
- **502:** Failed Typesense synchronization.  
- **500:** Internal server errors.  

**Benefit:**  
- Ensures robustness in **distributed and concurrent workflows**.

---

## **4. Practical Use Cases in FountainAI**

1. **Story and Script Management:**  
   - Maintain order of scripts, sections, and actions in multi-scene narratives.  
   - Provide quick search access to elements via Typesense integration.  

2. **Live Collaboration and Editing:**  
   - Support multiple users editing scripts simultaneously without conflicts.  
   - Track changes and versions to avoid overwrites or data loss.  

3. **Interactive Storytelling Systems:**  
   - Dynamically reorder sequences based on audience interactions.  
   - Roll back versions to experiment with narrative changes.  

4. **Content Versioning for Media Production:**  
   - Manage iterations of scripts or drafts during pre-production and filming.  
   - Synchronize updates across teams working on different parts of a project.  

5. **Search-Driven Applications:**  
   - Provide fast lookups and autocomplete features using Typesense for large datasets.  
   - Support **fuzzy matching** and **filtering** for metadata-driven searches.

---

## **5. Why is the Central Sequence Service Critical?**

1. **Data Consistency and Order Enforcement:**  
   - Guarantees sequence consistency, ensuring scripts and actions remain **in sync** across workflows.  

2. **Scalable and Extensible:**  
   - Modular design allows adding **new element types** or **sequence workflows** without disrupting existing features.  

3. **Search-Optimized Architecture:**  
   - Leveraging **Typesense** enables **near-instant lookups**, ideal for fast-paced production environments.  

4. **Resilience and Fault Tolerance:**  
   - Retry mechanisms and structured error handling provide stability during synchronization failures.  

5. **Compliance with OpenAPI Standards:**  
   - Ensures interoperability with external systems and microservices by adhering to the **OpenAPI contract**.

---

## **6. Conclusion**
The **Central Sequence Service** serves as the **ordering and synchronization backbone** for FountainAI. Its integration with Typesense, support for versioning, and ability to maintain order consistency make it indispensable for **narrative-driven workflows**, **collaborative editing**, and **interactive storytelling**.

