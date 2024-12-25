// Sources/Iterations/iteration_3.swift

import Vapor

// Iteration function that establishes a health route
public func iteration_3(app: Application) {
    print("Iteration 3 logic executed.")
    
    // Establish a minimal health route
    app.get("health") { req in
        return "OK"  // Responds with a simple placeholder message
    }
    
    print("Health route added: GET /health")
    print("Server is running. Access the health route at http://localhost:8080/health")
    
    // Run the server
    do {
        try app.run()
    } catch {
        print("Error starting the server: \(error)")
    }
}
