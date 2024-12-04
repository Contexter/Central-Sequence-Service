import Vapor

struct RoutesFactory {
    static func registerRoutes(on app: Application) throws {
        app.post("sequence") { req -> String in
            // Placeholder business logic, replace with real implementation
            return "Sequence generation endpoint reached."
        }

        app.put("sequence", "reorder") { req -> String in
            // Placeholder business logic, replace with real implementation
            return "Reorder endpoint reached."
        }
    }
}
