import Vapor

func routes(_ app: Application) {
    app.get("health") { req -> String in
        return "Service is running"
    }

    // Register Iteration 7
    iteration_7(app: app)
}
