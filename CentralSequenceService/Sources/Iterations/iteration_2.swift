import Vapor

/// Logic for Iteration 2
func iteration_2(app: Application) {
    app.get("health") { req -> String in
        return "Iteration 2: Server is healthy!"
    }
    print("Iteration 2 logic executed.")
}
