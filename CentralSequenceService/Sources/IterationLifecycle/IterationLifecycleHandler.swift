import Vapor
import Iterations // Import the `Iterations` module

/// A lifecycle handler for managing iteration-specific app logic.
final class IterationLifecycleHandler: LifecycleHandler {
    private let iteration: String

    init(iteration: String) {
        self.iteration = iteration
    }

    func didBoot(_ application: Application) throws {
        print("Starting Iteration \(iteration) Lifecycle...")

        switch iteration {
        case "1":
            print("Running iteration_1...")
            iteration_1(app: application)
        case "2":
            print("Running iteration_2...")
            iteration_2(app: application)
        default:
            print("Unknown iteration: \(iteration)")
            throw Abort(.badRequest, reason: "Unknown iteration.")
        }
    }
}
