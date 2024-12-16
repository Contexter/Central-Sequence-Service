# **Documentation: Iteration-Based Application Execution Using Vapor Lifecycle**

## **Introduction**
This documentation outlines a structured approach to implement iteration-based application execution in a Vapor-based server using the framework’s lifecycle management features. The solution leverages Vapor’s `LifecycleHandler` to configure and run distinct application behaviors ("iterations") based on runtime arguments. Each iteration represents a specific feature set, aligning with OpenAPI-driven development principles.

This method avoids conflicts with Vapor’s default commands, preserves the core lifecycle, and provides a modular, extensible architecture for managing iterations.

---

## **Project Structure**
The relevant files and their locations in the project tree are as follows:

```
CentralSequenceService/
├── Sources/
│   ├── App/
│   │   ├── Lifecycle/
│   │   │   ├── IterationLifecycle.swift
│   │   ├── main.swift
│   │   ├── Iterations/
│   │   │   ├── Iteration1.swift
│   │   │   ├── Iteration2.swift
```

---

## **Implementation Details**

### **1. Lifecycle Handler**
**File Path**: `Sources/App/Lifecycle/IterationLifecycle.swift`

The `IterationLifecycle` struct implements Vapor’s `LifecycleHandler` protocol to configure the application based on the selected iteration:

```swift
import Vapor

/// A Lifecycle handler that configures the application based on the iteration.
struct IterationLifecycle: LifecycleHandler {
    let iteration: String

    func didBoot(_ application: Application) throws {
        switch iteration {
        case "1":
            application.logger.info("Running Iteration 1")
            configureIteration1(application)
        case "2":
            application.logger.info("Running Iteration 2")
            configureIteration2(application)
        default:
            application.logger.warning("Unknown iteration: \(iteration)")
        }
    }

    private func configureIteration1(_ app: Application) {
        app.get("health") { req -> String in
            return "Iteration 1: Server is healthy!"
        }
    }

    private func configureIteration2(_ app: Application) {
        app.get("status") { req -> String in
            return "Iteration 2: Server is running smoothly!"
        }
    }
}
```

### **2. Iteration 1 Configuration**
**File Path**: `Sources/App/Iterations/Iteration1.swift`

```swift
import Vapor

/// Defines the configuration for Iteration 1.
func configureIteration1(_ app: Application) {
    app.get("health") { req -> String in
        return "Iteration 1: Server is healthy!"
    }
}
```

### **3. Iteration 2 Configuration**
**File Path**: `Sources/App/Iterations/Iteration2.swift`

```swift
import Vapor

/// Defines the configuration for Iteration 2.
func configureIteration2(_ app: Application) {
    app.get("status") { req -> String in
        return "Iteration 2: Server is running smoothly!"
    }
}
```

### **4. Main Entry Point**
**File Path**: `Sources/App/main.swift`

```swift
import Vapor

@main
struct App {
    static func main() throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        let app = Application(env)
        defer { app.shutdown() }

        // Detect the iteration from environment arguments
        let iteration = env.arguments.first(where: { $0.hasPrefix("iteration=") })?.split(separator: "=").last ?? "default"

        // Attach the IterationLifecycle handler
        app.lifecycle.use(IterationLifecycle(iteration: String(iteration)))

        // Run the app
        try app.run()
    }
}
```

---

## **How to Run**

### Example 1: Running Iteration 1
```bash
swift run CentralSequenceService iteration=1
```

- The server will load and register the `health` route for **Iteration 1**.
- Open a browser or run:
  ```bash
  curl http://localhost:8080/health
  ```

### Example 2: Running Iteration 2
```bash
swift run CentralSequenceService iteration=2
```

- The server will load and register the `status` route for **Iteration 2**.
- Open a browser or run:
  ```bash
  curl http://localhost:8080/status
  ```

---

## **Extending to New Iterations**
To add a new iteration:
1. Create a new file in the `Sources/App/Iterations/` directory.
2. Define the iteration logic (e.g., `configureIteration3`).
3. Update the `IterationLifecycle`'s `didBoot` method to include the new iteration.

For example, for **Iteration 3**:
- Add a new file: `Sources/App/Iterations/Iteration3.swift`
- Update `IterationLifecycle.swift`:
  ```swift
  case "3":
      application.logger.info("Running Iteration 3")
      configureIteration3(application)
  ```

---

## **Advantages**
1. **Aligns with Vapor’s Lifecycle**:
   - Hooks directly into Vapor’s lifecycle (`LifecycleHandler`).
2. **Clear Iteration Structure**:
   - Each iteration is isolated in its own file for modularity.
3. **Scalable**:
   - Adding or modifying iterations doesn’t affect the core logic.
4. **No Command Conflicts**:
   - Avoids overriding Vapor commands or CLI logic.

---

## **Conclusion**
This approach provides a robust and scalable way to execute iteration-based application logic in Vapor. By leveraging the `LifecycleHandler` protocol, the implementation ensures seamless integration with Vapor’s lifecycle, clear separation of iterations, and extensibility for future enhancements.

