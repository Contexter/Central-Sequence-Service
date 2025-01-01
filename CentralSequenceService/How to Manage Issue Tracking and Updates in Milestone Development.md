# How to Manage Issue Tracking and Updates in Milestone Development

## Purpose

This guide provides a structured approach for managing issue tracking and updates during the development process, ensuring clear documentation of progress, task completion, and traceability.

---

## **Best Practices for Issue Tracking and Updates**

### **1. Add Progress Updates as Comments**

- Use comments to **log incremental updates** for each task within the issue.
- Clearly mention:
  - What has been completed.
  - What is still pending.
  - Any blockers or decisions made.

**Example Comment:**

```
Completed API Key Middleware implementation.
Commit reference: 123abc.
Pending: Final integration testing.
```

---

### **2. Maintain the Checklist in the Issue Description**

- **Edit the issue description** to **update checkboxes** (✅) and **reflect progress**.
- Keeps the main issue summary clean, providing readers with an **at-a-glance status**.

**Checklist Example:**

```
- [x] Implement API Key Middleware
- [ ] Test and verify endpoint behaviors against OpenAPI contract
- [ ] Implement error handling for invalid API keys and request formats
```

---

### **3. Reference Commits**

- Include commit references in comments for traceability.
- Provide context about what was implemented in the commit.

**Example Comment:**

```
Commit 123abc resolves implementation of API Key Middleware.
Updated related tests for validation.
```

---

### **4. Use Labels or Milestones**

- Ensure the issue is linked to **Milestone 1** and labeled appropriately (e.g., `In Progress`, `Blocked`, `Ready for Review`).
- This helps visualize the **status in GitHub project boards**.

**Label Examples:**

- `In Progress`
- `Blocked`
- `Ready for Review`

---

### **5. Subtasks as Issues**

#### **Why Use Subtasks as Separate Issues?**

- **Granularity and Focus**: Tasks are easier to track when each issue addresses **one clear objective**.
- **Traceability**: Commits and pull requests can be linked directly to smaller issues.
- **Parallel Workflows**: Teams can work on multiple issues in parallel without bottlenecks.
- **Clear Reporting**: Each issue has its own status updates, reducing clutter in the parent milestone.
- **Flexibility**: Tasks requiring extra effort can evolve without disrupting the milestone.

#### **Best Practices for Subtasks:**

1. **Link Subtasks to Parent Issue**
   - Reference the parent milestone or issue in the subtask description.
   - Example:
     ```
     This issue is part of Milestone 1 (#23).
     ```

2. **Update Parent Issue Checklist**
   - Mark subtasks as complete in the parent issue once closed.

3. **Keep Parent Issue Open Until All Tasks Are Done**
   - Only close the milestone when all subtasks are resolved.

---

### **6. Converting Tasks into Issues (Recommended Practice)**

#### **Why Convert Tasks into Issues?**

- GitHub offers a **built-in feature** to convert tasks into issues, which simplifies tracking.
- Provides **dedicated space for discussions**, status updates, and commit references.
- Allows **parallel progress** without losing focus on the parent issue.

#### **Steps to Convert Tasks into Issues:**

1. Go to the **parent issue's checklist**.
2. Click the **task you want to convert**.
3. Select **"Convert to Issue"** from the options.
4. Add the necessary description and link it back to the **parent issue**.
5. Update the parent issue's checklist to reflect the new issue link.

**Example Checklist Update:**
```
- [x] Refactor API key middleware to align with Vapor's middleware protocols. (#28)
- [ ] Test and verify endpoint behaviors against OpenAPI contract
```

---

### **7. Close Issue Only When Fully Completed**

- Leave the issue open until all tasks in the checklist are complete.
- Add a **final comment summarizing completion** before closing.

**Final Comment Example:**

```
All tasks under Milestone 1 have been completed and tested.
Commit references: 123abc, 456def.
Issue closed.
```

---

## Example in CSS Development

## **Next Steps for Current Issue (#23):**

1. **Add a comment** to issue #23 describing:

   - The completion of the API Key Middleware implementation.
   - The reference to the commit ID.
   - The next steps in the checklist.

2. **Update the checklist** in the issue description:

   - Mark the **API Key Middleware task as complete** (checked).

3. **Keep the issue open** and continue tracking pending tasks in comments.

---

## Example in Action

### Issue #23 - "Milestone 1: Route Definitions and Middleware"

**Checklist Update Example:**

```
- [x] Define and implement route definitions
- [x] Create API key middleware for authentication (#28)
- [ ] Test and verify endpoint behaviors against OpenAPI contract
- [ ] Implement error handling for invalid API keys and request formats
```

**Comment Example:**

```
API Key Middleware implemented and validated.
Commit reference: abc123.
Next steps: Test endpoint behaviors and implement error handling.
```

---

## Conclusion

Following these structured practices for issue tracking ensures:

- Clear communication of progress.
- Traceability through commit references.
- Organized milestone management with updated checklists.
- Effective handling of subtasks via dedicated issues.

Keep iterating based on this approach to efficiently manage development milestones.

