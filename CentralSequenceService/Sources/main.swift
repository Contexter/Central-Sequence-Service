import Vapor

do {
    var env = Environment.custom(
        arguments: CommandLine.arguments,
        environment: .detect()
    )
    try LoggingSystem.bootstrap(from: &env)

    let app = Application(env)
    defer { app.shutdown() }

    // Register the custom command
    app.commands.use(RunIterationCommand(), as: "run-iteration")

    try app.run()
} catch {
    print("Failed to start application: \(error.localizedDescription)")
    exit(1)
}
