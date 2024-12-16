import Vapor
import ConsoleKit

do {
    // Detect environment and bootstrap logging
    var env = try Environment.detect()
    try LoggingSystem.bootstrap(from: &env)

    // Create the Vapor application
    let app = Application(env)
    defer { app.shutdown() }

    // Register custom commands
    app.commands.use(RunIterationCommand(), as: "run-iteration")

    // Debug: Show registered commands
    print("Registered commands: \(app.commands.commands.keys)")

    // Parse Command Input
    let input = CommandInput(arguments: CommandLine.arguments)
    var context = CommandContext(console: app.console, input: input)

    // Debug: Log Command-Line Arguments
    print("Command-line arguments: \(CommandLine.arguments)")

    // Custom Command Resolution
    if let commandName = input.arguments.first {
        print("Resolving custom command: \(commandName)")
        switch commandName {
        case "run-iteration":
            let runIterationCommand = RunIterationCommand()
            do {
                try runIterationCommand.run(using: &context)
            } catch {
                print("Critical error in custom command execution: \(error.localizedDescription)")
                exit(1)
            }
        default:
            print("Error: Unknown command '\(commandName)'.")
            exit(1)
        }
    } else {
        print("Error: No command provided.")
        exit(1)
    }
} catch {
    print("Critical error in application lifecycle: \(error.localizedDescription)")
    exit(1)
}
