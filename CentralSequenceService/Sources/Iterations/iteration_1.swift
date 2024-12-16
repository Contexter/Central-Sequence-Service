import Vapor

public func iteration_1(app: Application) {
    app.get("health") { req -> String in
        return "Iteration 1: Server is healthy!"
    }
}
