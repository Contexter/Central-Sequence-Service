import Vapor

struct RoutesFactory {
    static func registerRoutes(_ app: Application) throws {
        // Add default routes
        app.get { req async in
            "It works!"
        }

        app.get("hello") { req async -> String in
            "Hello, world!"
        }

        // Register Sequence-related routes
        try app.register(collection: SequenceRoutes())
    }
}
