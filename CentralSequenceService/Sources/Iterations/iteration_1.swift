import Vapor

/// Defines the configuration for Iteration 1.
func configureIteration1(_ app: Application) {
    app.get("health") { req -> String in
        return "Iteration 1: Server is healthy!"
    }
}
