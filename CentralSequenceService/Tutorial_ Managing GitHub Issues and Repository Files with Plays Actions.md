# **Tutorial: Managing GitHub Issues and Repository Files with Play's Actions**

> "play" , is a Custom GPT, configured in OpenAI's custom GPT configurator 
>
>

This tutorial explains how to **create, fetch, and manage GitHub issues** and **interact with repository files** using Play's **configured actions**. It provides **step-by-step instructions** and **prompt examples** to make issue and file management accessible directly in your ChatGPT session.

---

## **1. Prerequisites**

- Ensure ChatGPT is connected to a **GitHub repository** via the **GraphQL API**.
- Verify access to the repository where issues and files will be managed.
- Repository example: `Contexter/Central-Sequence-Service`.

---

## **2. Creating Issues**

### **Prompt Example 1: Create a Basic Issue**

```
Create a GitHub issue in the repository 'Contexter/Central-Sequence-Service' with the title 'Bug Report: Login Failure' and the description 'Users cannot log in using OAuth. Returns 500 error.'
```

### **Prompt Example 2: Add a Milestone Issue**

```
Create a GitHub issue in the repository 'Contexter/Central-Sequence-Service' with the title 'Milestone 1: Implement Authentication Middleware' and the following description:

- Add APIKeyMiddleware to validate incoming requests.
- Test APIKeyMiddleware for handling errors.

Checklist:
- [ ] Middleware Added.
- [ ] Middleware Tested.

Outcome:
Secure API endpoints with middleware protection.
```

### **Prompt Example 3: Assign Labels**

```
Create a GitHub issue in 'Contexter/Central-Sequence-Service' titled 'Enhancement: Add Logging Middleware' with the label 'enhancement'. Include the description: 'Implement middleware for logging incoming and outgoing API requests.'
```

---

## **3. Fetching Issues**

### **Prompt Example 4: Get All Issues**
```
Fetch all issues from the repository 'Contexter/Central-Sequence-Service'.
```

### **Prompt Example 5: Search by Title**
```
Fetch all issues from the repository 'Contexter/Central-Sequence-Service' with titles containing 'Milestone'.
```

### **Prompt Example 6: Filter Open Issues**
```
Fetch all OPEN issues in the repository 'Contexter/Central-Sequence-Service'.
```

### **Prompt Example 7: Use Pagination**
```
Fetch the first 20 issues from 'Contexter/Central-Sequence-Service'. If more issues exist, fetch subsequent pages using the provided endCursor.
```

### **Prompt Example 8: Fetch Specific Issues by Title**
```
Fetch issues from 'Contexter/Central-Sequence-Service' with the title 'Milestone 1: Route Definitions and Middleware'.
```

---

## **4. Understanding Pagination and endCursor**

### **What is an endCursor?**
- The **endCursor** is a pointer used for **pagination** when fetching issues or data in batches.
- It acts like a bookmark to continue fetching results **after the current set**.

### **How to Retrieve endCursor?**

**Prompt Example 9: Fetch Issues with endCursor**
```
Fetch the first 20 issues from 'Contexter/Central-Sequence-Service'.
```
**Response Example:**
```json
{
  "data": {
    "repository": {
      "issues": {
        "edges": [
          { "node": { "title": "Issue 1" } },
          { "node": { "title": "Issue 2" } }
        ],
        "pageInfo": {
          "endCursor": "Y3Vyc29yOnYyOpK5MjAyNC0xMi0yOVQwNzowODowMyswMTowMM6koqAt",
          "hasNextPage": true
        }
      }
    }
  }
}
```

### **Using the endCursor for Pagination:**
If `hasNextPage` is **true**, fetch the next set of issues with this prompt:
```
Fetch the next 20 issues starting after this endCursor: Y3Vyc29yOnYyOpK5MjAyNC0xMi0yOVQwNzowODowMyswMTowMM6koqAt
```

### **Repeat Until Done:**
Continue fetching until `hasNextPage` is **false**.

---

## **5. Updating Issues**

### **Prompt Example 10: Update Issue Title**
```
Update the title of issue #10 in 'Contexter/Central-Sequence-Service' to 'Milestone 1: Implement Secure Middleware'.
```

### **Prompt Example 11: Update Issue Body**
```
Update the body of issue #12 in 'Contexter/Central-Sequence-Service' with the following:

- Refactor API routes for scalability.
- Test route handlers using XCTVapor.

Checklist:
- [ ] Routes Refactored.
- [ ] Tests Completed.
```

---

## **6. Repository File and Commit Management**

### **Prompt Example 12: Fetch Repository Tree**
```
Fetch the repository tree of 'Contexter/Central-Sequence-Service'.
```

### **Prompt Example 13: Fetch File Content**
```
Fetch the content of 'Sources/main.swift' from 'Contexter/Central-Sequence-Service'.
```

### **Prompt Example 14: Fetch Specific Lines in a File**
```
Fetch lines 10 to 20 from 'Sources/APIHandler.swift' in 'Contexter/Central-Sequence-Service'.
```

### **Prompt Example 15: Get Total Line Count in a File**
```
Get the total number of lines in 'Sources/APIHandler.swift' in 'Contexter/Central-Sequence-Service'.
```

### **Prompt Example 16: Fetch Commit History**
```
Fetch the 5 most recent commits from 'Contexter/Central-Sequence-Service'.
```

### **Prompt Example 17: Fetch Commits in Date Range**
```
Fetch commits from 'Contexter/Central-Sequence-Service' between 2024-01-01 and 2024-12-31.
```

---

## **7. Best Practices for Managing Issues and Files**

1. **Use Clear Titles:** Describe tasks or problems concisely.
2. **Add Labels:** Categorize issues as `bug`, `enhancement`, `documentation`, etc.
3. **Use Checklists:** Break tasks into smaller steps for better tracking.
4. **Add Milestones:** Group related issues under milestones for better organization.
5. **Track Progress:** Regularly update issue statuses and use comments to log updates.
6. **Close Completed Tasks:** Ensure issues are closed only after verification and testing.
7. **Fetch Specific File Sections:** Use line ranges to access code segments quickly.
8. **Monitor Changes with Commits:** Use commit history to track modifications.

---

## **8. Conclusion**

Using Play’s configured actions, you can efficiently manage GitHub issues and repository files—creating, fetching, and updating them directly in your session. The examples provided here serve as a guide for workflows ranging from defining milestones to fetching files and monitoring changes through commits.

