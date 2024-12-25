# Iteration 7 - Backup and Migration Plan

## **1. Backup the Current Main Branch**

### **Step 1: Create a New Branch for Backup**
```bash
git checkout main
git pull origin main
git checkout -b backup-main-iteration6
git push origin backup-main-iteration6
```
This ensures the current state is stored in a dedicated backup branch, **`backup-main-iteration6`**, representing the completion of the **6th iteration**.

---

## **2. Archive and Document Existing Iterations**

### **Step 2: Create an Archive Folder**
Add a directory called **`Archive/`** at the root of the repository to store old iterations.
```bash
mkdir Archive
mv CentralSequenceService/Sources/Iterations Archive/
mv CentralSequenceService/Sources/Handlers Archive/
mv Docs Archive/
```

### **Step 3: Commit and Push Archive Changes**
```bash
git add Archive/
git commit -m "Archived existing iterations and handlers to prepare for Iteration 7"
git push origin main
```

---

## **3. Evaluate Files to Keep or Modify**

### **Keep the Following:**

1. **Infrastructure and Configuration Files:**
   - `Package.swift`: Retain dependencies and update it incrementally for new requirements.  
   - `configure.swift`: Maintain application configuration logic.  
   - `.gitignore`: Keep existing ignore rules.  
   - `openapi.yaml`: Treat this as the **contract source of truth** for compliance.  
   - `openapi-generator-config.yaml`: Retain for code generation.  

2. **Migrations and Database Schema Files:**
   - `Migrations/` – Archive old migrations but keep the schema structure for updates.

3. **Shared State and Utilities:**
   - `Shared/State.swift`: Preserve reusable logic related to global state management.  

4. **Generated Code:**
   - `GeneratedCode/` (Server.swift, Types.swift): Move these to **`Generated/`** to maintain separation.

5. **Docs Folder:**
   - Retain documentation but archive old iteration-specific documents.

---

### **Replace or Reorganize:**

1. **Handlers and Routes:**
   - Move older handlers to **`Archive/`** and rewrite them incrementally.  
   - Replace older logic with **modular services** under the new `Services/` directory.  

2. **Iterations Folder:**
   - Archive older iterations in **`Archive/Iterations`** for reference.  
   - Start **Iteration 7** as a **clean slate**.

3. **Testing:**
   - Archive previous tests and define new unit and integration tests aligned with **Iteration 7 goals**.

---

## **4. Prepare New Iteration Structure**

### **New Folder Structure:**
```
CentralSequenceService/
├── Generated/            # New location for generated code
│   ├── Server.swift
│   ├── Types.swift
├── Sources/
│   ├── configure.swift
│   ├── main.swift
│   ├── Routes/
│   │   ├── APIImplementation.swift  # Moved here as it orchestrates API routing logic
│   ├── Handlers/
│   ├── Services/
│   │   ├── placeholder.swift        # Placeholder to keep directory in version control
│   ├── Models/
│   ├── Migrations/
│   ├── openapi.yaml
│   ├── openapi-generator-config.yaml
├── Archive/
│   ├── Iterations/
│   ├── Handlers/
│   ├── Docs/
├── Tests/
│   ├── placeholder.txt             # Placeholder to keep directory in version control
└── README.md
```

---

## **5. Push Changes and Start Iteration 7**

1. **Commit New Structure:**  
```bash
git add .
git commit -m "Prepared project tree for Iteration 7 with archived previous iterations"
git push origin main
```

2. **Create an Iteration 7 Branch:**  
```bash
git checkout -b iteration7
git push origin iteration7
```

---

## **6. Define Goals for Iteration 7**

- **Meta Prompt Implementation:** Begin with the meta prompt framework discussed earlier.  
- **Incremental Testing:** Set up test scaffolding to validate new logic progressively.  
- **Typesense Integration:** Introduce Typesense components based on new requirements.  
- **Error Handling Enhancements:** Develop middleware for improved error handling.  

---

## **Next Steps:**
1. Confirm the above backup and migration plan.  
2. Discuss the specific goals for Iteration 7, focusing on modularity and compliance.  
3. Proceed with incremental implementation starting with **package setup** and **generated code integration**.

