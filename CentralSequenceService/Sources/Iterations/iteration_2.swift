import Vapor

public func iteration_2(app: Application) {
    app.get("status") { req -> String in
        return "Iteration 2: Server is running!"
    }
}
