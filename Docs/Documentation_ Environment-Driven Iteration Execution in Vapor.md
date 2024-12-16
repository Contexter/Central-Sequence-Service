# **Documentation: Environment-Driven Iteration Execution in Vapor**

## **Introduction**

This document outlines an alternative approach to implementing iteration-based execution in a Vapor application using **environment variables** and **command-line arguments**. This approach avoids extending Vapor’s command system or lifecycle handling, simplifying the process and adhering to Vapor’s default extensibility.

---

## **Motivation**

Previous attempts to implement iteration-based execution using commands and lifecycle handlers faced the following challenges:

- **Scope Issues**: Subcommands and lifecycle extensions encountered visibility problems.
- **Complexity**: Lifecycle handlers introduced non-trivial architectural overhead.
- **Vapor Constraints**: Overwriting Vapor’s defaults proved unreliable.

This environment-driven approach offers a straightforward alternative by leveraging runtime inputs (environment variables or command-line arguments) to execute the desired iteration logic without altering Vapor’s core systems.

---

## **Key Components**

### **1. Iteration Logic**
Each iteration’s specific logic is encapsulated in its own file under `Sources/Iterations`. This keeps the logic modular and maintainable.

#### **Example: Iteration 1 Logic**

**File: `Sources/Iterations/iteration_1.swift`**
```swift
import Vapor

/// Logic for Iteration 1
func iteration_1(app: Application) {
    app.get("health") { req -> String in
        return "Iteration 1: Server is healthy!"
    }
    print("Iteration 1 logic executed.")
}
```

#### **Example: Iteration 2 Logic**

**File: `Sources/Iterations/iteration_2.swift`**
```swift
import Vapor

/// Logic for Iteration 2
func iteration_2(app: Application) {
    app.get("health") { req -> String in
        return "Iteration 2: Server is healthy!"
    }
    print("Iteration 2 logic executed.")
}
```

---

### **2. Entry Point**

The `main.swift` file determines the desired iteration based on an environment variable or command-line argument and executes the corresponding logic.

#### **Implementation: Main Entry Point**

**File: `Sources/main.swift`**
```swift
import Vapor

// Entry Point

do {
    // Parse environment variable or command-line argument for iteration
    let iterationFlag = Environment.get("ITERATION") ?? CommandLine.arguments.dropFirst().first ?? "1"

    // Initialize the Vapor application
    let app = Application(.detect())
    defer { app.shutdown() }

    // Execute the iteration logic based on the flag
    switch iterationFlag {
    case "1":
        iteration_1(app: app)
    case "2":
        iteration_2(app: app)
    default:
        print("Unknown iteration: \(iterationFlag). Exiting.")
        exit(1)
    }

    // Run the Vapor application
    try app.run()
} catch {
    print("Critical error: \(error.localizedDescription)")
    exit(1)
}
```

---

## **Directory Structure**

The following structure organizes the application’s source files for clarity and scalability:

```
Sources/
├── Iterations/
│   ├── iteration_1.swift
│   ├── iteration_2.swift
├── main.swift
```

---

## **How It Works**

1. **Environment or Command-Line Input**:
   - The application first checks for the `ITERATION` environment variable.
   - If not found, it defaults to the first command-line argument.

2. **Iteration Selection**:
   - The `main.swift` file uses a `switch` statement to match the input and call the appropriate iteration logic.

3. **Iteration Logic Execution**:
   - The selected iteration’s logic is executed, registering routes or other functionality as needed.

4. **Run the Application**:
   - The Vapor application is launched with the registered iteration logic.

---

## **Usage**

### **Setting Environment Variables**

Run the application with an environment variable to specify the iteration:

```bash
ITERATION=2 swift run CentralSequenceService
```

### **Using Command-Line Arguments**

Alternatively, specify the iteration directly as a command-line argument:

```bash
swift run CentralSequenceService 2
```

---

## **Advantages**

1. **No Overwriting Vapor Defaults**:
   - The approach avoids extending or overwriting Vapor’s commands or lifecycle handlers.

2. **Modular Logic**:
   - Each iteration’s logic is encapsulated in its own file, ensuring maintainability.

3. **Simplicity**:
   - The solution relies on environment variables and command-line arguments, making it straightforward to implement and debug.

4. **Compatibility**:
   - Fully aligned with Vapor’s architecture and design principles.

---

## **Scalability**

This approach scales seamlessly:

- Add new iterations by creating new files in the `Iterations` directory.
- Update the `switch` statement in `main.swift` to include the new iteration.

For example, adding Iteration 3:

**File: `Sources/Iterations/iteration_3.swift`**
```swift
import Vapor

/// Logic for Iteration 3
func iteration_3(app: Application) {
    app.get("status") { req -> String in
        return "Iteration 3: All systems operational!"
    }
    print("Iteration 3 logic executed.")
}
```

Update the `main.swift` file:
```swift
switch iterationFlag {
case "1":
    iteration_1(app: app)
case "2":
    iteration_2(app: app)
case "3":
    iteration_3(app: app)
default:
    print("Unknown iteration: \(iterationFlag). Exiting.")
    exit(1)
}
```

---

## **Conclusion**

This environment-driven approach provides a simple, modular, and scalable solution for iteration-based execution in Vapor. By leveraging runtime inputs like environment variables and command-line arguments, it aligns with Vapor’s architectural principles and avoids the complexities of lifecycle or command extensions.

This method ensures maintainability and flexibility for future iteration-based application development.

