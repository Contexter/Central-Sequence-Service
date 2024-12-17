import Vapor

// Entry Point
do {
    let app = try Application(.detect())
    defer { app.shutdown() }

    // Call configure to set up the database and routes
    try configure(app)

    // Select which iteration to run here
    print("Starting Iteration 7...")
    iteration_7(app: app)  // Corrected to include the `app:` label.

    print("Shutting down the application.")
} catch {
    print("Critical error: \(error.localizedDescription)")
    exit(1)
}
