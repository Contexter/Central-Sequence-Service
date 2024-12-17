import Vapor

// Entry Point
do {
    let app = try Application(.detect())
    defer { app.shutdown() }

    // Select which iteration to run here
    print("Starting Iteration 4...")
    iteration_4(app: app)  // Corrected to include the `app:` label.

    print("Shutting down the application.")
} catch {
    print("Critical error: \(error.localizedDescription)")
    exit(1)
}
