import Vapor

/// Logic for Iteration 1
func iteration_1(app: Application) {
    app.get("health") { req -> String in
        return "Iteration 1: Server is healthy!"
    }
    print("Iteration 1 logic executed.")
}
