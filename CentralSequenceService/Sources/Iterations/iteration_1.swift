import Vapor

func iteration_1(app: Application) {
    app.get("health") { req -> String in
        return "Server is healthy!"
    }
    print("Iteration 1: Health check route is active.")
}
