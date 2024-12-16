import Vapor

struct RunIterationCommand: Command {
    struct Signature: CommandSignature {
        @Argument(name: "iteration")
        var iteration: String
    }

    let help = "Run a specific iteration of the application."

    func run(using context: CommandContext, signature: Signature) throws {
        let app = Application(.detect())
        defer { app.shutdown() }

        switch signature.iteration {
        case "1":
            print("Running iteration 1...")
            iteration_1(app: app)
        default:
            print("Error: Unknown iteration \(signature.iteration)")
            throw Abort(.badRequest, reason: "Unknown iteration.")
        }

        try app.run()
    }
}
