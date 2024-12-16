# **Documentation: Custom Command Strategy for Iteration-Based Execution in Vapor**

## **Introduction**
The iteration-based execution strategy in the Central Sequence Service leverages Vapor’s extensible command system to support modular and flexible application behavior. This milestone introduces a custom command, `RunIterationCommand`, that allows the server to execute specific iterations without interfering with Vapor’s default lifecycle commands (`serve`, `routes`, etc.).

This approach ensures:
- Separation of iteration logic from Vapor’s core lifecycle.
- Robust handling of custom arguments without causing conflicts.
- A clean and extensible architecture for iteration-based development.

---

## **Vapor’s Default Command System**

Vapor comes with a built-in **Command Lifecycle** that supports several default commands:
- **`serve`**: Starts the Vapor HTTP server and listens for requests on the configured port.
- **`routes`**: Displays a list of all registered routes in the application.
- **`help`**: Lists all available commands and their descriptions.

These commands provide a structured way to control the application during runtime. By extending this system with custom commands, developers can introduce new functionalities while preserving the core command behaviors.

---

## **Command Strategy Overview**
### **Why Custom Commands?**
By default, Vapor provides standard commands like `serve` and `routes`. However, when introducing custom arguments (e.g., `--run-iteration`), these can conflict with Vapor’s internal command parser, resulting in warnings like `unknownCommand`. To address this, we define a custom command that:

1. Parses and validates iteration-specific arguments.
2. Executes iteration logic in a modular and isolated manner.
3. Uses Vapor’s HTTP server lifecycle seamlessly.

---

### **Key Components**
The custom command strategy comprises the following components:

#### **1. RunIterationCommand**
This struct implements Vapor’s `Command` protocol and defines the logic for executing iterations.

- **Location**: `Sources/Commands/RunIterationCommand.swift`
- **Responsibilities**:
  - Parse and validate the `iteration` argument.
  - Invoke the appropriate iteration function (e.g., `iteration_1`).
  - Ensure the Vapor HTTP server starts and operates normally.

#### **2. Iteration Logic**
Each iteration is defined as a standalone function that:
- Configures the Vapor application (e.g., routes, middleware).
- Is invoked explicitly by the `RunIterationCommand`.

- **Location**: `Sources/Iterations/`
- **Example**:
  ```swift
  func iteration_1(app: Application) {
      app.get("health") { req -> String in
          return "Server is healthy!"
      }
      print("Iteration 1: Health check route is active.")
  }
  ```

#### **3. Final Main File**
The `main.swift` file registers the `RunIterationCommand` and ensures it is available for execution.

- **Final Content of main.swift**:
  ```swift
  import Vapor

  do {
      var env = Environment.custom(
          arguments: CommandLine.arguments,
          environment: .detect()
      )
      try LoggingSystem.bootstrap(from: &env)

      let app = Application(env)
      defer { app.shutdown() }

      // Register the custom command
      app.commands.use(RunIterationCommand(), as: "run-iteration")

      try app.run()
  } catch {
      print("Failed to start application: \(error.localizedDescription)")
      exit(1)
  }
  ```

---

## **Implementation Steps**
### **1. Create the Custom Command**
Define the `RunIterationCommand` in a new file:

- **File**: `Sources/Commands/RunIterationCommand.swift`
- **Code**:
  ```swift
  import Vapor

  struct RunIterationCommand: Command {
      struct Signature: CommandSignature {
          @Argument(name: "iteration")
          var iteration: String
      }

      let help = "Run a specific iteration of the application."

      func run(using context: CommandContext, signature: Signature) throws {
          let app = Application(.detect())
          defer { app.shutdown() }

          switch signature.iteration {
          case "1":
              print("Running iteration 1...")
              iteration_1(app: app)
          default:
              print("Error: Unknown iteration \(signature.iteration)")
              throw Abort(.badRequest, reason: "Unknown iteration.")
          }

          try app.run()
      }
  }
  ```

### **2. Add Iteration Logic**
Each iteration is implemented as a separate function in the `Sources/Iterations/` directory:

- **File**: `Sources/Iterations/iteration_1.swift`
- **Code**:
  ```swift
  import Vapor

  func iteration_1(app: Application) {
      app.get("health") { req -> String in
          return "Server is healthy!"
      }
      print("Iteration 1: Health check route is active.")
  }
  ```

---

## **Adding More Commands**
The system is designed to be extensible. You can add more commands to handle additional application behaviors beyond iterations.

### **Example: Adding a Feature Command**
To support feature-based commands, follow these steps:

#### **1. Create a New Command**
- **File**: `Sources/Commands/RunFeatureCommand.swift`
- **Code**:
  ```swift
  import Vapor

  struct RunFeatureCommand: Command {
      struct Signature: CommandSignature {
          @Argument(name: "feature")
          var feature: String
      }

      let help = "Run a specific feature of the application."

      func run(using context: CommandContext, signature: Signature) throws {
          let app = Application(.detect())
          defer { app.shutdown() }

          switch signature.feature {
          case "example":
              print("Running example feature...")
              // Add feature-specific logic here
          default:
              print("Error: Unknown feature \(signature.feature)")
              throw Abort(.badRequest, reason: "Unknown feature.")
          }

          try app.run()
      }
  }
  ```

#### **2. Register the New Command in Main**
Add the new command to `main.swift`:
  ```swift
  app.commands.use(RunIterationCommand(), as: "run-iteration")
  app.commands.use(RunFeatureCommand(), as: "run-feature")
  ```

#### **3. Test the New Command**
- Build and run:
  ```bash
  swift run CentralSequenceService run-feature example
  ```

- **Expected Output**:
  ```
  Running example feature...
  Server starting on http://127.0.0.1:8080
  ```

---

## **Usage**
### **Running an Iteration**
To execute a specific iteration, use the following command:
```bash
swift run CentralSequenceService run-iteration <iteration-number>
```

### **Running a Feature Command**
To execute a feature command:
```bash
swift run CentralSequenceService run-feature <feature-name>
```

---

## **Advantages**
1. **Modular and Scalable**:
   - Iterations and commands are isolated, simplifying testing and development.
   - New commands or iterations can be added without impacting existing functionality.

2. **Conflict-Free Argument Handling**:
   - Custom arguments (e.g., `run-iteration`, `run-feature`) are handled independently of Vapor’s core commands.

3. **Extensible Architecture**:
   - Supports additional commands for debugging, feature toggles, or administrative tasks.

---

## **Conclusion**
The `RunIterationCommand` represents a significant milestone in the Central Sequence Service architecture. By integrating custom commands with Vapor’s lifecycle, this strategy offers a robust, modular, and scalable approach to iteration-based execution. It resolves command conflicts, simplifies testing, and aligns with best practices for modern Swift application development.

This foundation paves the way for future iterations and enhancements, ensuring a seamless development experience.

