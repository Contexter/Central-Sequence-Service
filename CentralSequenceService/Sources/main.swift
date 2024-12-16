import Vapor
import IterationLifecycle

do {
    // Parse command-line arguments
    let iterationArgument = CommandLine.arguments.dropFirst().first ?? ""

    // Initialize Vapor application
    let app = try Application(.detect())
    defer { app.shutdown() }

    // Register the Iteration Lifecycle Handler
    app.lifecycle.use(IterationLifecycleHandler(iteration: iterationArgument))

    // Run the application
    try app.run()
} catch {
    print("Critical error in application lifecycle: \(error.localizedDescription)")
    exit(1)
}
