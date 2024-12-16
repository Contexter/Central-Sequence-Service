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
