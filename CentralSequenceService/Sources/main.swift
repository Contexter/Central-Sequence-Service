import Foundation
import Vapor

do {
    let app = try Application(.detect()) // Use `try` to handle the throwing initializer
    defer { app.shutdown() } // Ensure app shuts down properly

    let arguments = CommandLine.arguments

    if let iterationIndex = arguments.firstIndex(of: "--run-iteration"),
       iterationIndex + 1 < arguments.count {
        let iterationNumber = arguments[iterationIndex + 1]
        switch iterationNumber {
        case "1":
            print("Running iteration 1...")
            iteration_1(app: app)
        default:
            print("Error: Unknown iteration \(iterationNumber)")
        }
    } else {
        print("Starting Central Sequence Service...")
        app.get { req in
            "Central Sequence Service is running!"
        }
        try app.run() // Start Vapor's HTTP server
    }
} catch {
    print("Failed to start application: \(error.localizedDescription)")
    exit(1) // Exit with error
}
