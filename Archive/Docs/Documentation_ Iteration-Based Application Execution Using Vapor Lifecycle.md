# **Documentation: Lifecycle-Based Iteration Execution in Vapor**

## **Introduction**
This document describes the approach for implementing iteration-based application logic in Vapor using the `LifecycleHandler` mechanism. This method replaces the earlier command-based strategy and ensures seamless integration with Vapor's lifecycle while maintaining clarity and scalability.

## **Motivation**
The previous command-based approach encountered challenges:
- Conflicts with Vapor’s internal command handling.
- Complexity in managing custom commands and their integration with Vapor’s lifecycle.

The lifecycle-based approach leverages Vapor’s `LifecycleHandler` to:
1. Cleanly manage iteration-specific logic.
2. Align with Vapor’s lifecycle architecture.
3. Simplify the process of adding new iterations.

---

## **Key Components**

### **1. IterationLifecycleHandler**
The `IterationLifecycleHandler` is a custom implementation of Vapor’s `LifecycleHandler` that orchestrates the execution of iteration-specific logic during the application's lifecycle.

- **Responsibilities:**
  - Determine the iteration to execute based on input (e.g., command-line arguments).
  - Invoke the corresponding iteration logic.

- **Location:**
  ```
  Sources/IterationLifecycle/IterationLifecycleHandler.swift
  ```

- **Implementation:**
  ```swift
  import Vapor

  /// A lifecycle handler for managing iteration-specific app logic.
  class IterationLifecycleHandler: LifecycleHandler {
      private let iteration: String

      init(iteration: String) {
          self.iteration = iteration
      }

      func didBoot(_ application: Application) throws {
          print("Starting Iteration \(iteration) Lifecycle...")
          
          switch iteration {
          case "1":
              iteration_1(app: application)
          case "2":
              iteration_2(app: application)
          default:
              print("Unknown iteration: \(iteration)")
              throw Abort(.badRequest, reason: "Unknown iteration.")
          }
      }
  }
  ```

### **2. Iteration-Specific Files**
Each iteration is implemented in a separate file, encapsulating the logic for that iteration. These files define the routes, middleware, or other application-specific logic for the iteration.

- **Location:**
  ```
  Sources/Iterations/iteration_1.swift
  ```

- **Example Implementation:**
  ```swift
  import Vapor

  /// Logic for Iteration 1
  func iteration_1(app: Application) {
      app.get("health") { req -> String in
          return "Server is healthy!"
      }
      print("Iteration 1: Health check route is active.")
  }
  ```

### **3. Main Entry Point**
The `main.swift` file initializes the application and registers the `IterationLifecycleHandler` to manage the iteration logic.

- **Location:**
  ```
  Sources/main.swift
  ```

- **Implementation:**
  ```swift
  import Vapor

  do {
      // Parse command-line arguments
      let iterationArgument = CommandLine.arguments.dropFirst().first ?? ""
      
      // Initialize Vapor application
      let app = Application(.detect())
      defer { app.shutdown() }

      // Register the Iteration Lifecycle Handler
      app.lifecycle.use(IterationLifecycleHandler(iteration: iterationArgument))

      // Run the application
      try app.run()
  } catch {
      print("Critical error in application lifecycle: \(error.localizedDescription)")
      exit(1)
  }
  ```

---

## **Directory Structure**
```
Sources/
├── IterationLifecycle/
│   └── IterationLifecycleHandler.swift
├── Iterations/
│   └── iteration_1.swift
└── main.swift
```

---

## **Workflow**
### **Step 1: Define Iterations**
Each iteration is implemented in its respective file under the `Sources/Iterations/` directory. For example:
- `iteration_1.swift` for Iteration 1.
- `iteration_2.swift` for Iteration 2.

### **Step 2: Register Lifecycle Handler**
The `IterationLifecycleHandler` is registered in `main.swift` using `app.lifecycle.use`, ensuring it is invoked during the application lifecycle.

### **Step 3: Execute Iterations**
Run the application with the desired iteration as a command-line argument:
```bash
swift run CentralSequenceService 1
```
This executes the logic defined in `iteration_1.swift`.

---

## **Advantages**
1. **Separation of Concerns:**
   - Iteration-specific logic is isolated in individual files.
   - Lifecycle management is centralized in the `IterationLifecycleHandler`.

2. **Extensibility:**
   - New iterations can be added by creating new files and extending the `switch` statement in the handler.

3. **Alignment with Vapor:**
   - Uses Vapor’s `LifecycleHandler`, ensuring compatibility with its architecture.

---

## **Conclusion**
This lifecycle-based approach simplifies the implementation of iteration-based application logic while adhering to Vapor’s design principles. By leveraging `LifecycleHandler`, it ensures a scalable, maintainable, and extensible solution for OpenAPI-driven development.

