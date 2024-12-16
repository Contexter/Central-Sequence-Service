import Vapor

/// Defines the configuration for Iteration 2.
func configureIteration2(_ app: Application) {
    app.get("status") { req -> String in
        return "Iteration 2: Server is running smoothly!"
    }
}

